import SwiftUI

//Model
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
            isLocked: i > 1,   // only level 1 unlocked initially
            progress: 0.0
        )
    }
}

// Quiz config per theme
private struct QuizAppearance {
    let file: String
    let background: LinearGradient
    let accent: Color
}

private func quizConfig(for theme: Theme) -> QuizAppearance {
    switch theme.id {
    case .ecole:
        return .init(
            file: "violence_ecole_questions",
            background: LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
            accent: .blue
        )
    case .maison:
        return .init(
            file: "violence_domestique_enfants",
            background: LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
            accent: .green
        )
    case .net:
        return .init(
            file: "violence_reseaux_sociaux_enfants",
            background: LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
            accent: .purple
        )
    case .differents:
        return .init(
            file: "violence_autres_enfants",
            background: LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing),
            accent: .orange
        )
    }
}

//  Node bubble
struct LevelNode: View {
    let level: Level
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.25), lineWidth: 10)
                .frame(width: 72, height: 72)

            Circle()
                .trim(from: 0, to: min(max(level.progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)
                .opacity(level.progress > 0 ? 1 : 0.25)

            if level.isLocked {
                Image(systemName: "lock.fill")
                    .font(.title3.bold())
                    .foregroundStyle(tint)
            } else if level.progress >= 1 {
                Image(systemName: "checkmark")
                    .font(.title3.bold())
                    .foregroundStyle(tint)
            } else {
                Text("\(level.id)")
                    .font(.title3.bold())
                    .foregroundStyle(tint)
            }
        }
        .padding(6)
        .background(.white.opacity(0.10), in: Circle())
        .overlay(Circle().strokeBorder(tint.opacity(0.25), lineWidth: 1))
        .shadow(color: tint.opacity(0.25), radius: 4, x: 0, y: 2)
        .opacity(level.isLocked ? 0.7 : 1.0)
        .accessibilityLabel("\(level.title) \(level.isLocked ? "verrouillé" : "")")
    }
}

// Smooth snake path
struct SnakePath: Shape {
    let points: [CGPoint]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        path.move(to: points[0])
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

// Snake map (draw path + place nodes) — tap opens quiz
struct SnakeMap: View {
    let tint: Color
    @Binding var levels: [Level]
    @Binding var activeLevel: Level?

    var sideInset: CGFloat = 90
    var spacingY: CGFloat  = 130
    var topPadding: CGFloat = 40

    var body: some View {
        GeometryReader { geo in
            let leftX  = sideInset
            let rightX = max(sideInset, geo.size.width - sideInset)
            let points: [CGPoint] = levels.enumerated().map { idx, _ in
                CGPoint(x: idx.isMultiple(of: 2) ? leftX : rightX,
                        y: topPadding + CGFloat(idx) * spacingY)
            }

            ZStack(alignment: .topLeading) {
                SnakePath(points: points)
                    .stroke(
                        LinearGradient(colors: [tint, tint.opacity(0.85)],
                                       startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .shadow(color: tint.opacity(0.55), radius: 10, x: 0, y: 2)
                    .overlay(
                        SnakePath(points: points)
                            .stroke(.white.opacity(0.25),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    )

                ForEach(levels.indices, id: \.self) { idx in
                    let level = levels[idx]
                    let pt = points[idx]

                    Group {
                        if level.isLocked {
                            LevelNode(level: level, tint: tint)
                        } else {
                            Button {
                                activeLevel = level
                            } label: {
                                LevelNode(level: level, tint: tint)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .position(pt)
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: max(points.last?.y ?? 0 + 160, geo.size.height)
            )
        }
        .frame(height: topPadding + spacingY * CGFloat(max(levels.count - 1, 0)) + 220)
    }
}

// Screen hosting the snake map + quiz sheet
struct ThemeMapView: View {
    let theme: Theme
    @State private var levels: [Level]
    @State private var activeLevel: Level? = nil
    var onResults: (([String]) -> Void)? = nil

    init(theme: Theme, onResults: (([String]) -> Void)? = nil) {   // 👈 accept it here
           self.theme = theme
           self.onResults = onResults
           _levels = State(initialValue: makeLevels(for: theme))
       }
    var body: some View {
        let cfg = quizConfig(for: theme)

        ZStack {
            Image("mapblue").resizable().scaledToFill().ignoresSafeArea()
            theme.gradient.opacity(0.25).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    header
                    SnakeMap(tint: cfg.accent,
                             levels: $levels,
                             activeLevel: $activeLevel,
                             sideInset: 90, spacingY: 130, topPadding: 40)
                        .padding(.vertical, 8)
                }
                .padding(.vertical, 16)
            }
        }
//        .navigationTitle(theme.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeLevel) { level in
            let cfg = quizConfig(for: theme)
            
            // Present the QUIZ only when a level is selected
            QuizzView(
                quizFile: cfg.file,
                onFinish: { passed in
                    if passed, let idx = levels.firstIndex(where: { $0.id == level.id }) {
                        levels[idx].progress = 1.0
                        if idx + 1 < levels.count {
                            levels[idx + 1].isLocked = false
                        }
                    }
                    activeLevel = nil // dismiss
                },
                onResults: onResults,
                background: cfg.background,
                accent: cfg.accent
            )
        }
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

//  Preview
private let previewTheme = Theme(
    id: .ecole,
    title: "À l’école",
    subtitle: "Respect, harcèlement, entraide",
    symbol: "graduationcap.fill"
)

#Preview("Map – École") {
    NavigationStack { ThemeMapView(theme: previewTheme) }
}

