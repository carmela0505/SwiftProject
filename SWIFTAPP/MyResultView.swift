import SwiftUI
import Lottie

struct MyResultView: View {
    let bonbons: [String]                 // "green"/"red"/"gray"
    var onReplay: (() -> Void)? = nil     // optional actions
    var onFinish: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    private var total: Int { bonbons.count }
    private var correctAnswers: Int { bonbons.filter { $0 == "green" }.count }
    private var isPerfect: Bool { total > 0 && correctAnswers == total }

    private var resultMessage: String {
        switch correctAnswers {
        case 5:      return "BRAVO!"                    // you can keep this mapping if you like
        case 3...4:  return "TU PEUX LE FAIRE"
        case 1...2:  return "CONTINUE À TRAVAILLER !"
        default:     return "ON REPART POUR UN TOUR?"
        }
    }

    struct PulsingText: View {
        let text: String
        var font: Font = .largeTitle.bold()
        var color: Color = .white
        @State private var pulse = false

        var body: some View {
            Text(text)
                .font(font)
                .foregroundStyle(color)
                .scaleEffect(pulse ? 1.08 : 1.0)
                .opacity(pulse ? 1 : 0.9)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }
        }
    }

    var body: some View {
        ZStack {
            Image("yellow")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // 🎉 Lottie only if all answers are correct (perfect score of any length)
            if isPerfect {
                LottieView(name: "bonbon", loopMode: .playOnce)
                    .frame(width: 240, height: 240)
                    .allowsHitTesting(false)
                    .offset(y: -120)
                    .transition(.scale.combined(with: .opacity))
            }

            VStack(spacing: 16) {
                Text("RÉSULTATS")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 8)

                Divider()

                // Message animé
                PulsingText(text: resultMessage, font: .largeTitle.bold(), color: .blue)

                //  Toujours visible : total des bonnes réponses
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Bonnes réponses : \(correctAnswers)/\(total)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.blue)
                }
                .padding(.top, 2)

                Spacer(minLength: 5)

                // Cadeaux (tous les résultats, verts/rouges/gris)
                if total > 0 {
                    HStack(spacing: 15) {
                        ForEach(bonbons.indices, id: \.self) { i in
                            Image(systemName: "gift.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(color(for: bonbons[i]))
                                .accessibilityLabel(label(for: bonbons[i]))
                        }
                    }
                } else {
                    Text("Aucune réponse, mais voici une étoile d'encouragement !")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .font(.headline)
                        .padding(.horizontal)
                }

                Image("bear1")
                    .frame(width: 50, height: 300)

                Text("Est-ce que tu as aimé les questions ?")
                    .font(.title3)
                    .foregroundStyle(.blue)

                HStack(spacing: 18) {
                    Button("\(Image(systemName: "hand.thumbsup.fill"))") { }
                    Button("\(Image(systemName: "hand.thumbsdown.fill"))") { }
                }

                // Actions
                HStack(spacing: 14) {
//                    Button("Rejouer") {
//                        if let onReplay { onReplay() } else { dismiss() }
//                    }
//                    .font(.headline)
//                    .padding(.horizontal, 24)
//                    .padding(.vertical, 12)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button("Terminer") {
                        if let onFinish { onFinish() } else { dismiss() }
                    }
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
        }
    }

    //  Helpers
    private func color(for status: String) -> Color {
        switch status {
        case "green": return .green
        case "red":   return .red
        default:      return .gray.opacity(0.6)
        }
    }
    private func label(for status: String) -> Text {
        switch status {
        case "green": return Text("Bonne réponse")
        case "red":   return Text("Mauvaise réponse")
        default:      return Text("Non répondu")
        }
    }
}
//- MyResultView with tabs

struct MyResultTabView: View {
    let bonbons: [String]
    var onReplay: (() -> Void)? = nil
    var onFinish: (() -> Void)? = nil

    var body: some View {
        TabView {
            // Résultats tab
            NavigationStack {
                MyResultView(
                    bonbons: bonbons,
                    onReplay: onReplay,
                    onFinish: onFinish
                )
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Résultats", systemImage: "checkmark.seal.fill") }

            // Récompenses tab (optional)
            NavigationStack {
                RewardView(bonbons: bonbons)
                    .navigationTitle("Récompenses")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Récompenses", systemImage: "gift.fill") }
        }
    }
}

#Preview {
    MyResultTabView(
        bonbons: ["green","green","green","red","green"],
        onReplay: {},
        onFinish: {}
    )
}


