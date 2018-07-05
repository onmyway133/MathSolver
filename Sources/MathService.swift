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

  public func infix2postfix(expression: String) -> String {
    return (expression as NSString).infixToPostfix(withOutputDecimalSeparator: "")
  }

  public func solve(expression: String) -> Double {
    let validatedExpression = validate(expression: expression)
    return (validatedExpression as NSString).evaluateInfixNotationString()
  }

  public func validate(expression: String) -> String {
    let set = Set("0123456789()+-*/")
    return expression
      .replacingOccurrences(of: "/n", with: "")
      .filter({ set.contains($0) })
  }
}
