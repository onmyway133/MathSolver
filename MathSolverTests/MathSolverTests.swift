//
//  MathSolverTests.swift
//  MathSolverTests
//
//  Created by Khoa Pham on 05.07.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import XCTest
import MathSolver

class MathSolverTests: XCTestCase {
  func testMath() {
    let math = MathService()
    XCTAssertEqual(math.solve(expression: "(1+2)*3"), 9)
    XCTAssertEqual(math.solve(expression: "2^3+10/2"), 13)
  }
}
