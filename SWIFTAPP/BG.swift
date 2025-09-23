//
//  BGimage.swift
//  TESTING
//
//  Created by apprenant130 on 13/09/2025.
//


import SwiftUI

struct BackgroundColorAttribute: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("yellow")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("KIDS VOICE")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                Spacer()

                LottieView(name: "dancingbear", contentMode: .scaleAspectFit)
                    .frame(width: 400, height: 400)

                Spacer()

                NavigationLink {
                    ThemesTabContainer()
                } label: {
                    Text("JOUER")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(radius: 6)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)

        // On cache le bouton système…
        .navigationBarBackButtonHidden(true)

        // bouton "natif"
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                }
                .tint(.blue)                 // adopte la couleur du thème (noir/blanc auto)
                .accessibilityLabel("Retour")
            }
        }
    }
}

#Preview {
    NavigationStack {
        BackgroundColorAttribute()
    }
}
