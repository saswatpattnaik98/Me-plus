//
//  CelebrationParticle.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import Foundation
import SwiftUI

struct CelebrationParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let velocity: CGPoint
    let color: Color
    let size: CGFloat
}

