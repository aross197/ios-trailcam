# TrailCam

Free motion-detecting trail camera for **iPhone and Android**.

It runs as a Progressive Web App (PWA) — install it to your home screen and it feels like a normal app.

## Live App

**https://aross197.github.io/ios-trailcam/**

### First-time setup (important)

1. Go to the repo → **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: `main`  /  Folder: `/ (root)`
4. Save
5. Wait 1 minute, then open the link above on your phone.

### How to install on your phone

**Android (Chrome)**  
- Open the link → tap the menu (⋮) → **Install app** or **Add to Home screen**

**iPhone (Safari)**  
- Open the link → tap the Share button → **Add to Home Screen**

### How to use
1. Change the ntfy topic to a private one (example: `https://ntfy.sh/mytrailcam-xyz789`)
2. Tap **Start Camera** and allow permission
3. Wave your hand in front of the camera to test motion detection
4. Use **Test Upload** to force a photo anytime

Photos will appear as notifications on any device subscribed to the same ntfy topic.

### Tips
- Lower the threshold number = more sensitive
- The topic is saved automatically
- Works best when added to the home screen

## Original iOS Swift version
Still available in `ViewController.swift` (requires a Mac + Xcode).

## License
MIT
