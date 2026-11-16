import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoDataOutput: AVCaptureVideoDataOutput!
    
    let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    // Motion detection variables
    var lastSampleTime: Date = .distantPast
    var lastTriggerTime: Date = .distantPast
    var previousBuffer: CVPixelBuffer?
    let motionThreshold: CGFloat = 25.0 // Adjust sensitivity (lower = more sensitive)
    let cooldownSeconds: TimeInterval = 5.0 // Time between triggers to save data
    
    // Replace with your ntfy.sh topic or custom webhook URL
    let webhookURLString = "https://ntfy.sh/your_unique_trailcam_topic_here"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keep the phone awake and screen dim/dark for headless field operation
        UIApplication.shared.isIdleTimerDisabled = true
        view.backgroundColor = .black
        
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium // Balanced resolution for fast cellular upload

        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error: No back camera found.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            stillImageOutput = AVCapturePhotoOutput()
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addOutput(videoDataOutput)
            }
            
            videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            
            sessionQueue.async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }
    }

    // MARK: - Lightweight Pixel-Based Motion Detection
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Throttle check frequency to once per second to save CPU/battery
        guard Date().timeIntervalSince(lastSampleTime) > 1.0 else { return }
        lastSampleTime = Date()
        
        if let prev = previousBuffer {
            if detectMotion(current: pixelBuffer, previous: prev) {
                print("Motion detected! Triggering snapshot...")
                triggerCapture()
            }
        }
        
        // Retain current buffer for next comparison frame
        previousBuffer = pixelBuffer
    }

    func detectMotion(current: CVPixelBuffer, previous: CVPixelBuffer) -> Bool {
        CVPixelBufferLockBaseAddress(current, .readOnly)
        CVPixelBufferLockBaseAddress(previous, .readOnly)
        
        defer {
            CVPixelBufferUnlockBaseAddress(current, .readOnly)
            CVPixelBufferUnlockBaseAddress(previous, .readOnly)
        }
        
        guard let currBase = CVPixelBufferGetBaseAddress(current),
              let prevBase = CVPixelBufferGetBaseAddress(previous) else { return false }
        
        let width = CVPixelBufferGetWidth(current)
        let height = CVPixelBufferGetHeight(current)
        let currBytes = CVPixelBufferGetBytesPerRow(current)
        let prevBytes = CVPixelBufferGetBytesPerRow(previous)
        
        var diffSum: CGFloat = 0
        let sampleStep = 16 // Sample every 16th pixel for speed
        var sampleCount: CGFloat = 0
        
        for y in stride(from: 0, to: height, by: sampleStep) {
            let currRow = currBase.advanced(by: y * currBytes)
            let prevRow = prevBase.advanced(by: y * prevBytes)
            
            for x in stride(from: 0, to: width, by: sampleStep) {
                let currPixel = currRow.advanced(by: x * 4).assumingMemoryBound(to: UInt8.self).pointee
                let prevPixel = prevRow.advanced(by: x * 4).assumingMemoryBound(to: UInt8.self).pointee
                
                diffSum += abs(CGFloat(currPixel) - CGFloat(prevPixel))
                sampleCount += 1
            }
        }
        
        let avgDiff = sampleCount > 0 ? diffSum / sampleCount : 0
        return avgDiff > motionThreshold
    }

    func triggerCapture() {
        // Enforce cooldown so we don't spam uploads if an animal lingers
        guard Date().timeIntervalSince(lastTriggerTime) > cooldownSeconds else { return }
        lastTriggerTime = Date()
        
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Photo Capture & Cellular Upload
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let compressedImage = UIImage(data: imageData)?.jpegData(compressionQuality: 0.5),
              let url = URL(string: webhookURLString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("TrailCam Event", forHTTPHeaderField: "Title")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = compressedImage
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to upload photo over cellular: \(error)")
            } else {
                print("Successfully uploaded trail cam photo over cellular!")
            }
        }
        task.resume()
    }
}
