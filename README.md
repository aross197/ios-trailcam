# iOS TrailCam

A lightweight iOS trail camera app that uses the device's camera for motion detection and uploads photos over cellular to an ntfy.sh topic (or custom webhook).

## Features
- Real-time motion detection using pixel difference sampling
- Configurable sensitivity and cooldown
- Automatic photo capture on motion
- JPEG compression and upload to ntfy.sh (or any webhook)
- Keeps device awake for field use
- Dark/black UI for stealth/headless operation

## Setup
1. Open the project in Xcode (you'll need to create a new iOS App project and add this ViewController).
2. Replace the `webhookURLString` with your own ntfy.sh topic URL, e.g. `https://ntfy.sh/my_secret_trailcam_topic`.
3. Add required privacy permissions in Info.plist:
   - `NSCameraUsageDescription`
   - Possibly `NSPhotoLibraryUsageDescription` if saving locally later
4. For background/field operation, consider adding background modes if needed.

## Usage
- Point the back camera at the area you want to monitor.
- Motion above the threshold triggers a photo upload.
- Photos appear as notifications on any device subscribed to the ntfy topic.

## Notes
- Designed for simplicity and low power/CPU usage.
- Test thoroughly; motion detection is basic pixel sampling and can be affected by lighting changes, wind, etc.
- This is a single ViewController example — integrate into a full app as needed.

## License
MIT (or whatever you prefer)