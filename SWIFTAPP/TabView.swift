//
//  TabView.swift
//  TESTING
//
//  Created by apprenant130 on 18/09/2025.
//
import SwiftUI

enum TabTag: Int { case profil, quiz , challenges, recompenses, resultats}

struct ThemesTabContainer: View {
    @State private var selected: TabTag = .profil   // start on Themes
    @State private var resultsBonbons: [String] = []
    
    @AppStorage("prenomEnfant") private var prenomEnfant: String = "Léa"
    // optional “auto replay” flag the Quiz screen can observe
    @AppStorage("shouldReplayQuiz") private var shouldReplayQuiz: Bool = false
    
    func handleResults(_ b: [String]) {
        resultsBonbons = b
        selected = .recompenses
    }
    
    
    
    var body: some View {
        TabView(selection: $selected) {
            
            // PROFIL
            NavigationStack {
                ProfileEnfant(selectedTab: $selected)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Profil", systemImage: "person.crop.circle") }
            .tag(TabTag.profil)
            
            // QUIZ (Themes)
            NavigationStack {
                ThemesGridView(onResults: handleResults, seletecTab: $selected)
                    .navigationTitle("")
                // Optionally let the quiz screen auto-start if we set the flag
                    .onAppear {
                        if shouldReplayQuiz {
                            shouldReplayQuiz = false
                            // Tell your Themes/Quiz to launch immediately if you support it
                            // e.g. NotificationCenter, environment, or direct binding
                        }
                    }
            }
            .tabItem { Label("Quiz", systemImage: "questionmark.circle") }
            .tag(TabTag.quiz)
            
            // RÉCOMPENSES
            NavigationStack {
                RewardView(
                    bonbons: resultsBonbons,
                    onRejouer: {
                        shouldReplayQuiz = true
                        selected = .quiz
                        
                    }
                )
            }
            .tabItem { Label("Récompenses", systemImage: "gift.fill") }
            .tag(TabTag.recompenses)
            
            // RÉSULTATS (MyResultView avec Tab bar)
            NavigationStack {
                MyResultView(bonbons: resultsBonbons)
            }
            .tabItem { Label("Résultats", systemImage: "checkmark.seal.fill") }
            .tag(TabTag.resultats)
            
            
            // CHALLENGES
            NavigationStack {
                Challenge2View()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Challenges", systemImage: "flag.checkered") }
            .tag(TabTag.challenges)
        }
        // your tab bar overlay keeps working as-is
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.12), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                .frame(height: 54)
                .padding(.horizontal, 10)
                .padding(.bottom, 2)
                .allowsHitTesting(false)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: 10)
        }
    }
}

#Preview {
    ThemesTabContainer()
}
