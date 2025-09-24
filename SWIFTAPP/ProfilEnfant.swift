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
    
    var body: some View {
        ZStack {
            Image("yellow")
                .resizable()
//                .scaledToFill()
                .ignoresSafeArea(edges: .top)
//                .frame(height: 770)
            
            VStack(spacing: 20) {
                Text("PROFIL ENFANT")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
               
               
                
                Text("Bienvenue \(prenomEnfant)")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                LottieView(name: mascotName, contentMode: .scaleAspectFit)
                    .frame(width: 400, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 7))
                    .shadow(radius: 10)
                Spacer()
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
    NavigationStack { ProfileEnfant() }
}
