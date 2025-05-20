//
//  ContentView.swift
//  Me+
//
//  Created by Hari's Mac on 02.05.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack(){
         HomeView()
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
