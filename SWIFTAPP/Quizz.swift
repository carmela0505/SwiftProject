import SwiftUI
import Foundation
import Lottie


struct QuizItem: Codable, Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let answer: String
    private enum CodingKeys: String, CodingKey { case question, options, answer }
}
struct Answer: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var isCorrect: Bool
    var selection: Bool
}
struct QuestionBlock: Identifiable {
    let id = UUID()
    var question: String
    var options: [Answer]
}
struct QuizzState {
    var questions: [QuestionBlock] = []
    
    var bonbon: [Color] = []
    var finished: Bool = false
}

private func loadQuizItems(from fileName: String, exactly count: Int = 5) -> [QuizItem] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else { return [] }
    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([QuizItem].self, from: data)
        if decoded.count >= count { return Array(decoded.shuffled().prefix(count)) }
        return decoded // fallback if file has < 5 items
    } catch {
        print("Failed to load quiz items from \(fileName).json: \(error.localizedDescription)")
        return []
    }
}
private func mapToState(_ items: [QuizItem]) -> QuizzState {
    let qs: [QuestionBlock] = items.map { item in
        QuestionBlock(
            question: item.question,
            options: item.options.map { opt in
                Answer(text: opt, isCorrect: opt == item.answer, selection: false)
            }
        )
    }
    return QuizzState(questions: qs, bonbon: Array(repeating: .gray, count: qs.count), finished: false)
}


//View
struct QuizzView: View {
    let quizFile: String
    let onFinish: (Bool) -> Void
    let background: LinearGradient
    let accent: Color
    
    
    
    // UI state
    @State private var state = QuizzState()
    @State private var currentIndex = 0
    @State private var selectedText: String? = nil
    
    // Lottie bear feedback
    @State private var showBear = false
    @State private var bearIsCorrect = false
    @State private var bearAnchorIndex: Int? = nil
    //Results
    @State private var showResults = false
    @State private var passedResult =   false
    
    // Wrong-answer popup
    @State private var showCorrectionAlert = false
    @State private var correctionText = ""
    
    // Computed
    private var answeredCurrent: Bool {
        guard let q = safeQuestion(currentIndex) else { return false }
        return q.options.contains(where: { $0.selection })
    }
    private var selectedAnswer: Answer? {
        guard let q = safeQuestion(currentIndex) else { return nil }
        return q.options.first(where: { $0.selection })
    }
    private var headerText: String {
        if let sel = selectedAnswer { return sel.isCorrect ? "Bravo !" : "Ne lâche pas!" }
        return "Quiz"
    }
    private var correctCount: Int { state.bonbon.filter { $0 == .green }.count }
    private var bonbonStrings: [String] {
        state.bonbon.map { c in
            if c == .green { return "green" }
            if c == .red   { return "red" }
            return "gray"
        }
    }
    
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()  // themed gradient background
            
            if state.questions.isEmpty {
                Text("Chargement…")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .onAppear(perform: setup)
            } else {
                VStack(spacing: 20) {
                    
                    // Header
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.92))
                            .shadow(radius: 6)
                            .frame(height: 60)
                        
                        Text(headerText)
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(accent)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: headerText)
                    }
                    .padding(.horizontal)
                    Divider()
                    // Gifts + score + bear
                    VStack(spacing: 10) {
                        HStack(spacing: 14) {
                            ForEach(state.bonbon.indices, id: \.self) { i in
                                Image(systemName: "gift.fill")
                                    .resizable().scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .foregroundColor(state.bonbon[i])
                                    .accessibilityLabel(
                                        state.bonbon[i] == .green
                                        ? "Bonne réponse"
                                        : state.bonbon[i] == .red
                                        ? "Mauvaise réponse"
                                        : "Non répondu"
                                    )
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.8), in:
                                        RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        if showBear, bearAnchorIndex == currentIndex {
                            LottieView(name: bearIsCorrect ? "yesbear" : "nobear", loopMode: .playOnce)
                                .frame(width: 120, height: 120)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .offset(y: 6)
                        }
                    }
                    
                    // Current question
                    if let q = safeQuestion(currentIndex) {
                        Text(q.question)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                        VStack(spacing: 25) {
                            ForEach(q.options) { option in
                                optionRow(option)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom controls
                    HStack(spacing: 22) {
                        if currentIndex > 0 {
                            CircleButton(icon: "chevron.left", tint: accent) {
                                goPrev()
                            }
                        }
                        
                        if !answeredCurrent {
                            Button("Valider") {
                                if let s = selectedText { validate(s) }
                            }
                            .font(.title3)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(accent)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .disabled(selectedText == nil)
                            .opacity(selectedText == nil ? 0.6 : 1.0)
                        } else if currentIndex < state.questions.count - 1 {
                            Button("Suivant") {
                                autoNextIfPossible()
                            }
                            .font(.title)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        
                        // Show "Terminer" on last question
                        if currentIndex >= max(state.questions.count - 1, 0) {
                            Button {
                                finish()
                            } label: {
                                Label("Terminer", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(.white.opacity(0.9))
                                    .foregroundColor(accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .disabled(!state.finished)
                            .opacity(state.finished ? 1 : 0.6)
                            .accessibilityHint("Terminer le quizz")
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 6)
                }
                .padding(.vertical)
            }
        }
        // Results screen
        .fullScreenCover(isPresented: $showResults, onDismiss: {
            onFinish(passedResult)
        }) {
            MyResultView(bonbons: bonbonStrings)
        }
        // Correction popup (shown AFTER the “no bear” animation on wrong answers)
        .alert("Réponse", isPresented: $showCorrectionAlert) {
            Button("OK") { autoNextIfPossible() }
        } message: {
            Text("La bonne réponse est : \(correctionText)")
               
        }
    }
 
    @ViewBuilder
    private func optionIndicator(for option: Answer) -> some View {
        if let selected = selectedAnswer {
            if option.isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if option.id == selected.id {
                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
            }
        } else if selectedText == option.text {
            Circle().fill(accent.opacity(0.55)).frame(width: 16, height: 16)
        }
    }
    
    @ViewBuilder
    private func optionRow(_ option: Answer) -> some View {
        HStack {
            Text(option.text)
                .fontWeight(.medium)
                .foregroundColor(.black)
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                optionIndicator(for: option)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture {
            if !option.selection && !answeredCurrent {
                selectedText = option.text
            }
        }
    }
    
    //  Logic
    private func setup() {
        let items = loadQuizItems(from: quizFile, exactly: 5) // change or remove `exactly:` if you want all questions
        state = mapToState(items)
        currentIndex = 0
        selectedText = nil
    }
    
    private func safeQuestion(_ idx: Int) -> QuestionBlock? {
        guard idx >= 0 && idx < state.questions.count else { return nil }
        return state.questions[idx]
    }
    
    private func validate(_ selected: String) {
        guard var q = safeQuestion(currentIndex), !answeredCurrent else { return }
        
        // mark selection
        for i in 0..<q.options.count {
            if q.options[i].text == selected {
                q.options[i].selection = true
            }
        }
        state.questions[currentIndex] = q
        
        // prepare correct text for possible popup
        let correctText = q.options.first(where: { $0.isCorrect })?.text ?? ""
        
        if let sel = q.options.first(where: { $0.selection }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                state.bonbon[currentIndex] = sel.isCorrect ? .green : .red
            }
            bearAnchorIndex = currentIndex
            bearIsCorrect = sel.isCorrect
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showBear = true
            }
            
            // after the bear animation…
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation(.easeOut) { showBear = false }
                
                if sel.isCorrect {
                    // correct -> auto next immediately
                    autoNextIfPossible()
                } else {
                    // wrong -> show popup, then go next on OK
                    correctionText = correctText
                    showCorrectionAlert = true
                }
            }
        }
        
        // finished when all answered (no gray left)
        state.finished = !state.bonbon.contains(.gray)
    }
    
    private func goPrev() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        selectedText = selectedAnswer?.text
    }
    
    private func autoNextIfPossible() {
        guard currentIndex + 1 < state.questions.count else { return }
        currentIndex += 1
        selectedText = selectedAnswer?.text
    }
    
    private func finish() {
        // “passed” only if perfect score on the set you loaded
        let passed = (correctCount == state.questions.count && state.questions.count == 5)
        passedResult = passed
        showResults = true
    }
}

//  Small round button (kept only for "Prev")
struct CircleButton: View {
    var icon: String
    var tint: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.white).frame(width: 50, height: 50)
                Image(systemName: icon).foregroundColor(tint)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    QuizzView(
        quizFile: "violence_ecole_questions",
        onFinish: { _ in },
        background: LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
        accent: .blue
    )
}
