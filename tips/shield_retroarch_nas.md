1. In case anyone's interested, I just found out how to access my NAS ROMs from Retroarch with the Android 11 / Shield 9 upgrade. Assuming you're under the latest 9.0+ firmware:
2. Mount the NAS under system preferences.
3. Check with an file manager tool (e.g. x-plore) where the NAS is mounted (e.g. /storage/NAS/Roms).
4. Share the Shield files over SMB (system preferences as well).
5. Make sure RetroArch is closed.
6. From your PC, mount the shield SMB share and edit directly the Android/data/com.retroarch.aarch64/files/retroarch.cfg file
7. Look for rgui_browser_directory and replace "default" with your mounted SMB share (e.g. "/storage/NAS/Roms")
8. Open Retroarch and it should work :)
