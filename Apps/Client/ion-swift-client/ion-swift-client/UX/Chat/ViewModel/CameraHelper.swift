import AVFoundation
import CoreImage
import CoreMedia
import UIKit

/// `CameraCaptureHelper` wraps up all the code required to access an iOS device's
/// camera images and convert to a series of `CIImage` images.
///
/// The helper's delegate, `CameraCaptureHelperDelegate` receives notification of
/// a new image in the main thread via `newCameraImage()`.
class CameraCaptureHelper: NSObject {
    let captureSession = AVCaptureSession()
    let cameraPosition: AVCaptureDevice.Position

    weak var delegate: CameraCaptureHelperDelegate?

    required init(cameraPosition: AVCaptureDevice.Position) {
        self.cameraPosition = cameraPosition

        super.init()

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.initialiseCaptureSession()

        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.initialiseCaptureSession()
                }
            }

        case .denied: // The user has previously denied access.
            return

        case .restricted: // The user can't grant access due to restrictions.
            return
        default: break
        }
    }

    fileprivate func initialiseCaptureSession() {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo

        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: AVMediaType.video,
            position: .front
        ) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            captureSession.addInput(input)
        } catch {
            fatalError("Unable to access back camera")
        }

        let videoOutput = AVCaptureVideoDataOutput()

        videoOutput.setSampleBufferDelegate(self,
                                            queue: DispatchQueue(label: "sample buffer delegate",
                                                                 attributes: []))

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.startRunning()
    }
}

extension CameraCaptureHelper: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        connection.isVideoMirrored = true
        connection.videoOrientation = AVCaptureVideoOrientation.portrait

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        DispatchQueue.main.async {
            if let image = UIImage(pixelBuffer: pixelBuffer) {
                self.delegate?.newCameraImage(self, image: image)
            }
        }
    }
}

protocol CameraCaptureHelperDelegate: AnyObject {
    func newCameraImage(_ cameraCaptureHelper: CameraCaptureHelper, image: UIImage)
}

import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let image = cgImage else { return nil }

        self.init(cgImage: image)
    }
}
