from datetime import datetime, timezone
import json
from bleak import BleakScanner
from kivy.app import App
from kivy.uix.label import Label
from kivy.clock import Clock
import asyncio
from kivy.utils import platform
from my_automower_ble.error_codes import ErrorCodes
from my_automower_ble.mower import Mower

# For Android-specific imports
if platform == 'android':
    from jnius import autoclass
    from android.permissions import request_permissions, Permission

# Create the App class
class MyApp(App):
    def build(self):
        self.label = Label(text="Connecting ...")

        if platform == 'android':
            self.check_android_permissions()

        Clock.schedule_interval(self.start_background_thread, 30)
        # self.start_background_thread()

        return self.label

    def check_android_permissions(self):
        from kivy.utils import platform
        if platform == 'android':
            from jnius import autoclass
            autoclass('org.jnius.NativeInvocationHandler')
            autoclass('com.github.hbldh.bleak.PythonScanCallback')
            autoclass('com.github.hbldh.bleak.PythonBluetoothGattCallback')
            autoclass('com.github.hbldh.bleak.PythonScanCallback$Interface')
            from android.permissions import request_permissions, Permission

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
        asyncio.run(self.call_mower())

    async def call_mower(self):
        mower = Mower(1197489078, "60:98:66:EF:B0:0B", 6612)
        try:
            def update_label_clear():
                Clock.schedule_once(lambda dt: self.label_clear(), 0)
            def update_label_text(new_text):
                Clock.schedule_once(lambda dt: self.label_update(new_text), 0)

            update_label_clear()
            update_label_text("Connecting ...")

            from kivy.utils import platform
            if platform == 'android':
                from jnius import autoclass
                autoclass('org.jnius.NativeInvocationHandler')
                autoclass('com.github.hbldh.bleak.PythonScanCallback')
                autoclass('com.github.hbldh.bleak.PythonBluetoothGattCallback')
                autoclass('com.github.hbldh.bleak.PythonScanCallback$Interface')
                UUID = autoclass('java.util.UUID')
                UUID.__hash__ = UUID.hashCode
            device = await BleakScanner.find_device_by_address(mower.address)

            if device is None:
                update_label_text(f"Unable to connect to device address: {mower.address}\n"
                                "Please make sure the device is correct, powered on, and nearby")
                return

            await mower.connect(device)
            update_label_text("Connected to mower.")

            manufacturer = await mower.get_manufacturer()
            update_label_text(f"Mower manufacturer: {manufacturer}")

            model = await mower.get_model()
            update_label_text(f"Mower model: {model}")

            charging = await mower.is_charging()
            if charging:
                update_label_text("Mower is charging")
            else:
                update_label_text("Mower is not charging")

            battery_level = await mower.battery_level()
            update_label_text(f"Battery level: {battery_level}%")

            state = await mower.mower_state()
            if state:
                update_label_text(f"Mower state: {state.name}")

            activity = await mower.mower_activity()
            if activity:
                update_label_text(f"Mower activity: {activity.name}")

            next_start_time = await mower.mower_next_start_time()
            if next_start_time:
                update_label_text(f"Next start time: {next_start_time.strftime('%Y-%m-%d %H:%M:%S')}")
            else:
                update_label_text("No next start time")

            statuses = await mower.command("GetAllStatistics")
            for status, value in statuses.items():
                update_label_text(f"{status}: {value}")

            serial_number = await mower.command("GetSerialNumber")
            update_label_text(f"Serial number: {serial_number}")

            mower_name = await mower.command("GetUserMowerNameAsAsciiString")
            update_label_text(f"Mower name: {mower_name}")

            next_start_time = await mower.command("GetNextStartTime")
            update_label_text(f"GetNextStartTime: {json.dumps(next_start_time)}")

            last_message = await mower.command("GetMessage", messageId=0)
            update_label_text("Last message:")
            update_label_text(datetime.fromtimestamp(last_message["time"], timezone.utc).strftime("%Y-%m-%d %H:%M:%S"))
            update_label_text(ErrorCodes(last_message["code"]).name)
            update_label_text(f"Last check: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        except:
            update_label_text("Error.")
        finally:
            await mower.disconnect()
            update_label_text("Disconnected from mower.")

    def label_update(self, new_text):
        self.label.text += "\n" + new_text

    def label_clear(self):
        self.label.text = ""

if __name__ == '__main__':
    MyApp().run()

# from kivy.app import App
# from kivy.uix.boxlayout import BoxLayout
# from kivy.uix.button import Button
# from kivy.uix.label import Label
# from kivy.uix.scrollview import ScrollView
# from kivy.uix.gridlayout import GridLayout
# from kivy.clock import mainthread
# from bleak import BleakScanner
# import asyncio

# class BLEScannerApp(App):
#     def build(self):
#         self.layout = BoxLayout(orientation='vertical')

#         # Button to start BLE scan
#         self.scan_button = Button(text='Scan for BLE Devices', size_hint_y=None, height=50)
#         self.scan_button.bind(on_press=self.scan_for_devices)

#         self.layout.add_widget(self.scan_button)

#         # Scrollable area to display devices
#         self.scroll_view = ScrollView(size_hint=(1, None), size=(400, 400))
#         self.grid = GridLayout(cols=1, size_hint_y=None)
#         self.grid.bind(minimum_height=self.grid.setter('height'))

#         self.scroll_view.add_widget(self.grid)
#         self.layout.add_widget(self.scroll_view)

#         return self.layout

#     async def scan(self):
#         # Start the BLE scanning using Bleak
#         devices = await BleakScanner.discover()
#         self.display_devices(devices)

#     def scan_for_devices(self, instance):
#         # Launch the scan in a background thread
#         asyncio.run(self.scan())

#     @mainthread
#     def display_devices(self, devices):
#         # Clear the previous device list
#         self.grid.clear_widgets()

#         if not devices:
#             self.grid.add_widget(Label(text="No BLE devices found", size_hint_y=None, height=40))
#         else:
#             for device in devices:
#                 self.grid.add_widget(Label(text=f'{device.name} ({device.address})', size_hint_y=None, height=40))

# if __name__ == '__main__':
#     BLEScannerApp().run()

