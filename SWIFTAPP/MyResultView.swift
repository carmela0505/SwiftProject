//
//  MyResultView.swift
//  TESTING
//
//  Created by apprenant130 on 19/09/2025.
//




import Foundation
import SwiftUI

struct MyResultView: View {
    @State private var showResult = false
    var correctAnswers: Int {
            bonbons.filter { $0 == "green" }.count
        }

        // Message à afficher selon le nombre de réponses correctes
        var resultMessage: String {
            
            switch correctAnswers {
            case 5:
                return "BRAVO !"
            case 3...4:
                return "TU PEUX LE FAIRE"
            case 1...2:
                return "CONTINUE À TRAVAILLER !"
            default:
                return "TU APPRENDS TOUS LES JOURS !"
            }
        }
        
    let bonbons: [String]
    
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
                ZStack{
                   
                    Image("yellow")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack {
                        
                        Text("RESULTATS")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
Divider()
                        PulsingText(
                            text: resultMessage,
                            font: .largeTitle.bold(),
                            color: .blue   // pick what looks best on your background
                        )
                        
                        Spacer()
                        
                            HStack{
                                
                            let greenIndices = bonbons.indices.filter { bonbons[$0] == "green" }
                            if !greenIndices.isEmpty {
                                    HStack(spacing: 15) {
                                        ForEach(greenIndices, id: \.self) { i in
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
                                }
                                }
                        
                        VStack{
                        Image("bear1")
                                .frame(width: 50, height: 300)
                        }
                        
                       
                        VStack{
                        Text("Est ce que vous avez aimé les questions?")
                        .font(.title3)
                        .foregroundStyle(.blue)
                                    
                                }
                                .padding()
                        
                        HStack{
                                    
                            Button("\(Image(systemName: "hand.thumbsup.fill"))"){
                                
                            }
                            Button("\(Image(systemName: "hand.thumbsdown.fill"))"){
                              
                            }
                                }
                        .padding()
                        Spacer()
                        
                               
                            }
                   
                        }
                
               
                    }
                }
#Preview{
   MyResultView(bonbons: ["green", "green", "green", "green", "green"])
}
