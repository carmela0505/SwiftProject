//
//  Challenges.swift
//  TESTING
//
//  Created by apprenant130 on 19/09/2025.
//
import SwiftUI


struct ChallengeItem: Identifiable, Decodable {
    let id: Int
    let description: String
}

struct ChallengeStatus: Identifiable {
    let id: Int
    let challenge: ChallengeItem
    var isDone: Bool = false
    var isSkipped: Bool = false
}


struct MyChallengeView: View {
    @State private var rotation: Double = 0
    @State private var showChallenge: ChallengeItem? = nil
    @State private var challenges: [ChallengeItem] = []
    @State private var weekChallenges: [ChallengeStatus] = []
    
    @State private var showRewardPopup = false
    @State private var showIncompleteAlert = false
    
    // 7 slice colors
    let sliceColors: [Color] = [
        Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1),
        Color(.sRGB, red: 0.95, green: 0.60, blue: 0.30, opacity: 1),
        Color(.sRGB, red: 0.55, green: 0.80, blue: 0.30, opacity: 1),
        Color(.sRGB, red: 0.35, green: 0.65, blue: 0.85, opacity: 1),
        Color(.sRGB, red: 0.80, green: 0.40, blue: 0.70, opacity: 1),
        Color(.sRGB, red: 0.90, green: 0.75, blue: 0.25, opacity: 1),
        Color(.sRGB, red: 0.50, green: 0.60, blue: 0.90, opacity: 1)
    ]
    
    var body: some View {
        ZStack {
            Color(.sRGB, red: 1.0, green: 0.69, blue: 0.20, opacity: 1)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
            
                ZStack {
                    ForEach(0..<7) { index in
                        let startAngle = Angle(degrees: Double(index) * (360 / 7))
                        let endAngle = Angle(degrees: Double(index + 1) * (360 / 7))
                        PieSlice(startAngle: startAngle, endAngle: endAngle)
                            .fill(sliceColors[index])
                            .frame(width: 300, height: 300)
                    }
                }
                .rotationEffect(.degrees(rotation))
                .animation(.easeOut(duration: 2), value: rotation)
                
                // Fixed pointer
                PointerShape()
                    .fill(Color.white)
                    .frame(width: 40, height: 80)
                    .offset(y: -350)
                    .shadow(radius: 2)
                
                // Spin button
                Button(action: spinWheel) {
                    Text("Tourner !")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(.sRGB, red: 55/255, green: 119/255, blue: 211/255, opacity: 1))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                
                // Show current spun challenge
                if let challenge = showChallenge {
                    Text(challenge.description)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
          
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(weekChallenges.indices, id: \.self) { index in
                            VStack(spacing: 10) {
                                Text(weekChallenges[index].challenge.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(width: 140, height: 80)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .multilineTextAlignment(.center)
                                
                                HStack {
                                    Button(action: {
                                        weekChallenges[index].isDone = true
                                        weekChallenges[index].isSkipped = false
                                    }) {
                                        Text("Terminé")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(weekChallenges[index].isDone ? Color.green : Color.gray)
                                            .cornerRadius(5)
                                    }
                                    
                                    Button(action: {
                                        weekChallenges[index].isSkipped = true
                                        weekChallenges[index].isDone = false
                                    }) {
                                        Text("Passer")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(weekChallenges[index].isSkipped ? Color.red : Color.gray)
                                            .cornerRadius(5)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
          
                VStack(spacing: 10) {
                    // Reset button luôn hiển thị
                    Button(action: resetWeek) {
                        Text("Réinitialiser la semaine")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    
                    let allHandled = weekChallenges.count == 7 && weekChallenges.allSatisfy { $0.isDone || $0.isSkipped }
                    
                    if allHandled {
                        Button(action: {
                            let completedCount = weekChallenges.filter { $0.isDone }.count
                            if completedCount >= 3 {
                                showRewardPopup = true
                            } else {
                                showIncompleteAlert = true
                            }
                        }) {
                            Text("Cliquez ici pour voir le résultat")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadChallenges()
        }
        .alert(isPresented: $showIncompleteAlert) {
            Alert(title: Text("Attention"),
                  message: Text("Faites plus de missions !"),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showRewardPopup) {
            VStack(spacing: 20) {
                Text(" Bravo !")
                    .font(.largeTitle)
                    .bold()
                Text("Vous avez terminé au moins 3 missions.")
                    .font(.title3)
                Button(action: { showRewardPopup = false }) {
                    Text("Fermer")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    
    func loadChallenges() {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ChallengeItem].self, from: data)
            self.challenges = decoded
        } catch {
            print("Erreur lors du chargement du JSON: \(error)")
        }
    }
    
    func spinWheel() {
        // Check that there are available challenges
        guard !challenges.isEmpty else { return }
        
        // Create a list of challenges that have not been used yet
        let availableChallenges = challenges.filter { c in
            !weekChallenges.contains(where: { $0.challenge.id == c.id })
        }
        
        // If all challenges have already been used, do nothing
        guard !availableChallenges.isEmpty else { return }
        
        // Randomly select a challenge from the available ones
        let selected = availableChallenges.randomElement()!
        
        // Determine a random segment on the wheel (0 to 6)
        let randomIndex = Int.random(in: 0..<7)
        let fullRotations = Double.random(in: 3...6) // Number of full turns
        let extraRotation = Double(randomIndex) * (360/7)
        let totalRotation = fullRotations*360 + extraRotation
        
        // Animate the wheel
        withAnimation(.easeOut(duration: 2)) {
            rotation += totalRotation
        }
        
        // After the animation, show the selected challenge
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showChallenge = selected
            
            // Add the challenge to the start of the week's list (stack)
            weekChallenges.insert(ChallengeStatus(id: selected.id, challenge: selected), at: 0)
        }
    }

    
    func resetWeek() {
        weekChallenges.removeAll()
        showChallenge = nil
        rotation = 0
    }
}


struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center,
                    radius: rect.width/2,
                    startAngle: startAngle - Angle(degrees: 90),
                    endAngle: endAngle - Angle(degrees: 90),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

// Pointer Shape

struct PointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Stem
        let stemWidth = width * 0.2
        let stemHeight = height * 0.6
        path.addRect(CGRect(x: rect.midX - stemWidth/2,
                            y: rect.minY,
                            width: stemWidth,
                            height: stemHeight))
        
        // Arrow head
        path.move(to: CGPoint(x: rect.midX - width*0.4, y: stemHeight))
        path.addLine(to: CGPoint(x: rect.midX + width*0.4, y: stemHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: height))
        path.closeSubpath()
        
        return path
    }
}


struct MyChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        MyChallengeView()
    }
}


