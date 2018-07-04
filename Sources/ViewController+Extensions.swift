//
//  ViewController+Extensions.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit

extension UIViewController {
  func add(childController: UIViewController) {
    childController.willMove(toParentViewController: self)
    view.addSubview(childController.view)
    childController.didMove(toParentViewController: self)
  }
}
