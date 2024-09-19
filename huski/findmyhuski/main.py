from datetime import datetime, timezone, timedelta
import json
from bleak import BleakScanner
import httpx
from kivy.app import App
from kivy.uix.label import Label
from kivy.clock import Clock
import asyncio
from kivy.utils import platform
from my_automower_ble.error_codes import ErrorCodes
from my_automower_ble.mower import Mower
import os
import threading
import time
import sys

if platform == 'android':
    from jnius import autoclass # type: ignore
    from android.permissions import request_permissions, Permission # type: ignore

async def call_with_timeout(coro, timeout_seconds=10):
        return await asyncio.wait_for(coro, timeout=timeout_seconds)

class MyApp(App):
    def build(self):
        self.last_check = datetime.now()
        self.label = Label(text="Connecting ...")

        if platform == 'android':
            self.check_android_permissions()

        self.log_file_path = self.setup_logging()
        self.log("App started")

        Clock.schedule_interval(self.start_background_thread, 60)
        self.start_watchdog()
        return self.label

    def check_android_permissions(self):
        from kivy.utils import platform
        if platform == 'android':
            from jnius import autoclass # type: ignore
            autoclass('org.jnius.NativeInvocationHandler')
            autoclass('com.github.hbldh.bleak.PythonScanCallback')
            autoclass('com.github.hbldh.bleak.PythonBluetoothGattCallback')
            autoclass('com.github.hbldh.bleak.PythonScanCallback$Interface')
            from android.permissions import request_permissions, Permission # type: ignore

            # Define callback to handle permission results
            def callback(permissions, results):
                if not all(results):
                    self.label_update("Permissions were not granted, exiting.")
                    return
                self.label_update("All permissions granted, proceeding with Bluetooth.")

            # Check Android version and request appropriate permissions
            if autoclass('android.os.Build$VERSION').SDK_INT >= 31:
                # Android 12 (API level 31+) requires these additional permissions
                permissions_to_request = [
                    Permission.BLUETOOTH_CONNECT,
                    Permission.BLUETOOTH_SCAN,
                    Permission.BLUETOOTH
                ]
            else:
                # Android versions < 31
                permissions_to_request = [
                    Permission.BLUETOOTH,
                    Permission.BLUETOOTH_ADMIN
                ]

            # Request the permissions
            request_permissions(permissions_to_request, callback)


    def start_background_thread(self, _):
        self.log("STEP 1")
        httpx.Client().post("https://api.irmancnik.dev/huski/v1/ping", json={"ping": "pong"})
        current_time = datetime.now().time()
        start_time = current_time.replace(hour=7, minute=0, second=0, microsecond=0)
        end_time = current_time.replace(hour=21, minute=0, second=0, microsecond=0)
        if current_time < start_time or current_time > end_time:
            return
        try:
            self.log("STEP 2")
            asyncio.run(self.call_mower())
        except:
            return

    async def call_mower(self):
        self.log("STEP 3")
        self.last_check = datetime.now()
        mower = Mower(1197489078, "60:98:66:EF:B0:0B", 6612)
        device = None
        try:
            def update_label_clear():
                Clock.schedule_once(lambda dt: self.label_clear(), 0)
            def update_label_text(new_text):
                Clock.schedule_once(lambda dt: self.label_update(new_text), 0)

            update_label_clear()
            update_label_text("Connecting ...")

            self.log("STEP 4")
            from kivy.utils import platform
            if platform == 'android':
                from jnius import autoclass # type: ignore
                autoclass('org.jnius.NativeInvocationHandler')
                autoclass('com.github.hbldh.bleak.PythonScanCallback')
                autoclass('com.github.hbldh.bleak.PythonBluetoothGattCallback')
                autoclass('com.github.hbldh.bleak.PythonScanCallback$Interface')
                UUID = autoclass('java.util.UUID')
                UUID.__hash__ = UUID.hashCode
            device = await BleakScanner.find_device_by_address(mower.address)
            self.log("STEP 5")

            if device is None:
                update_label_text(f"Unable to connect to device")
                update_label_text(f"Last check: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                return

            self.log("STEP 6")
            await call_with_timeout(mower.connect(device))
            update_label_text("Connected to mower.")

            self.log("STEP 7")
            manufacturer = await mower.get_manufacturer()
            update_label_text(f"Mower manufacturer: {manufacturer}")

            self.log("STEP 8")
            model = await mower.get_model()
            update_label_text(f"Mower model: {model}")

            self.log("STEP 9")
            charging = await mower.is_charging()
            if charging:
                update_label_text("Mower is charging")
            else:
                update_label_text("Mower is not charging")

            self.log("STEP 10")
            battery_level = await mower.battery_level()
            update_label_text(f"Battery level: {battery_level}%")

            self.log("STEP 11")
            state = await mower.mower_state()
            if state:
                update_label_text(f"Mower state: {state.name}")

            self.log("STEP 12")
            activity = await mower.mower_activity()
            if activity:
                update_label_text(f"Mower activity: {activity.name}")

            self.log("STEP 13")
            next_start_time = await mower.mower_next_start_time()
            if next_start_time:
                update_label_text(f"Next start time: {next_start_time.strftime('%Y-%m-%d %H:%M:%S')}")
            else:
                update_label_text("No next start time")

            self.log("STEP 14")
            statuses = await mower.command("GetAllStatistics")
            for status, value in statuses.items():
                update_label_text(f"{status}: {value}")

            self.log("STEP 15")
            serial_number = await mower.command("GetSerialNumber")
            update_label_text(f"Serial number: {serial_number}")

            self.log("STEP 16")
            mower_name = await mower.command("GetUserMowerNameAsAsciiString")
            update_label_text(f"Mower name: {mower_name}")

            self.log("STEP 17")
            next_start_time = await mower.command("GetNextStartTime")
            update_label_text(f"GetNextStartTime: {json.dumps(next_start_time)}")

            self.log("STEP 18")
            last_message = await mower.command("GetMessage", messageId=0)
            update_label_text("Last message:")
            update_label_text(datetime.fromtimestamp(last_message["time"], timezone.utc).strftime("%Y-%m-%d %H:%M:%S"))
            update_label_text(ErrorCodes(last_message["code"]).name)
            update_label_text(f"Last check: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

            data = {}
            data["name"] = mower_name
            data["model"] = model
            data["serial_number"] = serial_number
            data["manufacturer"] = manufacturer
            data["state"] = state.value if state else None
            data["activity"] = activity.value if activity else None
            data["last_message"] = ErrorCodes(last_message["code"]).value if last_message["code"] else None
            data["last_message_time"] = last_message["time"]
            data["next_start_time"] = next_start_time
            data["battery_level"] = battery_level
            data["is_charging"] = charging
            data["total_running_time"] = statuses["totalRunningTime"]
            data["total_cutting_time"] = statuses["totalCuttingTime"]
            data["total_charging_time"] = statuses["totalChargingTime"]
            data["total_searching_time"] = statuses["totalSearchingTime"]
            data["number_of_collisions"] = statuses["numberOfCollisions"]
            data["number_of_charging_cycles"] = statuses["numberOfChargingCycles"]
            data["blade_usage_time"] = statuses["cuttingBladeUsageTime"]
            client = httpx.Client()
            url = "https://api.irmancnik.dev/huski/v1/state"
            response = client.post(url, json=data)
            if response.status_code == 200:
                response_data = response.json()
                if "command" in response_data and response_data["command"]:
                    command = response_data["command"]
                    update_label_text(f"Executing command: {command}")
                    match command:
                        case "park":
                            result = await mower.mower_park()
                        case "pause":
                            result = await mower.mower_pause()
                        case "resume":
                            result = await mower.mower_resume()
                        case "override":
                            result = await mower.mower_override()
                        case _:
                            result = "unknown command"
                    update_label_text(f"Command result: {str(result)}")
                else:
                    update_label_text("Data sent, no command found.")
            else:
                update_label_text(f"Failed to send data. Status code: {response.status_code}")
            self.log("STEP 19")
        except Exception as e:
            update_label_text(f"Error. {e}")
        finally:
            try:
                self.log("STEP 20")
                if device is not None:
                    await mower.disconnect()
                update_label_text("Disconnected from mower.")
            except:
                update_label_text("Error disconnecting from mower.")
                update_label_text(f"Last check: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    def label_update(self, new_text):
        self.label.text += "\n" + new_text

    def label_clear(self):
        self.label.text = ""

    def setup_logging(self):
        if platform == 'android':
            Context = autoclass('android.content.Context')
            Environment = autoclass('android.os.Environment')
            current_activity = autoclass('org.kivy.android.PythonActivity').mActivity
            external_dir = current_activity.getExternalFilesDir(None)
            log_folder = external_dir.getAbsolutePath()
        else:
            log_folder = './logs'
            os.makedirs(log_folder, exist_ok=True)

        log_file = os.path.join(log_folder, 'huski.log')
        return log_file

    def log(self, message):
        try:
            fullMessage = f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}: {message}\n"
            with open(self.log_file_path, 'a') as log_file:
                log_file.write(fullMessage)
            print(fullMessage)
        except Exception as e:
            print(f"Error: {str(e)}")

    def start_watchdog(self):
        # Create and start a thread
        thread = threading.Thread(target=self.watchdog, daemon=True)
        thread.start()

    def watchdog(self):
        while True:
            try:
                time.sleep(60)
                print("Background task running...")
                if self.last_check is not None and datetime.now() - self.last_check > timedelta(minutes=5):
                    self.log(f"Restarting app...")
                    self.restart_app()
                else:
                    time_ago = datetime.now() - self.last_check
                    print(f"Last check was done {time_ago} ago (self.last_check: {self.last_check})")
                    self.log(f"Last check was done {time_ago} ago (self.last_check: {self.last_check})")
            except:
                self.log(f"Exception during watchdog")

    def restart_app(self):
        from jnius import autoclass # type: ignore
        PythonActivity = autoclass('org.kivy.android.PythonActivity')
        Intent = autoclass('android.content.Intent')
        context = PythonActivity.mActivity.getApplicationContext()
        activity = PythonActivity.mActivity
        intent = context.getPackageManager().getLaunchIntentForPackage("com.irmancnik.restart_huski")
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        activity.finish()
        sys.exit(0)

if __name__ == '__main__':
    MyApp().run()