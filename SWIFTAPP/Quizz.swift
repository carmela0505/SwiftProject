//
//  Quizz.swift
//  TESTING
//
//  Created by apprenant130 on 19/09/2025.
//

import SwiftUI
import Foundation
import Lottie

struct QuizItem: Codable, Identifiable {
    // On garde un id local (non codé/décodé)
    let id = UUID()
    let question: String
    let options: [String]
    let answer: String
    private enum CodingKeys: String, CodingKey { case question, options, answer }
}

//UI
struct Answer: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var isCorrect: Bool
    var bonbon: Bool
    var selection: Bool
}

struct Questions: Identifiable {
    let id = UUID()
    var question: String
    var options: [Answer]
}

struct Quizz {
    var color: Color
    var questions: [Questions]
    var terminer: Bool
    var bonbon: [Color]            // on stocke directement des Color
}


func loadQuizItems(from fileName: String) -> [QuizItem] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("❌ Could not find file \(fileName).json")
        return []
    }
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([QuizItem].self, from: data)
    } catch {
        print("❌ Failed to decode JSON:", error)
        return []
    }
}

func getRandomQuizItems(from items: [QuizItem], count: Int = 5) -> [QuizItem] {
    guard count > 0 else { return [] }
    return Array(items.shuffled().prefix(count))
}


struct QuizzView: View {
    @State private var showBear = false
    @State private var bearIsCorrect = false
    @State private var bearAnchorIndex: Int? = nil
    @State private var quizz = Quizz(
        color: Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1),
        questions: [],
        terminer: false,
        bonbon: []
    )
    @State private var currentIndex = 0
    @State private var selectedOption: String? = nil
    @State private var showResults = false
    
    private var bonbonStrings: [String] {
            quizz.questions.map { q in
                if let sel = q.options.first(where: { $0.selection }) {
                    return sel.isCorrect ? "green" : "red"
                } else {
                    return "gray"
                }
            }
        }
    private func finishIfReady() {
          showResults = true
      }

    
    var body: some View {
        ZStack {
            quizz.color.ignoresSafeArea()
            
            if quizz.questions.isEmpty {
                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.title)
                    .onAppear(perform: setupData)
            } else {
                VStack(spacing: 20) {
                    
                    // Header
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(height: 120)
                            .shadow(radius: 5)
                        
                        Text(headerText)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(quizz.color)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .fullScreenCover(isPresented: $showResults) {
                                MyResultView(bonbons: bonbonStrings)
                            }
                    
                    
                    .padding(.horizontal)
                    
                    // Gifts / Bonbon
                    VStack(spacing: 8) {
                        HStack(spacing: 15) {
                            ForEach(quizz.bonbon.indices, id: \.self) { i in
                                Image(systemName: "gift.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(giftColor(for: i))
                                    .accessibilityLabel(
                                        Text(giftColor(for: i) == .green ? "Bonne réponse" :
                                             giftColor(for: i) == .red   ? "Mauvaise réponse" : "Non répondu")
                                    )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)

                        // Ours juste en dessous de la rangée
                        if showBear, bearAnchorIndex == currentIndex {
                            LottieView(name: bearIsCorrect ? "yesbear" : "nobear", loopMode: .playOnce)
                                .frame(width: 120, height: 120)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .offset(y: 6)
                        }
                    }
                    
                    // Question (safe index)
                    if currentIndex < quizz.questions.count {
                        Text(quizz.questions[currentIndex].question)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Options
                        VStack(spacing: 15) {
                            ForEach(quizz.questions[currentIndex].options) { option in
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
                                .cornerRadius(20)
                                .onTapGesture {
                                    if !option.selection && !answeredCurrent {
                                        selectedOption = option.text
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Buttons
                    HStack(spacing: 30) {
                        if currentIndex > 0 {
                            Button(action: goPrev) {
                                CircleButton(icon: "chevron.left")
                            }
                        }
                        
                        if !answeredCurrent {
                            Button("Valider") {
                                if let selected = selectedOption {
                                    validateAnswer(selected)
                                }
                            }
                            .font(.headline)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .disabled(selectedOption == nil)
                            .opacity(selectedOption == nil ? 0.7 : 1)
                        }
                        
                        if currentIndex < max(quizz.questions.count - 1, 0) {
                            Button(action: goNext) {
                                CircleButton(icon: "chevron.right")
                            }
                        } else {
                            Button(action: { showResults = true }) {
                                CircleButton(icon: "checkmark")
                            }
                            .disabled(!quizz.terminer)
                            .opacity(quizz.terminer ? 1 : 0.6)
                            .accessibilityHint(Text("Ouvrir les résultats"))
                        }
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding(.vertical)
                .fullScreenCover(isPresented: $showResults) {
                    AnswersView(quizz: quizz, onReset: resetQuiz, onBack: { showResults = false })
                }
            }
        }
    }
    
    private var answeredCurrent: Bool {
        guard currentIndex < quizz.questions.count else { return false }
        return quizz.questions[currentIndex].options.contains(where: { $0.selection })
    }
    
    private var selectedAnswer: Answer? {
        guard currentIndex < quizz.questions.count else { return nil }
        return quizz.questions[currentIndex].options.first(where: { $0.selection })
    }
    
    private var headerText: String {
        if let selected = selectedAnswer {
            return selected.isCorrect ? "Bravo" : "Oh non ! Ne lâche pas !"
        } else {
            return "Quizz"
        }
    }
    
    private func giftColor(for index: Int) -> Color {
        guard index < quizz.questions.count else { return .gray }
        if let selected = quizz.questions[index].options.first(where: { $0.selection }) {
            return selected.isCorrect ? .green : .red
        }
        return .gray
    }
    
   
    @ViewBuilder
    private func optionIndicator(for option: Answer) -> some View {
        if let selected = selectedAnswer {
            if option.isCorrect {
                Image(systemName: "checkmark").foregroundColor(.green)
            } else if option.id == selected.id {
                Image(systemName: "xmark").foregroundColor(.red)
            }
        } else if selectedOption == option.text {
            Circle().fill(Color.green.opacity(0.6)).frame(width: 16, height: 16)
        }
    }
    

    private func setupData() {
        let allItems = loadQuizItems(from: "violence_autres_enfants")
        // Fallback si le JSON est vide/absent : on injecte 5 questions factices
        let source: [QuizItem] = allItems.isEmpty
        ? (0..<5).map { i in
            QuizItem(question: "Question \(i+1) ?", options: ["A", "B", "C", "D"], answer: "A")
        }
        : getRandomQuizItems(from: allItems, count: 5)
        
        let mappedQuestions = source.map { item in
            Questions(
                question: item.question,
                options: item.options.map {
                    Answer(text: $0, isCorrect: $0 == item.answer, bonbon: false, selection: false)
                }
            )
        }
        
        quizz = Quizz(
            color: Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1),
            questions: mappedQuestions,
            terminer: false,
            bonbon: Array(repeating: .gray, count: mappedQuestions.count)
        )
        currentIndex = 0
        selectedOption = nil
    }
    
    private func validateAnswer(_ selected: String) {
        guard !answeredCurrent, currentIndex < quizz.questions.count else { return }

        // Marque l'option sélectionnée
        for i in 0..<quizz.questions[currentIndex].options.count {
            if quizz.questions[currentIndex].options[i].text == selected {
                quizz.questions[currentIndex].options[i].selection = true
            }
        }

        if let sel = quizz.questions[currentIndex].options.first(where: { $0.selection }) {
            // 1) mettre à jour le cadeau
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                quizz.bonbon[currentIndex] = sel.isCorrect ? .green : .red
            }

            // 2) déclencher l’ours
            bearAnchorIndex = currentIndex
            bearIsCorrect = sel.isCorrect
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showBear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut) { showBear = false }
            }
        }

        quizz.terminer = !quizz.bonbon.contains(.gray)
    }

    
    private func resetQuiz() {
        guard !quizz.questions.isEmpty else { return }
        for i in 0..<quizz.questions.count {
            for j in 0..<quizz.questions[i].options.count {
                quizz.questions[i].options[j].selection = false
            }
        }
        quizz.bonbon = Array(repeating: .gray, count: quizz.questions.count)
        quizz.terminer = false
        currentIndex = 0
        selectedOption = nil
        showResults = false
    }
    
    private func goPrev() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        selectedOption = selectedAnswer?.text
    }
    
    private func goNext() {
        guard currentIndex + 1 < quizz.questions.count else { return }
        currentIndex += 1
        selectedOption = selectedAnswer?.text
    }
}


struct CircleButton: View {
    var icon: String
    var body: some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 50, height: 50)
            Image(systemName: icon).foregroundColor(Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1))
        }
    }
}

struct AnswersView: View {
    let quizz: Quizz
    let onReset: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    // Bonbon
                    HStack(spacing: 15) {
                        ForEach(quizz.bonbon.indices, id: \.self) { i in
                            Image(systemName: "gift.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(quizz.bonbon[i])
                        }
                    }
                    .padding()
                    
                    // Rappel questions non répondues
                    let remaining = quizz.bonbon.filter { $0 == .gray }.count
                    if remaining > 0 {
                        Text("Il vous reste \(remaining) questions sans réponse.")
                            .foregroundColor(.red)
                            .padding(.bottom, 4)
                            .accessibilityLabel(Text("Questions sans réponse: \(remaining)"))
                    }
                    
                    // Détail Q/R
                    ForEach(quizz.questions.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Q\(i+1): \(quizz.questions[i].question)")
                                .font(.headline)
                            
                            if let ans = quizz.questions[i].options.first(where: { $0.selection }) {
                                Text("Réponse: \(ans.text)")
                                    .foregroundColor(ans.isCorrect ? .green : .red)
                            } else {
                                Text("Pas de réponse").foregroundColor(.gray)
                            }
                            
                            Text("Correct: \(quizz.questions[i].options.first(where: { $0.isCorrect })?.text ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 6)
                    }
                    
                    // Boutons
                    HStack(spacing: 20) {
                        Button(action: onReset) { CircleButton(icon: "arrow.clockwise") }
                        
                        if quizz.terminer {
                            Button("Recevoir la récompense") {}
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        } else {
                            Button("Non Termine") { onBack() }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        Button("Back") { onBack() }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Résultats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    QuizzView()
}
