//
//  AddTaskTextField.swift
//  Me+
//
//  Created by Hari's Mac on 03.06.2025.
//

import SwiftUI

struct AddTaskTextField: View {
    @Binding var text: String
    @FocusState.Binding var isTextFieldFocused: Bool
    @Binding var showChatBot: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        HStack{
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.indigo.opacity(0.7))
                    .symbolEffect(.pulse, value: isTextFieldFocused)
                
                TextField("Add Task", text: $text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .focused($isTextFieldFocused)
                    .onSubmit(onSubmit)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .strokeBorder(
                                isTextFieldFocused ?
                                Color.indigo.opacity(0.5) : Color.gray.opacity(0.2),
                                lineWidth: isTextFieldFocused ? 2 : 1
                            )
                            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                    )
            )
            .scaleEffect(isTextFieldFocused ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
            // Improved positioning for different screen sizes
            HStack{
                Button{
                    showChatBot.toggle()
                }label: {
                    ZStack{
                        Circle()
                            .fill(Color.indigo)
                            .frame(width: 40, height: 40)
                            .shadow(color: .indigo.opacity(0.8) , radius: 6, x: 0, y: 2)
                        
                        Image("appIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width:20,height: 20)
                            .font(.title)
                    }
                }
            }
        }
    }
}
