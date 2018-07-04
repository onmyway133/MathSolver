//
//  OCRService.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import SwiftOCR
import TesseractOCR

protocol OCRServiceDelegate: class {
  func ocrService(_ service: OCRService, didDetect text: String)
}

final class OCRService {
  private let instance = SwiftOCR()
  private let tesseract = G8Tesseract(language: "eng")!

  weak var delegate: OCRServiceDelegate?

  init() {
    tesseract.engineMode = .tesseractCubeCombined
    tesseract.pageSegmentationMode = .singleBlock
  }

  func handle(image: UIImage) {
    handleWithTesseract(image: image)
  }

  private func handleWithSwiftOCR(image: UIImage) {
    instance.recognize(image, { string in
      DispatchQueue.main.async {
        self.delegate?.ocrService(self, didDetect: string)
      }
    })
  }

  private func handleWithTesseract(image: UIImage) {
    tesseract.image = image.g8_blackAndWhite()
    tesseract.recognize()
    let text = tesseract.recognizedText ?? ""
    delegate?.ocrService(self, didDetect: text)
  }
}
