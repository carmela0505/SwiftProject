
//
//  Map.swift
//  TESTING
//
//  Created by apprenant130 on 18/09/2025.
//

import SwiftUI

// Couleur principale du parcours / des anneaux
private let nodePrimary = Color(red: 0.05, green: 0.16, blue: 0.44) // bleu foncé

// MARK: - Modèle
struct Level: Identifiable, Hashable {
    let id: Int
    let title: String
    var isLocked: Bool
    var progress: Double // 0.0 ... 1.0
}

func makeLevels(for theme: Theme) -> [Level] {
    (1...12).map { i in
        Level(
            id: i,
            title: "Niveau \(i)",
            isLocked: i > 2,              // 1 & 2 déverrouillés pour l’exemple
            progress: i == 1 ? 1.0 : 0.0  // 1er niveau complété pour l’exemple
        )
    }
}

// MARK: - Noeud (bulle de niveau)
struct LevelNode: View {
    let level: Level
    let theme: Theme

    var body: some View {
        ZStack {
            // anneau de fond
            Circle()
                .stroke(nodePrimary.opacity(0.25), lineWidth: 10)
                .frame(width: 72, height: 72)

            // anneau de progression
            Circle()
                .trim(from: 0, to: min(max(level.progress, 0), 1))
                .stroke(nodePrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)
                .opacity(level.progress > 0 ? 1 : 0.25)

            // contenu central
            if level.isLocked {
                Image(systemName: "lock.fill")
                    .font(.title3.bold())
                    .foregroundStyle(nodePrimary)
            } else if level.progress >= 1 {
                Image(systemName: "checkmark")
                    .font(.title3.bold())
                    .foregroundStyle(nodePrimary)
            } else {
                Text("\(level.id)")
                    .font(.title3.bold())
                    .foregroundStyle(nodePrimary)
            }
        }
        .padding(6)
        .background(.white.opacity(0.10), in: Circle())
        .overlay(Circle().strokeBorder(nodePrimary.opacity(0.25), lineWidth: 1))
        .shadow(color: nodePrimary.opacity(0.25), radius: 4, x: 0, y: 2)
        .opacity(level.isLocked ? 0.7 : 1.0)
        .accessibilityLabel("\(level.title) \(level.isLocked ? "verrouillé" : "")")
    }
}

// MARK: - Chemin serpent (S-curve) lissé
struct SnakePath: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        path.move(to: points[0])

        // Courbes douces entre chaque point (contrôles à mi-hauteur)
        for i in 1..<points.count {
            let prev = points[i - 1]
            let cur  = points[i]
            let midY = (prev.y + cur.y) / 2
            path.addCurve(
                to: cur,
                control1: CGPoint(x: prev.x, y: midY),
                control2: CGPoint(x: cur.x,  y: midY)
            )
        }
        return path
    }
}

// MARK: - Carte “serpent” (dessine le chemin + place les nœuds)
struct SnakeMap: View {
    let theme: Theme
    let levels: [Level]

    // Tweaks visuels
    var sideInset: CGFloat = 90     // marge gauche/droite (augmente → plus centré)
    var spacingY: CGFloat  = 130    // espacement vertical entre nœuds
    var topPadding: CGFloat = 40    // décalage depuis le haut

    var body: some View {
        GeometryReader { geo in
            let leftX  = sideInset
            let rightX = max(sideInset, geo.size.width - sideInset)

            // Points alternés gauche/droite
            let points: [CGPoint] = levels.enumerated().map { idx, _ in
                CGPoint(x: idx.isMultiple(of: 2) ? leftX : rightX,
                        y: topPadding + CGFloat(idx) * spacingY)
            }

            ZStack(alignment: .topLeading) {
                // Chemin accentué (épais + ombre + liseré clair)
                SnakePath(points: points)
                    .stroke(
                        LinearGradient(colors: [nodePrimary, nodePrimary.opacity(0.8)],
                                       startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .shadow(color: nodePrimary.opacity(0.5), radius: 8, x: 0, y: 3)
                    .overlay(
                        SnakePath(points: points)
                            .stroke(.white.opacity(0.22),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    )

                // Nœuds positionnés sur le chemin
                ForEach(levels.indices, id: \.self) { idx in
                    let level = levels[idx]
                    let pt = points[idx]

                    Group {
                        if level.isLocked {
                            LevelNode(level: level, theme: theme)
                        } else {
                            NavigationLink {
                                LevelDetailView(theme: theme, level: level)
                            } label: {
                                LevelNode(level: level, theme: theme)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .position(pt)
                }
            }
            // Hauteur suffisante pour contenir tous les points
            .frame(
                maxWidth: .infinity,
                maxHeight: max(points.last?.y ?? 0 + 160, geo.size.height)
            )
        }
        // Hauteur minimum utile en l’absence de scroll (ex: preview)
        .frame(height: topPadding + spacingY * CGFloat(max(levels.count - 1, 0)) + 220)
    }
}

// MARK: - Écran de carte (fond + header + serpent)
struct ThemeMapView: View {
    let theme: Theme
    @State private var levels: [Level]

    init(theme: Theme) {
        self.theme = theme
        _levels = State(initialValue: makeLevels(for: theme))
    }

    var body: some View {
        ZStack {
            // fond
            Image("mapblue")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // voile coloré pour le contraste
            theme.gradient
                .opacity(0.25)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    header
                    // 👉 Remplace l'ancien “map” par la version serpent :
                    SnakeMap(theme: theme, levels: levels,
                             sideInset: 90, spacingY: 130, topPadding: 40)
                        .padding(.vertical, 8)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(theme.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: theme.symbol)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.blue)
                .padding(14)
                .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text(theme.subtitle)
                .foregroundStyle(.black.opacity(0.95))
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Détail d’un niveau (inchangé)
struct LevelDetailView: View {
    let theme: Theme
    let level: Level

    var body: some View {
        ZStack {
            theme.gradient.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(level.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Contenu du niveau pour « \(theme.title) ».\nIci: leçon, quiz, mini-jeu, etc.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Aperçus
private let previewTheme = Theme(
    id: .ecole,
    title: "À l’école",
    subtitle: "Respect, harcèlement, entraide",
    symbol: "graduationcap.fill"
)

#Preview("Map – École") {
    NavigationStack { ThemeMapView(theme: previewTheme) }
}

#Preview("Level Node – Unlocked") {
    ZStack {
        previewTheme.gradient.ignoresSafeArea()
        LevelNode(level: Level(id: 1, title: "Niveau 1", isLocked: false, progress: 0.4), theme: previewTheme)
    }
    .frame(height: 140)
}

#Preview("Level Node – Locked") {
    ZStack {
        previewTheme.gradient.ignoresSafeArea()
        LevelNode(level: Level(id: 2, title: "Niveau 2", isLocked: true, progress: 0.0), theme: previewTheme)
    }
    .frame(height: 140)
}

#Preview("Level Detail") {
    NavigationStack {
        LevelDetailView(theme: previewTheme,
                        level: Level(id: 1, title: "Niveau 1", isLocked: false, progress: 1.0))
    }
}
