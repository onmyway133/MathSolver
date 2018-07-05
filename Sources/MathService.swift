//
//  MathService.swift
//  MathSolver
//
//  Created by Khoa Pham on 04.07.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import Foundation

public class MathService {
  public init() {}

  public func solve(expression: String) -> Double {
    return (expression as NSString).evaluateInfixNotationString()
  }
}
