import SwiftUI

struct StreakExpandView: View {
    @Binding var streakCount : Int
   @State var text : String = "day streak"
    var body: some View {
        NavigationStack{
            ZStack{
                if streakCount != 0{
                    LinearGradient(colors: [.orange,.white], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
                VStack{
                    if streakCount != 0{
                        Image("flame")
                            .resizable()
                            .frame(width: 200,height: 200)
                            .scaledToFit()
                    }else{
                        Image("flamedull")
                            .resizable()
                            .frame(width: 200,height: 200)
                            .scaledToFit()
                            .overlay(
                                Circle() // White border circle
                                    .stroke(Color.white, lineWidth: 2) // White border with thickness
                            )
                    }
                  OutlinedView(value: $streakCount)
                    
                    
                Text("day streak")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(.orange)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    StreakExpandView(streakCount: .constant(1))
}
