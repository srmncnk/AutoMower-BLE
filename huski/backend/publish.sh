#!/bin/bash

ROOT="$(cd "$(dirname "$0")"; pwd)"
ENTRY=$ROOT/lib/main.dart
OUTPUT=backend
ARCHIVE=backend.txz
SSH_DESTINATION=root@irmancnik.dev
REMOTE_DESTINATION=/srv/huski
SERVICE_NAME=huski

cd $ROOT
dart pub get || {
    echo "Error fetching dependencies" && cd $ROOT &&
    exit 1
}
dart compile exe $ENTRY -o $ROOT/$OUTPUT || {
    echo "Error during build" && cd $ROOT &&
    exit 2
}
XZ_OPT="-7 -T 0 -v " tar Jcpf $ROOT/$ARCHIVE $OUTPUT || {
    echo "Could not prepare archive" && cd $ROOT &&
    exit 3
}

scp $ARCHIVE $SSH_DESTINATION:$REMOTE_DESTINATION || {
    echo "Error transfering archive" && exit 1
}

ssh $SSH_DESTINATION "cd $REMOTE_DESTINATION && tar xf $ARCHIVE && service $SERVICE_NAME restart" || {
    echo "Error deploying service" && exit 2
}
