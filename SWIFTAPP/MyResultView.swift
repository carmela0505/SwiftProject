import SwiftUI
import Lottie

struct MyResultView: View {
    let bonbons: [String]   // "green"/"red"/"gray"
    @Environment(\.dismiss) private var dismiss
     
    var correctAnswers: Int { bonbons.filter { $0 == "green" }.count }
    var isPerfect: Bool { correctAnswers == 5 }

    // Message selon score
    var resultMessage: String {
        switch correctAnswers {
        case 5:      return "BRAVO !"
        case 3...4:  return "TU PEUX LE FAIRE"
        case 1...2:  return "CONTINUE À TRAVAILLER !"
        default:     return "TU APPRENDS TOUS LES JOURS !"
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
            
            
            // 🎉 Lottie appears only on perfect score (5/5)
                       if isPerfect {
                           LottieView(name: "bonbon", loopMode: .playOnce) // or "yesbear"
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

                PulsingText(text: resultMessage, font: .largeTitle.bold(), color: .blue)

                // 👉 Total des bonnes réponses
                Text("Bonnes réponses : \(correctAnswers)/\(bonbons.count)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)

                Spacer(minLength: 5)

                // Cadeaux pour chaque bonne réponse
                let greenIndices = bonbons.indices.filter { bonbons[$0] == "green" }
                if !greenIndices.isEmpty {
                    HStack(spacing: 15) {
                        ForEach(greenIndices, id: \.self) { _ in
                            Image(systemName: "gift.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.green)
                        }
                    }
                } else {
                    Text("Aucune réponse correcte, mais voici une étoile d'encouragement !")
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
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    MyResultView(bonbons: ["green", "green", "green", "green", "green"])
}

