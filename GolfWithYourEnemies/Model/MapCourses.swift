//
//  MapCourses.swift
//  GolfWithYourEnemies
//
//  Created by Adam Míka on 29.07.2025.
//

import CoreGraphics

/// All the playable courses bundled with the app.
enum MapCourses {
    /// A simple rectangular fairway.
    static let easy = Course(
        size:        .init(width: 800,  height: 500),
        ballStart:   .init(x: -300, y:   0),
        cupPosition: .init(x:  300, y:   0))

    /// Big L-shaped hole that needs a bank shot.
    static let lShape = Course(
        size:        .init(width: 1200, height: 800),
        ballStart:   .init(x: -500, y:  200),
        cupPosition: .init(x:  400, y: -250))
}

/// Convenience array for menu listings.
let allCourses: [(name: String, course: Course)] = [
    ("Easy Rect", MapCourses.easy),
    ("L-Shape",   MapCourses.lShape)
]
