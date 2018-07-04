//
//  Array+Extensions.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import Foundation

extension Array {
  func shuffled() -> Array {
    var array = self
    for _ in 0..<array.count {
      array.sort(by: { (_,_) in arc4random() < arc4random() })
    }

    return array
  }
}
