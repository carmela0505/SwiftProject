//
//  TabView.swift
//  TESTING
//
//  Created by apprenant130 on 18/09/2025.
//
import SwiftUI

private enum TabTag: Int { case profil = 0, quiz = 1, challenges = 2, recompenses = 3 }

struct ThemesTabContainer: View {
    @State private var selected: TabTag = .quiz   // start on Themes

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
            NavigationStack { ChallengesView() }
                .tabItem { Label("Challenges", systemImage: "flag.checkered") }
                .tag(TabTag.challenges)

            // RÉCOMPENSES
            NavigationStack { RecompensesView() }
                .tabItem { Label("Récompenses", systemImage: "gift.fill") }
                .tag(TabTag.recompenses)
        }
    }
}

#Preview {
    ThemesTabContainer()
}
