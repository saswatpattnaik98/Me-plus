import SwiftUI

struct StreakExpandView: View {
    @Binding var streakCount : Int
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
                    }
                    Text("\(streakCount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("day streak")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    StreakExpandView(streakCount: .constant(0))
}
