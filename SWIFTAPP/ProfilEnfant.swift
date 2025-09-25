//
//  ProfilEnfant.swift
//  TESTING
//
//  Created by apprenant130 on 17/09/2025.
//
import SwiftUI

struct ProfileEnfant: View {
    @AppStorage("prenomEnfant") private var prenomEnfant: String = ""
    @State private var mascotName: String = "shiba"
    private let choices = ["raccoon","donkey","cat","shiba"]
    
    @Environment(\.dismiss) private var dismiss   // ⬅️ pour gérer le retour
    @Binding var selectedTab: TabTag
    
    var body: some View {
        ZStack {
            Image("yellow")
                .resizable()
                .ignoresSafeArea(edges: .top)
                .padding(.bottom, 10)

            VStack(spacing: 12) {
                Text("PROFIL ENFANT")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Bienvenue \(prenomEnfant)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                LottieView(name: mascotName, contentMode: .scaleAspectFit)
                    .frame(width: 400, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 7))
                    .shadow(radius: 8)
                    .padding(.top, 4)
                    .padding(.bottom, 6)
                
              
                // Mascot chooser
                Menu {
                    ForEach(choices, id: \.self) { option in
                        Button(option) { mascotName = option }
                    }
                } label: {
                    HStack {
                   Image(systemName: "person")
                        Text("Changer de mascotte")
                    }
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .frame(width: 280, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(radius: 3)
                }
                .controlSize(.regular)  //slightly smaller than large
                
                //Suivant
                NavigationLink {
                    BackgroundColorAttribute(selectedTab: $selectedTab)
                } label: {
                    Text("SUIVANT")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(radius: 4)
                }
                
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                
                NavigationLink(destination: ProfilParentFormView(selectedTab: $selectedTab)) {
                    Label("Profil parent", systemImage: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileEnfant(selectedTab: .constant(.challenges)) }
}
