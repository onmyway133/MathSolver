//
//  Result.swift
//  MathSolver
//
//  Created by Khoa Pham on 04.07.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import Foundation

enum Result<T> {
  case value(value: T)
  case failure(error: Error)

  // Sync
  public func map<U>(f: (T) -> U) -> Result<U> {
    switch self {
    case let .value(value):
      return .value(value: f(value))
    case let .failure(error):
      return .failure(error: error)
    }
  }

  // Async
  public func flatMap<U>(f: @escaping ((T), (U) -> Void) -> Void) -> (((Result<U>) -> Void) -> Void) {
    return { g in   // g: Result<U> -> Void
      switch self {
      case let .value(value):
        f(value) { transformedValue in  // transformedValue: U
          g(.value(value: transformedValue))
        }
      case let .failure(error):
        g(.failure(error: error))
      }
    }
  }
}
