//
//  CameraController.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraControllerDelegate: class {
  func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer)
}

final class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
  private(set) lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)

  private lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = AVCaptureSession.Preset.photo

    guard
      let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
      let input = try? AVCaptureDeviceInput(device: backCamera)
    else {
      return session
    }

    session.addInput(input)
    return session
  }()

  weak var delegate: CameraControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(cameraLayer)

    // register to receive buffers from the camera
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
    self.captureSession.addOutput(videoOutput)

    // begin the session
    self.captureSession.startRunning()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // make sure the layer is the correct size
    self.cameraLayer.frame = view.bounds
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection) {

    sample = sampleBuffer
  }

  // FIXME: Test

  var sample: CMSampleBuffer?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    if let sample = sample {
      delegate?.cameraController(self, didCapture: sample)
    }
  }
}
