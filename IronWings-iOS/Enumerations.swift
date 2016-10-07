//
//  Enumerations.swift
//
//  Created by Nikolaos Kechagias on 28/07/15.
//  Copyright © 2015 Nikolaos Kechagias. All rights reserved.
//

import SpriteKit

// States of the game
enum GameState: Int {
    case ready, gameOver, playing
}

// The drawing order of objects in z-axis (zPosition property)
enum zOrderValue: CGFloat {
    case background, wall, block, coin, bird, foreground, hud, message
}

// The categories of the game's object for handling of the collisions
enum ColliderCategory: UInt32 {
    case bird = 1
    case wall = 2
    case coin = 4
}
