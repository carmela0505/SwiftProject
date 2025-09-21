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
    

    func handleResults(_ b: [String]) {
            resultsBonbons = b
            selected = .recompenses
        }
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
                ThemesGridView(onResults:handleResults)                 // inside a
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
            NavigationStack {RewardView(bonbons: resultsBonbons)
            }
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
            // ✅ Draw a rounded-rectangle “frame” around the system Tab Bar
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1.5)   // the visible outline
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                            .frame(height: 64)                                   // height of the frame
                            .padding(.horizontal, 10)                            // inset from screen edges
                            .padding(.bottom, 2)                                 // lift it slightly
                            .allowsHitTesting(false)
                            .ignoresSafeArea(edges: .bottom)
                            .offset(y: 10)
                        
                    }
                    
    }
}

#Preview {
    ThemesTabContainer()
}
