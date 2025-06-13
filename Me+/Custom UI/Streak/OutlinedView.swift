import SwiftUI

struct OutlinedView: View {
    @Binding var value: Int
    var fontSize: CGFloat = 48
    var strokeWidth: CGFloat = 3
    
    var body: some View {
        ZStack {
            // Stroke layer
            StrokeText(
                text: "\(value)",
                width: strokeWidth,
                color: .orange,
                fontSize: fontSize
            )
            
            // Fill layer
            Text("\(value)")
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(.white)
        }
        // Add some padding to ensure the view has enough space
        .padding(4)
        // Use a fixed frame width based on the number of digits
        .frame(minWidth: getMinWidthForDigits(value: value))
    }
    
    // Calculate minimum width based on number of digits
    private func getMinWidthForDigits(value: Int) -> CGFloat {
        let digitCount = "\(value)".count
        return CGFloat(digitCount) * (fontSize * 0.6) + strokeWidth * 2
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color
    let fontSize: CGFloat
    
    var body: some View {
        ZStack {
            // Create 8 offset copies for a more uniform stroke
            ForEach(0..<8) { i in
                Text(text)
                    .font(.system(size: fontSize, weight: .black))
                    .foregroundColor(color)
                    .offset(
                        x: width * cos(Double(i) * .pi / 4),
                        y: width * sin(Double(i) * .pi / 4)
                    )
            }
            
            // Clear text in the center (for reference only)
            Text(text)
                .font(.system(size: fontSize, weight: .black))
                .foregroundColor(.clear)
        }
    }
}
#Preview {
    OutlinedView(value: .constant(12))
}
