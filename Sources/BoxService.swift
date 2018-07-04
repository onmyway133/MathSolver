//
//  BoxDrawer.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

protocol BoxServiceDelegate: class {
  func boxService(_ service: BoxService, didDetect images: [UIImage])
}

final class BoxService {
  private var layers: [CALayer] = []

  weak var delegate: BoxServiceDelegate?

  func handle(cameraLayer: AVCaptureVideoPreviewLayer, image: UIImage, results: [VNTextObservation], on view: UIView) {
    reset()

    var images: [UIImage] = []
    let results = results.filter({ $0.confidence > 0.5 })

    layers = results.map({ result in
      let layer = CALayer()
      view.layer.addSublayer(layer)
      layer.borderWidth = 2
      layer.borderColor = UIColor.green.cgColor

      do {
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: image.size.width, y: -image.size.height)
        transform = transform.translatedBy(x: 0, y: -1)
        let rect = result.boundingBox.applying(transform)

        let scaleUp: CGFloat = 0.2
        let biggerRect = rect.insetBy(
          dx: -rect.size.width * scaleUp,
          dy: -rect.size.height * scaleUp
        )

        if let croppedImage = crop(image: image, rect: biggerRect) {
          images.append(croppedImage)
        }
      }

      do {
        let rect = cameraLayer.layerRectConverted(fromMetadataOutputRect: result.boundingBox)
        layer.frame = rect
      }

      return layer
    })

    delegate?.boxService(self, didDetect: images)
  }

  private func crop(image: UIImage, rect: CGRect) -> UIImage? {
    guard let cropped = image.cgImage?.cropping(to: rect) else {
      return nil
    }

    return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
  }

  private func reset() {
    layers.forEach {
      $0.removeFromSuperlayer()
    }

    layers.removeAll()
  }
}
