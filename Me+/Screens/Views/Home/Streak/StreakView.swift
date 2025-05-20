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
                            .frame(width: 100,height: 100)
                            .scaledToFit()
                    }else{
                        Image("flamedull")
                            .resizable()
                            .frame(width: 100,height: 100)
                            .scaledToFit()
                    }
                  OutlinedView(value: $streakCount)
                    
                    
                Text("day streak")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(.orange)
                    Spacer(minLength: 40)
                    
                    StreakCalendarView()
                }
                
            }
        }
    }
}

#Preview {
    StreakExpandView(streakCount: .constant(6))
}
