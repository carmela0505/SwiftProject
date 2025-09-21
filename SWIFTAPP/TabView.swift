//
//  TabView.swift
//  TESTING
//
//  Created by apprenant130 on 18/09/2025.
//
import SwiftUI

private enum TabTag: Int { case profil, quiz , challenges, recompenses, resultats}

struct ThemesTabContainer: View {
    @State private var selected: TabTag = .quiz   // start on Themes
    @State private var resultsBonbons: [String] = Array(repeating: "gray", count: 5)
    
    var body: some View {
        TabView(selection: $selected) {
            // PROFIL
            NavigationStack {
                ProfileEnfant(prenomEnfant: "Léa")
                    .navigationTitle("Profil")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Profil", systemImage: "person.crop.circle") }
            .tag(TabTag.profil)

            // QUIZ (Themes)
            NavigationStack {
                ThemesGridView()                 // 👈 inside a NavigationStack
                    .navigationTitle("Thèmes")
            }
            .tabItem { Label("Quiz", systemImage: "questionmark.circle") }
            .tag(TabTag.quiz)

            // CHALLENGES
            NavigationStack { MyChallengeView()
                    .navigationTitle("Challenges")
                    .navigationBarTitleDisplayMode( .inline)
            }
                .tabItem { Label("Challenges", systemImage: "flag.checkered") }
                .tag(TabTag.challenges)

            // RÉCOMPENSES
            NavigationStack {RewardView() }
                .tabItem { Label("Récompenses", systemImage: "gift.fill") }
                .tag(TabTag.recompenses)
            // RÉSULTATS (MyResultView avec Tab bar)
          NavigationStack {MyResultView(bonbons: resultsBonbons)
                               .navigationTitle("Résultats")
                               .navigationBarTitleDisplayMode(.inline)
                       }
                       .tabItem { Label("Résultats", systemImage: "checkmark.seal.fill") }
                       .tag(TabTag.resultats)
        }
    }
}

#Preview {
    ThemesTabContainer()
}
