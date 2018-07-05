//
//  ViewController.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit
import Anchors
import AVFoundation
import Vision

class ViewController: UIViewController {

  private let cameraController = CameraController()
  private let visionService = VisionService()
  private let boxService = BoxService()
  private let ocrService = OCRService()
  private let mathService = MathService()

  private lazy var recognisedTextLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.textColor = .black
    label.alpha = 0
    return label
  }()

  private lazy var calculatedLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 50)
    label.textColor = .green
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraController.delegate = self
    add(childController: cameraController)
    activate(
      cameraController.view.anchor.edges
    )

    view.addSubview(recognisedTextLabel)
    view.addSubview(calculatedLabel)
    activate(
      recognisedTextLabel.anchor.bottom.right.constant(-20),
      calculatedLabel.anchor.center
    )

    visionService.delegate = self
    boxService.delegate = self
    ocrService.delegate = self
  }
}

extension ViewController: CameraControllerDelegate {
  func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer) {
    calculatedLabel.alpha = 0
    visionService.handle(buffer: buffer)
  }
}

extension ViewController: VisionServiceDelegate {
  func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation]) {
    boxService.handle(
      overlayLayer: cameraController.overlayLayer,
      image: image,
      results: results,
      on: cameraController.view
    )
  }
}

extension ViewController: BoxServiceDelegate {
  func boxService(_ service: BoxService, didDetect image: UIImage) {
    ocrService.handle(image: image)
  }
}

extension ViewController: OCRServiceDelegate {
  func ocrService(_ service: OCRService, didDetect text: String) {
    recognisedTextLabel.text = text
    let result = mathService.solve(expression: text)
    show(result: result)
  }

  private func show(result: Double) {
    calculatedLabel.transform = .identity
    UIView.animate(
      withDuration: 0.25,
      animations: {
        self.calculatedLabel.alpha = 1.0
        self.calculatedLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
      },
      completion: nil
    )
  }
}
