//
//  Thematique.swift
//  TESTING
//
//  Created by apprenant130 on 16/09/2025.
//
import SwiftUI


enum ThemeID: String, CaseIterable, Identifiable, Hashable {
    case ecole, maison, net, differents
    var id: String { rawValue }
}

struct Theme: Identifiable, Hashable {
        
    let id: ThemeID
    let title: String
    let subtitle: String
    let symbol: String

    // Computed gradient (not stored) so Theme stays Hashable
    var gradient: LinearGradient {
        switch id {
        case .ecole:
            return LinearGradient(colors: [Color.blue, Color.cyan],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .maison:
            return LinearGradient(colors: [Color.green, Color.teal],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .net:
            return LinearGradient(colors: [Color.purple, Color.indigo],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .differents:
            return LinearGradient(colors: [Color.orange, Color.pink],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// The 4 themes you wanted
let themes: [Theme] = [
    .init(id: .ecole,      title: "À l’école",        subtitle: "Respect, harcèlement, entraide", symbol: "graduationcap.fill"),
    .init(id: .maison,     title: "À la maison",      subtitle: "Famille, émotions, règles",      symbol: "house.fill"),
    .init(id: .net,        title: "Sur le net",       subtitle: "Sécurité, écrans, réseaux",      symbol: "globe"),
    .init(id: .differents, title: "Tous différents",  subtitle: "Diversité, inclusion, amitié",    symbol: "person.3.fill")
]



struct ThemeCard: View {
    let theme: Theme


    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(radius: 6, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: theme.symbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(10)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(theme.title).font(.headline).foregroundStyle(.white)
                Text(theme.subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.85))
            }
            .padding(16)
        }
        .frame(height: 150)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(theme.title), \(theme.subtitle)")
    }
}
struct ThemeDetailView: View {
    let theme: Theme

    var body: some View {
        ZStack {
            theme.gradient.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: theme.symbol)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                Text(theme.title).font(.largeTitle.bold()).foregroundStyle(.white)
                Text(theme.subtitle).font(.title3).foregroundStyle(.white.opacity(0.9))
                Text("Ici, tu peux afficher le contenu du thème « \(theme.title) » (quiz, activités, conseils, etc.).")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(theme.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}



struct ThemesGridView: View {
    
    
//    @AppStorage("shouldReplayQuiz") private var shouldReplayQuiz = false
//    @AppStorage("lastQuizFile")     private var lastQuizFile = "violence_ecole_questions"

      
    
    var onResults: (([String]) -> Void)? = nil
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
    
    @Binding var seletecTab: TabTag

    var body: some View {
        ZStack {
            Color.orange.opacity(0.80).ignoresSafeArea(edges: .top)

            ScrollView {
                // Header card (your teddy banner)
                ZStack {
                    Rectangle()
                        .fill(Color.purple.opacity(0.80))
                        .frame(width: 300, height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.30), lineWidth: 10)
                        )
                        .cornerRadius(20)

                    Text("Thématiques")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)

                    Image("bear1")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(20))
                        .offset(x: 120, y: -60)
                }
                .padding(.top, 12)
Divider()
                // Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(themes) { theme in
                        NavigationLink {
                            ThemeMapView(theme:theme,onResults:onResults) 
                        } label: {
                            ThemeCard(theme: theme)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
//        .navigationTitle("")
//        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}

struct ChallengesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.blue)
            Text("Défis à venir").font(.title2.weight(.semibold))
            Text("Ajoute ici la liste des challenges, niveaux, et progrès.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Challenges")
    }
}

struct RecompensesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift.fill")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.pink)
            Text("Récompenses").font(.title2.weight(.semibold))
            Text("Badges, points, cadeaux — tout ce qui motive les enfants !")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
//        .navigationTitle("Récompenses")
    }
}



//#Preview("Detail") {
//    ThemeDetailView(theme: themes.first!)
//}

#Preview("Grid") {
    NavigationStack { ThemesGridView(seletecTab: .constant(.challenges)) }
}

#Preview("TabView") {
    NavigationStack { ThemesTabContainer() }
}
