//
//  EspaceParent.swift
//  TESTING
//
//  Created by apprenant130 on 18/09/2025.
//

import SwiftUI

struct Accueil: View {

        var body: some View {
            ZStack {
                Image("school")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("KIDS VOICE")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
       Divider()                 .foregroundColor(.pink)
    Spacer()
                    
                    
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

    //                Image(systemName: "teddybear.fill")
    //                    .imageScale(.large)
    //                    .foregroundStyle(.tint)
                }
                .padding()
            }
    //        .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)  // hide default back

            
            .overlay(alignment: .topLeading) {
                Button {
                  
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
                .padding(.leading, 16)
                .padding(.top, 12)
                .accessibilityLabel("Retour")
            }
        }
    }

    
    
    
    
#Preview {
    Accueil()
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
