//
//  ProfilEnfant.swift
//  TESTING
//
//  Created by apprenant130 on 17/09/2025.
//
import SwiftUI

struct ProfileEnfant: View {
    let prenomEnfant: String
   @State private var mascotName: String = "shiba"
    private let choices = ["raccoon","donkey","cat","shiba"]

    var body: some View {
        ZStack {
            Image("yellow")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("PROFIL ENFANT")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Divider()
                Spacer()

                Text("Bienvenue \(prenomEnfant)")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)

                LottieView(name: mascotName, contentMode: .scaleAspectFill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
                    .shadow(radius: 10)
Spacer()
                // Mascot chooser
                Menu {
                    ForEach(choices, id: \.self) { option in
                        Button(option) { mascotName = option }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                        Text("Changer de mascotte")
                    }
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .frame(width: 300, height: 56)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 4)
                }
                .controlSize(.large)

              
                NavigationLink {
                    BackgroundColorAttribute()
                } label: {
                    Text("SUIVANT")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 6)
                }

                
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack { ProfileEnfant(prenomEnfant: "Léa") }
}
