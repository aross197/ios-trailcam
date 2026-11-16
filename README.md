# TrailCam

Simple motion-detecting camera that uploads photos to [ntfy.sh](https://ntfy.sh).

## Live Web Version

After enabling GitHub Pages (see below), open:

**https://aross197.github.io/ios-trailcam/**

### How to turn on GitHub Pages (required for the camera to work)

1. Go to the repository: https://github.com/aross197/ios-trailcam
2. Click **Settings** → **Pages** (left sidebar)
3. Under "Source", choose **Deploy from a branch**
4. Branch: `main`  /  Folder: `/ (root)`
5. Click Save

Wait 30–60 seconds, then open the link above on your phone.

### Using it
1. Change the ntfy topic to something private (e.g. `https://ntfy.sh/mytrailcam-xyz123`)
2. Tap **Start Camera** and allow permission
3. Wave your hand in front of the camera to test
4. Use **Test Upload** to force a photo without waiting for motion

The topic is saved in the browser so you don’t have to re-type it.

### Tips
- Lower the threshold number = more sensitive
- Works best in Chrome or Safari on a phone
- The page must be served over HTTPS (GitHub Pages does this)

## Native iOS Version

`ViewController.swift` contains the original AVFoundation code for a real iOS app (better for long unattended use).

## License
MIT
