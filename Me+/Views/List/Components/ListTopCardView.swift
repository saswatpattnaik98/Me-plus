import SwiftUI

// Alternative version with different color scheme
struct ListTopCardView: View {
    var body: some View {
        ZStack {
            // Main card
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.black.opacity(0.9))
                .frame(width:400,height: 100)
            // Content
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    // Header text
                    Text("Read your Journal on")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    // Main title
                    Text("Quantam Mechanics")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.leading, 24)
                .padding(.vertical, 15)
                .padding(.horizontal,2)
                Spacer()
                Button {
                    let url = URL(string: "https://www.hindwi.org")
                    UIApplication.shared.open(url!)
                } label: {
                    HStack(spacing: 8) {
                        Text("Read")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 0)
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    ListTopCardView()
    
}
