//
//  PlaceholderView.swift
//  Me+
//
//  Created by Hari's Mac on 23.05.2025.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        // Placeholder when no task added ...
        VStack(spacing: 12) {
            Image("noHabits") // Make sure "noHabits" exists in Assets
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .opacity(0.8)
            
            Text("Top athletes follow 'Top Heaviness'")
                .font(.system(size: 15))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text("1.⁠ ⁠More on Mon, Tue, Wed\n2.⁠ ⁠More in morning than evening\n3.⁠ ⁠⁠Definitely set time for rest")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding()
    }
}

#Preview {
    PlaceholderView()
}
