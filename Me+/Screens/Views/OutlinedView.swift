import SwiftUI

struct OutlinedView: View {
    @Binding var value: Int
    
    var body: some View {
        ZStack {
            // Outline layer
            Text("\(value)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.clear)
                .overlay(
                    Text("\(value)")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.orange)
                        .opacity(2)
                        .background(
                            StrokeText(text: "\(value)", width: 3, color: .orange)
                        )
                )

            // Fill layer
            Text("\(value)")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ZStack {
                Text(text).offset(x: width, y: 0)
                Text(text).offset(x: -width, y: 0)
                Text(text).offset(x: 0, y: width)
                Text(text).offset(x: -2, y: -width)
            }
            .foregroundColor(color)
            
            Text(text).foregroundColor(.clear)
        }
        .font(.system(size: 48, weight: .black))
    }
}

#Preview {
    OutlinedView(value: .constant(3))
}
