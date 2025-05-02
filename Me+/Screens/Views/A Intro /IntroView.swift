import SwiftUI

struct IntroView: View {
   @State private var goToHabitView = false
    @State private var personname: String = ""
    @State private var isAnimating = true
    var body: some View {
        ZStack {
            VStack(spacing: 12) {

                IntroAnimation()
                    .padding()

                Text("Finish To-Dos like an\nOlympian Athlete")
                    .foregroundStyle(.black)
                    .font(.system(size: 25, weight: .heavy))
                    .frame(width: 300, height: 200)
                    .padding(.top,12)

                Button("Get Started") {
                    goToHabitView = true
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 340, minHeight: 60)
                .background(.green)
                .foregroundStyle(.black)
                .fontWeight(.bold)
                .cornerRadius(12)

                FooterView
            }
            .padding(.top, 20)
        }
        .fullScreenCover(isPresented: $goToHabitView){
                HomeView()
                .ignoresSafeArea()
        }
    }

    private var FooterView: some View {
        VStack {
            HStack(spacing: 80) {
                Spacer()
                VStack {
                    Text("Keep Smiling and")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text("Stay Consistent")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Spacer()
            }
            .padding(.top, 12)
        }
    }
}


#Preview {
    IntroView()
}


