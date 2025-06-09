
import SwiftUI
import SwiftData

struct ActivityRowView: View {
    let activity: Activity
    let index: Int
    let isPressed: Bool
    let isAnimatingCompletion: Bool
    let isNewTask: Bool
    let onTap: () -> Void
    let onComplete: () -> Void
    @Binding var selectedDate: Date
    let onDeleteSingle: () -> Void
    let Today: Date = Calendar.current.startOfDay(for: Date())
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        HStack {
            ActivityIconView(activity: activity, isNewTask: isNewTask)
            
            VStack(alignment: .leading) {
                ActivityStatusView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
                ActivityNameView(activity: activity, isAnimatingCompletion: isAnimatingCompletion)
            }
            
            Spacer()
            
            CompletionButtonView(
                activity: activity,
                isAnimatingCompletion: isAnimatingCompletion,
                onComplete: onComplete,selectedDate: $selectedDate
            )
        }
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 15))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(activity.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isNewTask ? 0.3 : 0),
                                    Color.white.opacity(isNewTask ? 0.1 : 0),
                                    Color.white.opacity(isNewTask ? 0.3 : 0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .foregroundColor(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .onTapGesture {
            if selectedDate >= Calendar.current.startOfDay(for: Date()) {
                onTap()
            }else {
                withAnimation{
                    let newActivity = Activity(name: activity.name, date: Today, duration: 0,movedFromPast: true)
                    modelContext.insert(newActivity)
                    onDeleteSingle()
                    try? modelContext.save()
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
}

