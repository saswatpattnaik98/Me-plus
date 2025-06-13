import SwiftUI
import SwiftData

struct DynamicCardContent {
    let headerText: String
    let mainTitle: String
    let backgroundColor: Color
    let accentColor: Color
    let imageName: String
    let buttonText: String
    let url: String
}

struct ListTopCardView: View {
    @State private var currentContentIndex = 0
    @State private var isPressed = false
    @Environment(\.modelContext) var modelContext
    @Query var activities: [Activity]
    
    private let contentOptions: [DynamicCardContent] = [
        DynamicCardContent(
            headerText: "Read you favorite books of",
            mainTitle: "Hindi Fiction",
            backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.2),
            accentColor: Color(red: 0.4, green: 0.3, blue: 0.8),
            imageName: "book",
            buttonText: "Read",
            url: "https://www.hindwi.org"
        ),
        DynamicCardContent(
            headerText: "Dive into modern",
            mainTitle: "Biotechnology",
            backgroundColor: Color(red: 0.05, green: 0.2, blue: 0.15),
            accentColor: Color(red: 0.2, green: 0.7, blue: 0.4),
            imageName: "leaf.fill",
            buttonText: "Learn",
            url: "https://www.cell.com/trends/biotechnology/newarticles"
        ),
        DynamicCardContent(
            headerText: "Understanding",
            mainTitle: "Machine Learning",
            backgroundColor: Color(red: 0.2, green: 0.08, blue: 0.15),
            accentColor: Color(red: 0.9, green: 0.3, blue: 0.6),
            imageName: "brain.head.profile",
            buttonText: "Study",
            url: "https://www.nature.com/subjects/machine-learning"
        )
    ]
    
    var currentContent: DynamicCardContent {
        contentOptions[currentContentIndex]
    }
    
    var body: some View {
        Button(action: {
            let url = URL(string: currentContent.url)
            UIApplication.shared.open(url!)
            let today = Calendar.current.startOfDay(for: Date())
            if !activities.contains(where: {$0.name == currentContent.mainTitle && Calendar.current.isDate($0.date, inSameDayAs: today)
            }){
                let newactivity = Activity(name: currentContent.mainTitle, date: today, duration: 0)
                modelContext.insert(newactivity)
                try? modelContext.save()
            }
            
        }) {
            HStack(spacing: 0) {
                // Left content area
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentContent.headerText)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    Text(currentContent.mainTitle)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                .padding(.vertical, 18)
                
                // Right section with icon and button
                HStack(spacing: 16) {
                    // Icon with subtle glow
                    ZStack {
                        Circle()
                            .fill(currentContent.accentColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .blur(radius: 8)
                        
                        Image(systemName: currentContent.imageName)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(currentContent.accentColor)
                    }
                    
                    // Clean button
                    HStack(spacing: 8) {
                        Text(currentContent.buttonText)
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
                }
                .padding(.trailing, 20)
                .padding(.vertical, 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            currentContent.backgroundColor,
                            currentContent.backgroundColor.opacity(0.8),
                            Color.black.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(currentContent.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(width: 370,height: 100)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .onAppear {
            selectRandomContent()
        }
    }
    
    private func selectRandomContent() {
        currentContentIndex = Int.random(in: 0..<contentOptions.count)
    }
}

#Preview {
    ListTopCardView()
}
