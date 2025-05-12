
import SwiftUI

struct TaskView: View {
    var image : String
    var text : String
    var colour : Color
    var body: some View {
        HStack{
            Image("\(image)")
                .resizable()
                .frame(width: 30, height: 30)
                .scaledToFit()
            Text("\(text)")
                .font(.system(size: 14))
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(20)
        .frame(width: 350, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colour)
        )
    }
}

#Preview {
    TaskView(image: "image", text: "text", colour: .secondary)
}

