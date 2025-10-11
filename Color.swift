//
//  Color.swift
//  Serenity
//
//  Created by Avy Narra on 10/11/25.
//

import Foundation
import SwiftUI

struct SerenityTheme {
    static let top = Color(red: 0.75, green: 0.80, blue: 0.96)   // soft lavenblue
    static let bottom = Color(red: 0.83, green: 0.94, blue: 0.84) // light sage-green
    static let accent = Color(red: 0.30, green: 0.45, blue: 0.70) // muted blue
    static let cardBG = Color.white.opacity(0.92)
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.gray.opacity(0.80)
    
    static let backgroundGradient = LinearGradient(
        colors: [top, bottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
        
        // MARK: - Alternative Gradients (if you want variety)
    static let verticalGradient = LinearGradient(
        colors: [top, bottom],
        startPoint: .top,
        endPoint: .bottom
    )
}

// Extension for easy access
extension Color {
    static let serenity = SerenityTheme.self
}

extension LinearGradient {
    static let serenityBackground = SerenityTheme.backgroundGradient
    static let serenityVertical = SerenityTheme.verticalGradient
}
