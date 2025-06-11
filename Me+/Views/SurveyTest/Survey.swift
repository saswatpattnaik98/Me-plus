import SwiftUI

struct Survey: View {
    @State private var currentStep = 0
    @State private var selectedInterests: Set<String> = []
    @State private var selectedHobbies: Set<String> = []
    @State private var selectedGoals: Set<String> = []
    @State private var userName = "x"
    @State private var animateContent = false
    @State private var showProgress = true
    @Environment(\.dismiss) private var dismiss
    
    let interests = ["Cooking", "Travel", "Reading", "Coding", "Fashion", "Art", "Music", "Sports"]
    let hobbies = ["Swimming", "Hiking", "Dancing", "Photography", "Gaming", "Yoga", "Writing", "Gardening"]
    let goals = ["Self-Care", "Mindfulness", "Fitness", "Learning", "Creativity", "Social", "Career", "Health"]
    let totalSteps = 4
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.1),
                        Color.pink.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Content area
                    ZStack {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            if step == currentStep {
                                stepView(for: step)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.6), value: currentStep)
                    
                    // Navigation buttons
                    navigationButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int((Double(currentStep + 1) / Double(totalSteps)) * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                .tint(Color.purple)
                .scaleEffect(y: 2)
        }
    }
    
    // MARK: - Step Views
    @ViewBuilder
    private func stepView(for step: Int) -> some View {
        switch step {
        case 0:
            welcomeStep
        case 1:
            interestsStep
        case 2:
            hobbiesStep
        case 3:
            goalsStep
        default:
            EmptyView()
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Welcome animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1 : 0.8)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    
                    Text("👋")
                        .font(.system(size: 50))
                        .scaleEffect(animateContent ? 1 : 0)
                        .animation(.bouncy.delay(0.5), value: animateContent)
                }
                
                VStack(spacing: 12) {
                    Text("Welcome!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                    
                    Text("Let's get to know you better")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                }
            }
            
            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
                    .padding(.horizontal, 4)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
            .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    private var interestsStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 12) {
                    Text("What interests you?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Select all that apply")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Options grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(Array(interests.enumerated()), id: \.offset) { index, interest in
                        optionCard(
                            title: interest,
                            isSelected: selectedInterests.contains(interest),
                            delay: Double(index) * 0.1
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedInterests.contains(interest) {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.insert(interest)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var hobbiesStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 12) {
                    Text("Your hobbies?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("What do you love doing?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Options grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(Array(hobbies.enumerated()), id: \.offset) { index, hobby in
                        optionCard(
                            title: hobby,
                            isSelected: selectedHobbies.contains(hobby),
                            delay: Double(index) * 0.1
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedHobbies.contains(hobby) {
                                    selectedHobbies.remove(hobby)
                                } else {
                                    selectedHobbies.insert(hobby)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var goalsStep: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 12) {
                    Text("Your goals?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("What would you like to focus on?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Options grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(Array(goals.enumerated()), id: \.offset) { index, goal in
                        optionCard(
                            title: goal,
                            isSelected: selectedGoals.contains(goal),
                            delay: Double(index) * 0.1
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Completion message
                if !selectedGoals.isEmpty {
                    VStack(spacing: 15) {
                        Text("🎉")
                            .font(.system(size: 40))
                        
                        Text("Perfect! You're all set!")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("We'll personalize your experience based on your preferences")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Option Card
    private func optionCard(title: String, isSelected: Bool, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundFill(isSelected: isSelected))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.clear : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.purple.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(delay), value: animateContent)
        .onAppear {
            animateContent = true
        }
    }
    
    // Helper function for background fill
    private func backgroundFill(isSelected: Bool) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).opacity(0.9)
            )
        } else {
            return AnyShapeStyle(Color.gray.opacity(0.1))
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 15) {
            // Back button
            if currentStep > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentStep -= 1
                        animateContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            animateContent = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            // Next/Finish button
            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentStep += 1
                        animateContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            animateContent = true
                        }
                    }
                } else {
                    // Finish survey
                    finishSurvey()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(currentStep == totalSteps - 1 ? "Finish" : "Next")
                        .font(.system(size: 16, weight: .semibold))
                    
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.6)
        }
    }
    
    // MARK: - Helper Properties
    private var canProceed: Bool {
        switch currentStep {
        case 0: return !userName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return !selectedInterests.isEmpty
        case 2: return !selectedHobbies.isEmpty
        case 3: return !selectedGoals.isEmpty
        default: return true
        }
    }
    
    // MARK: - Actions
    private func finishSurvey() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showProgress = false
        }
        
        // Mark onboarding as completed and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            dismiss()
        }
    }
}

#Preview {
    Survey()
}
