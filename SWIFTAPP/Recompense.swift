//
//  RewardView.swift
//  TESTING
//

import SwiftUI
import Lottie

// MARK: - Reward tier

private enum RewardTier {
    case none, bronze, silver, gold

    // Gold = perfect score; Silver = ≥80%; Bronze = ≥60%; else none
    static func from(correct: Int, total: Int) -> RewardTier {
        guard total > 0 else { return .none }
        if correct == total { return .gold }
        let pct = Double(correct) / Double(total)
        if pct >= 0.80 { return .silver }
        if pct >= 0.60 { return .bronze }
        return .none
    }

    var symbol: String {
        switch self {
        case .gold:   return "trophy.fill"
        case .silver: return "medal.fill"
        case .bronze: return "medal.fill"
        case .none:   return "hourglass"
        }
    }

    var color: Color {
        switch self {
        case .gold:   return .yellow
        case .silver: return .gray
        case .bronze: return .brown
        case .none:   return .orange
        }
    }

    func title(correct: Int, total: Int) -> String {
        switch self {
        case .gold:   return "Trophée d’or – \(correct)/\(total) 🎉"
        case .silver: return "Médaille d’argent – \(correct)/\(total) ✨"
        case .bronze: return "Médaille de bronze – \(correct)/\(total) 🌟"
        case .none:   return correct == 0 ? "On réessaie !" : "Bravo, continue !"
        }
    }
}

// MARK: - Gift model & card

private struct Gift: Identifiable, Hashable {
    let id: String
    let name: String
    let imageName: String
}

private struct GiftCard: View {
    let gift: Gift
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(gift.imageName)               // your asset name
                .resizable()
                .scaledToFit()
                .frame(height: 54)              // keep carousel compact
                .clipped()

            Text(gift.name)
                .font(.subheadline)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
    }
}

// MARK: - View

struct RewardView: View {
    // Input from results (e.g. MyResultView)
    let bonbons: [String]   // "green" / "red" / "gray"

    // Selection state
    @State private var selectedGift: Gift? = nil
    @State private var showConfirm = false

    // Score/tier
    private var total: Int { bonbons.count }
    private var correct: Int { bonbons.filter { $0 == "green" }.count }
    private var canChooseGift: Bool { correct >= 3 }
    private var rewardTier: RewardTier {
        return RewardTier.from(correct: correct, total: total)
    }

    // Provide your gift images here (add them to Assets first)
    private let gifts: [Gift] = [
        .init(id: "teddy",  name: "Ourson",          imageName: "teddy"),
        .init(id: "camera", name: "Caméra",          imageName: "camera"),
        .init(id: "book",   name: "Livre surprise",  imageName: "gift_book"),
        .init(id: "bike",   name: "Vélo",            imageName: "gift_velo"),
        .init(id: "puzzle", name: "Puzzle",          imageName: "gift_puzzle")
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [.white, .blue.opacity(0.08)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Récompenses")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Divider()

                // Trophy/Medal card
                VStack(spacing: 5) {
                    if rewardTier == .gold {
                        // Lottie trophy for perfect score (loops)
                        LottieView(name: "trophy", loopMode: .loop)
                            .frame(height: 100)
                            .allowsHitTesting(false)
                    } else {
                        Image(systemName: rewardTier.symbol)
                            .resizable().scaledToFit()
                            .frame(height: 90)
                            .foregroundStyle(rewardTier.color)
                            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
                    }

                    Spacer(minLength: 0)

                    Text(rewardTier.title(correct: correct, total: total))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(rewardTier.color)

                    Text("Bonnes réponses : \(correct)/\(total)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(.white, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                // Gift carousel
                VStack(alignment: .center, spacing: 8) {
                    Text("Choisis ton cadeau")
                        .font(.title2)

                    if canChooseGift {
                        TabView(selection: $selectedGift) {
                            ForEach(gifts) { gift in
                                GiftCard(gift: gift, isSelected: gift.id == selectedGift?.id)
                                    .tag(Optional(gift))      // selection is Gift?
                                    .padding(.horizontal, 5)
                            }
                        }
                        .frame(height: 180)                    // adjust height as you like
                        .tabViewStyle(.page(indexDisplayMode: .automatic))

                        Button {
                            showConfirm = true
                        } label: {
                            Label("Choisir ce cadeau", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background((selectedGift == nil) ? Color.gray.opacity(0.3) : Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(selectedGift == nil)
                        .alert("Cadeau choisi", isPresented: $showConfirm) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(selectedGift != nil ? "Tu as choisi : \(selectedGift!.name) 🎁" : "")
                        }
                    } else {
                        Text("Obtiens au moins 3 bonnes réponses pour choisir un cadeau.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(12)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    // Example: all correct -> gold
    RewardView(bonbons: ["green","green","green","green","green"])
}

