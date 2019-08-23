#./adb kill-server
./adb forward tcp:4444 localabstract:/adb-hub
./adb connect 127.0.0.1:4444
./adb devices