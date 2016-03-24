//
//  Enumerations.swift
//
//  Created by Nikolaos Kechagias on 28/07/15.
//  Copyright © 2015 Nikolaos Kechagias. All rights reserved.
//

import SpriteKit

// States of the game
enum GameState: Int {
    case Ready, GameOver, Playing
}

// The drawing order of objects in z-axis (zPosition property)
enum zOrderValue: CGFloat {
    case Background, Wall, Block, Coin, Bird, Foreground, Hud, Message
}

// The categories of the game's object for handling of the collisions
enum ColliderCategory: UInt32 {
    case Bird = 1
    case Wall = 2
    case Coin = 4
}
