//
//  MusicService.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import Foundation
import AVFoundation

final class MusicService {

  private let player = AVPlayer()
  private var isPlaying = false

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerDidFinishPlaying),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: player.currentItem
    )
  }

  @objc private func playerDidFinishPlaying() {
    isPlaying = false
  }

  func handle(text: String) {
    if let number = parseNumber(text: text) {
      print("detected \(number)")
      handle(number: number)
    }
  }

  private func handle(number: Int) {
    switch number {
    case ..<0:
      play(fileName: "1")
      break
    case ..<1_000:
      play(fileName: "3")
      break
    case ..<10_000:
      play(fileName: "2")
      break
    case ..<1_000_000:
      let fileName = ["4", "5", "6", "7"].shuffled().first!
      play(fileName: fileName)
    case ..<1_000_000_000:
      let fileName = ["8", "9", "10", "11"].shuffled().first!
      play(fileName: fileName)
    case ..<Int.max:
      play(fileName: "end")
    default:
      break
    }
  }

  func play(fileName: String) {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
      return
    }

    guard !isPlaying else {
      return
    }

    isPlaying = true

    let item = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: item)
    player.play()
  }

  private func parseNumber(text: String) -> Int? {
    let acceptedLetters = Array(0...9).map(String.init) + ["-"]

    let characters = text
      .replacingOccurrences(of: "\n", with: "")
      .replacingOccurrences(of: "o", with: "0")
      .filter({ acceptedLetters.contains(String($0)) })

    return Int(String(characters))
  }
}
