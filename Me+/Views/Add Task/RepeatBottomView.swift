

import SwiftUI

struct RepeatBottomSelect: View {
    @State private var repeatTYPE = ""
    // this is the variable which i should bind with addnew habit
    @Binding var selectedRepeat: RepeatOption
    @Binding  var endDate: Date
    @State private var goToCustomRepeat = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                ForEach(RepeatOption.allCases) { option in
                    HStack {
                        Text(option.rawValue)
                            .font(.headline)
                            .padding()
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRepeat = option
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $goToCustomRepeat){
                RepeatCustomView(endDate: endDate)
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    RepeatBottomSelect(selectedRepeat: .constant(.None),endDate: .constant(Date()))
}

