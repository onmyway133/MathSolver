//
//  VisionService.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import Vision
import AVFoundation
import UIKit

protocol VisionServiceDelegate: class {
  func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation])
}

final class VisionService {

  weak var delegate: VisionServiceDelegate?

  func handle(buffer: CMSampleBuffer) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
      return
    }

    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    guard let image = ciImage.toUIImage() else {
      return
    }

    makeRequest(image: image)
  }

  private func makeRequest(image: UIImage) {
    guard let cgImage = image.cgImage else {
      assertionFailure()
      return
    }

    let handler = VNImageRequestHandler(
      cgImage: cgImage,
      orientation: CGImagePropertyOrientation.right,
      options: [VNImageOption: Any]()
    )

    let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] request, error in
      DispatchQueue.main.async {
        self?.handle(image: image, request: request, error: error)
      }
    })

    request.reportCharacterBoxes = true

    do {
      try handler.perform([request])
    } catch {
      print(error as Any)
    }
  }

  private func handle(image: UIImage, request: VNRequest, error: Error?) {
    guard
      let results = request.results as? [VNTextObservation]
    else {
      return
    }

    delegate?.visionService(self, didDetect: image, results: results)
  }
}
