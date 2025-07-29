//
//  Course.swift
//  GolfWithYourEnemies
//
//  Created by Adam Míka on 29.07.2025.
//

import CoreGraphics
import Foundation

struct Course {
//    var id = UUID()
    /// Outer green size
    var size: CGSize
    /// Ball spawn (scene coordinates, usually left side)
    var ballStart: CGPoint
    /// Hole position
    var cupPosition: CGPoint
    /// Corner radius for the green
    var corner: CGFloat = 16
}
