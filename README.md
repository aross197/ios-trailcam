# TrailCam

Motion-detecting trail camera that uploads photos to [ntfy.sh](https://ntfy.sh) (or any webhook).

There are two versions in this repo:

## 1. Web version (recommended for quick use)

Open **[web/index.html](web/index.html)** in a modern mobile browser (Chrome or Safari recommended).

Features:
- Uses device camera (prefers rear camera)
- Lightweight pixel-difference motion detection
- Configurable sensitivity + cooldown
- JPEG upload to your ntfy topic
- Dark UI, works offline after first load

### Quick start
1. Open `web/index.html` on your phone (or host it somewhere).
2. Replace the default ntfy URL with your private topic, e.g. `https://ntfy.sh/my-secret-trailcam-xyz`.
3. Tap **Start Camera** and allow camera permission.
4. Subscribe to the same topic on your other devices to receive the photos as notifications.

> Note: Browser versions cannot run completely headless or keep the screen off. For true unattended field use the native iOS version is better.

## 2. Native iOS version

`ViewController.swift` — original AVFoundation implementation.

- Pixel-based motion detection
- Cellular-friendly JPEG upload
- Designed for longer unattended use (keeps idle timer disabled)

Create a new iOS App project in Xcode, drop in the ViewController, set your ntfy URL, and add the camera usage description in Info.plist.

## Tips
- Use a hard-to-guess ntfy topic name.
- Lower the motion threshold for higher sensitivity (more false positives).
- Increase cooldown if an animal stays in frame.
- Lighting changes and moving vegetation will trigger the detector — experiment with the threshold outdoors.

## License
MIT
