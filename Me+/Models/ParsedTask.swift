//
//  ParsedTask.swift
//  Me+
//
//  Created by Hari's Mac on 17.06.2025.
//

import SwiftUI

// MARK: - Parsed Task Model
struct ParsedTask: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int
    let suggestedDate: Date
    let originalLine: String
}
