//
//  Recompense.swift
//  TESTING
//
//  Created by apprenant130 on 14/09/2025.
//

import SwiftUI
//
//struct Recompense :Identifiable {
//    var image : String
//    var condition : Int

struct RewardView: View {
    
    //    var recompenses: [recompense] = [
    //        Recompense (image:"badge1",condition :10)
    //        Recompense (image:"badge2",condition : 20)
    //        Recompese  (image:"badge3",condition :30)
    //        Recompense  (image:"badge4",condition:40)
    //    ]
    
    
    var body: some View{
        
        ZStack {
            Color.green
                .ignoresSafeArea()
            Spacer()
            VStack {
                Text ("RECOMPENSES")
                  .font(.largeTitle)
                  .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                Text("Tu as gagné  ")
                    .font(.title)
                    .foregroundColor(.white)
                Spacer()
       
            Image ("Trophy")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .frame(width: 350)
                . clipShape(Circle())
                
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack  {
                    Image("Couronne")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                    
                    Image("Fusée")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                    
                    
                    Image("Trophée")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                    
                    
                    Image("Pyramide")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                    
                    Image("Cadenas")
                        .resizable()
                        .scaledToFit()
                        .frame(width:100, height:100)
                        .padding()
                    
                    
                }
            }
        }
    }
}
        }

#Preview{
    RewardView()
}
