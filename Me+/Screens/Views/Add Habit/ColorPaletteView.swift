import SwiftUI

struct ColorPaletteView: View {
    @Binding var selectedColor: Color
    var body: some View {
        HStack(spacing: 20) {
            // Light Peach
            Color(red: 1.0, green: 0.8, blue: 0.7)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle() // White border circle
                        .stroke(Color.white, lineWidth: 2)
                )
                .overlay(
                    Group {
                        if selectedColor == Color(red: 1.0, green: 0.8, blue: 0.7) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black) // Tick color
                                .font(.title2) // Tick font size
                        }
                    }
                )
                .onTapGesture {
                    selectedColor = Color(red: 1.0, green: 0.8, blue: 0.7)
                }
            
            // Light Pink
            Color(red: 1.0, green: 0.8, blue: 0.9) // Light pink
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle() // White border circle
                        .stroke(Color.white, lineWidth: 2) // White border with thickness
                )
                .overlay(
                    Group {
                        if selectedColor == Color(red: 1.0, green: 0.8, blue: 0.9) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black) // Tick color
                                .font(.title2) // Tick font size
                        }
                    }
                )
                .onTapGesture {
                    selectedColor = Color(red: 1.0, green: 0.8, blue: 0.9)
                }
            
            // Soft Lavender
            Color(red: 0.8, green: 0.7, blue: 1.0) // Soft lavender
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle() // White border circle
                        .stroke(Color.white, lineWidth: 2) // White border with thickness
                )
                .overlay(
                    Group {
                        if selectedColor == Color(red: 0.8, green: 0.7, blue: 1.0) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black) // Tick color
                                .font(.title2) // Tick font size
                        }
                    }
                )
                .onTapGesture {
                    selectedColor = Color(red: 0.8, green: 0.7, blue: 1.0)
                }
            
            // Soft Coral
            Color(red: 1.0, green: 0.6, blue: 0.6) // Soft coral
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle() // White border circle
                        .stroke(Color.white, lineWidth: 2) // White border with thickness
                )
                .overlay(
                    Group {
                        if selectedColor == Color(red: 1.0, green: 0.6, blue: 0.6) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black) // Tick color
                                .font(.title2) // Tick font size
                        }
                    }
                )
                .onTapGesture {
                    selectedColor = Color(red: 1.0, green: 0.6, blue: 0.6)
                }
            // Separate one
            Color(red: 1.1, green: 0.5, blue: 0.3) // Soft coral
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle() // White border circle
                        .stroke(Color.white, lineWidth: 2) // White border with thickness
                )
                .overlay(
                    Group {
                        if selectedColor == Color(red: 1.1, green: 0.5, blue: 0.3) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black) // Tick color
                                .font(.title2) // Tick font size
                        }
                    }
                )
                .onTapGesture {
                    selectedColor = Color(red: 1.1, green: 0.5, blue: 0.3)
                }
        }.padding(3)
    }
}

#Preview {
    ColorPaletteView(selectedColor: .constant(.green.opacity(0.4)))
}

