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

  private let captureSession = AVCaptureSession()
  private(set) var cameraLayer: AVCaptureVideoPreviewLayer!

  weak var delegate: CameraControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    setupAVSession()

    // begin the session
    self.captureSession.startRunning()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // make sure the layer is the correct size
    self.cameraLayer.frame = view.bounds
  }

  private func setupAVSession() {
    captureSession.beginConfiguration()
    captureSession.sessionPreset = .high

    defer {
      captureSession.commitConfiguration()
    }

    // input
    guard
      let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
      let input = try? AVCaptureDeviceInput(device: backCamera),
      captureSession.canAddInput(input)
    else {
      return
    }

    captureSession.addInput(input)

    // output
    let output = AVCaptureVideoDataOutput()

    guard captureSession.canAddOutput(output) else {
      return
    }

    captureSession.addOutput(output)
    output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
    output.alwaysDiscardsLateVideoFrames = true

    // preview layer
    cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    view.layer.addSublayer(cameraLayer)
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
