//
//  MathService.swift
//  MathSolver
//
//  Created by Khoa Pham on 04.07.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import Foundation

protocol MathServiceDelegate: class {
  func mathService(_ service: MathService, didSolve result: Int)
}

class MathService {

  weak var delegate: MathServiceDelegate?

  func solve(equation: String) {
    
  }
}
