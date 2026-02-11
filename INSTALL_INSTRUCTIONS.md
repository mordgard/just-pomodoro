# Installing Just Pomodoro on macOS

Since this app isn't signed with an Apple Developer certificate, macOS will show a security warning. Here's how to install it:

## Method 1: Right-click to Open (Easiest)
1. Download and open the DMG file
2. **Right-click** (or Control+click) on "Just Pomodoro.app"
3. Select **"Open"** from the menu
4. Click **"Open"** in the security dialog
5. The app will now launch and you can use it normally

## Method 2: System Settings (If Method 1 doesn't work)
1. Try to open the app (it will show a warning)
2. Open **System Settings** → **Privacy & Security**
3. Scroll down to **Security** section
4. Click **"Open Anyway"** next to "Just Pomodoro was blocked"
5. Click **"Open"** in the confirmation dialog

## Method 3: Terminal (For advanced users)
If the above methods don't work, open Terminal and run:

```bash
xattr -cr /Applications/Just\ Pomodoro.app
```

Then open the app normally.

---

## Note for Friends
This app is safe - it's just not signed by Apple because the developer doesn't have a paid Apple Developer account ($99/year). The source code is available and can be inspected.

The app will remember this choice and open normally after the first time.
