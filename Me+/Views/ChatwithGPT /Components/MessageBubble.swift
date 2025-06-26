import SwiftUI

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Mesaage
    let taskKey: String
    let cleanContent: String

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.role == .assistant {
                assistantBubble
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
                userBubble
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ))
    }

    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                Image("appIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    // ✅ Replaced Text(...) with TextWithLinks to support clickable URLs
                    TextWithLinks(text: cleanContent)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)

                    Text(formatTime(message.createdAt))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }

    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .textSelection(.enabled)

                    Text(formatTime(message.createdAt))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.indigo.opacity(0.7), Color.indigo.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)

                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                    )
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
