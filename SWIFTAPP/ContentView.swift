//
//  ContentView.swift
//  TESTING
//
//  Created by apprenant130 on 13/09/2025.
//

//import SwiftUI
//
//struct ContentView: View {
//    @State private var result: String = ""
//
//    func mySecondFunction() -> Int {
//        let x = 20
//        let y = 20
//        return x + y
//    }
//
//    var body: some View {
//        ZStack {
//            // Full-screen gradient background
//            LinearGradient(
//                gradient: Gradient(colors: [.blue, .red]),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                Text("Calculate the sum ")
//                    .font(.title)
//
//                // Result in a styled TextField
//                TextField("Result will appear here:", text: $result)
//                    .font(.headline)
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 10)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                    .frame(width: 300, height: 50)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(style: StrokeStyle(lineWidth: 2))
//                    )
//
//                // System-styled rectangular button (bigger)
//                Button("Calculate") {
//                    result = "\(mySecondFunction())"
//                }
//                .buttonStyle(.borderedProminent) // attach to the Button, not VStack
//                .tint(.green)
//                .font(.title2)
//                .padding(.horizontal, 40)
//                .padding(.vertical, 10)
//                .cornerRadius(10)
//                
//
//                Image(systemName: "hands.sparkles")
//                    .imageScale(.large)
//                    .foregroundStyle(.tint)
//            }
//            .padding()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
