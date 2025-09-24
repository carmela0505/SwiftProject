//
// Challenge2View.swift
// KidVoice
//
// Created by Apprenant 134 on 23/09/2025.
//

import SwiftUI

//Models

struct Challenge2Item: Identifiable, Decodable {
    let id: Int
    let description: String
}

struct Challenge2Status: Identifiable {
    let id: Int
    let challenge: Challenge2Item
    var isDone: Bool = false
    var isSkipped: Bool = false
}

class CompletedChallengesData2: ObservableObject {
    @Published var completedChallenges: [Challenge2Status] = []
}

// Main View

struct Challenge2View: View {
    @State private var rotation: Double = 0
    @State private var currentChallenge: Challenge2Item? = nil
    @State private var challenges: [Challenge2Item] = []
    @StateObject private var completedData = CompletedChallengesData2()
    
    // 4 slices for the wheel
    let sliceColors: [Color] = [
        Color(.sRGB, red: 55/255, green: 119/255, blue: 211/255, opacity: 1), // #3777D3
        Color(.sRGB, red: 229/255, green: 83/255, blue: 124/255, opacity: 1), // #E5537C
        Color(.sRGB, red: 141/255, green: 213/255, blue: 79/255, opacity: 1), // #8DD54F
        Color(.sRGB, red: 255/255, green: 177/255, blue: 52/255, opacity: 1)  // #FFB134
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("yellow")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("CHALLENGES")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Wheel + pointer
                    ZStack() {
                        ForEach(0..<4) { index in
                            let startAngle = Angle(degrees: Double(index) * 360 / 4)
                            let endAngle = Angle(degrees: Double(index + 1) * 360 / 4)
                            
                            NewPieSlice2(startAngle: startAngle, endAngle: endAngle)
                                .fill(sliceColors[index])
                                .frame(width: 300, height: 300)
                        }
                        .rotationEffect(.degrees(rotation))
                        .animation(.easeOut(duration: 2), value: rotation)
                        
                        // Pointer
                        NewPointerShape2()
                            .fill(Color.white)
                            .frame(width: 40, height: 80)
                            .offset(y: -150)
                            .shadow(radius: 2)
                    }
                    
                    // Challenge card (single)
                    if let challenge = currentChallenge {
                        Text(challenge.description)
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .padding()

                        
                        HStack() {
                            
                            Button(action: markDone) {
                                Text("Terminé")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                                    
                            }
                            
                            Button(action: markSkipped) {
                                Text("Passer")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    HStack{
                        // Spin button
                        Button(action: spinWheel) {
                            Text("Tourner !")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(currentChallenge == nil ? Color.blue : Color.gray)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .disabled(currentChallenge != nil)
                        
                        // Completed challenges navigation
                        NavigationLink(destination: CompletedChallengesView2(completedData: completedData)) {
                            Text("Mes missions")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 130, height: 40)
                                .background(Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1))
                                .cornerRadius(10)
                        }
                        
                        
                    }
                }
//
            }
            .onAppear { loadChallenges() }
        }
    }
    
    // Load Challenges
    func loadChallenges() {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Challenge2Item].self, from: data)
            self.challenges = decoded
        } catch {
            print("Error loading JSON: \(error)")
        }
    }
    
    // Spin Wheel
    func spinWheel() {
        guard !challenges.isEmpty else { return }
        let randomIndex = Int.random(in: 0..<4)
        let available = challenges.filter { c in
            !completedData.completedChallenges.contains(where: { $0.challenge.id == c.id }) &&
            c.id % 4 == randomIndex
        }
        guard let selected = available.randomElement() else { return }
        
        let fullRotations = Double.random(in: 3...6)
        let extraRotation = Double(randomIndex) * (360 / 4)
        let totalRotation = fullRotations * 360 + extraRotation
        
        withAnimation(.easeOut(duration: 2)) {
            rotation += totalRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            currentChallenge = selected
        }
    }
    
    // Mark Done/Skipped
    func markDone() {
        guard let challenge = currentChallenge else { return }
        let status = Challenge2Status(id: challenge.id, challenge: challenge, isDone: true)
        completedData.completedChallenges.append(status)
        currentChallenge = nil
    }
    
    func markSkipped() {
        guard let challenge = currentChallenge else { return }
        let status = Challenge2Status(id: challenge.id, challenge: challenge, isDone: false, isSkipped: true)
        completedData.completedChallenges.append(status)
        currentChallenge = nil
    }
}

// Completed Challenges View

struct CompletedChallengesView2: View {
    @ObservedObject var completedData: CompletedChallengesData2
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(Array(completedData.completedChallenges.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text("\(index + 1).").bold()
                        Text(item.challenge.description)
                        if item.isDone {
                            Text("✅").padding(.leading, 5)
                        } else if item.isSkipped {
                            Text("❌").padding(.leading, 5)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Missions complétées")
    }
}

// Pie Slice & Pointer

struct NewPieSlice2: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width/2,
                    startAngle: startAngle - Angle(degrees: 90),
                    endAngle: endAngle - Angle(degrees: 90),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct NewPointerShape2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let stemWidth = width * 0.2
        let stemHeight = height * 0.6
        
        path.addRect(CGRect(x: rect.midX - stemWidth/2, y: rect.minY,
                            width: stemWidth, height: stemHeight))
        
        path.move(to: CGPoint(x: rect.midX - width*0.4, y: stemHeight))
        path.addLine(to: CGPoint(x: rect.midX + width*0.4, y: stemHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: height))
        path.closeSubpath()
        
        return path
    }
}

// Preview

struct Challenge2View_Previews: PreviewProvider {
    static var previews: some View {
        Challenge2View()
    }
}
 
