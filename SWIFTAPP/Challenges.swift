import SwiftUI

// MARK: - Models

struct NewChallengeItem: Identifiable, Decodable {
    let id: Int
    let description: String
}

struct NewChallengeStatus: Identifiable {
    let id: Int
    let challenge: NewChallengeItem
    var isDone: Bool = false
    var isSkipped: Bool = false
}

class NewCompletedWeeksData: ObservableObject {
    @Published var completedWeeks: [NewCompletedWeek] = []
}

struct NewCompletedWeek: Identifiable {
    let id = UUID()
    let weekNumber: Int
    var challenges: [NewChallengeStatus]
}

// MARK: - Main View

struct NewChallengeView: View {
    @State private var rotation: Double = 0
    @State private var showChallenge: NewChallengeItem? = nil
    @State private var challenges: [NewChallengeItem] = []
    
    @State private var weekChallenges: [NewChallengeStatus] = []
    @State private var currentWeekNumber: Int = 1
    
    @StateObject private var completedData = NewCompletedWeeksData()
    @State private var navigateToResult = false
    
    // 4 slices cho bánh xe
    let sliceColors: [Color] = [
        Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1),
        Color(.sRGB, red: 0.95, green: 0.60, blue: 0.30, opacity: 1),
        Color(.sRGB, red: 0.55, green: 0.80, blue: 0.30, opacity: 1),
        Color(.sRGB, red: 0.35, green: 0.65, blue: 0.85, opacity: 1)
    ]
    
    
    
    var hasUnhandledChallenge: Bool {
        guard let first = weekChallenges.first else { return false }
        return !first.isDone && !first.isSkipped
    }
    
    var canSpin: Bool {
        weekChallenges.count < 7 && !hasUnhandledChallenge
    }
    
    var isWeekCompleted: Bool {
        weekChallenges.count == 7 && weekChallenges.allSatisfy { $0.isDone || $0.isSkipped }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(.sRGB, red: 1.0, green: 0.69, blue: 0.20, opacity: 1)
                    .ignoresSafeArea(edges:.top)
                
                VStack(spacing: 15) { // reduce spacing for compact layout
                    
                    // Wheel + Pointer
                    ZStack {
                        // 4-slice wheel
                        ForEach(0..<4) { index in
                            let startAngle = Angle(degrees: Double(index) * 360 / 4)
                            let endAngle = Angle(degrees: Double(index + 1) * 360 / 4)
                            NewPieSlice(startAngle: startAngle, endAngle: endAngle)
                                .fill(sliceColors[index])
                                .frame(width: 300, height: 300)
                        } .rotationEffect(.degrees(rotation))
                            .animation(.easeOut(duration: 2), value: rotation)
                        
                        // Pointer on top
                        NewPointerShape()
                            .fill(Color.white)
                            .frame(width: 40, height: 80)
                            .offset(y: -150)  // pointer sits on top of wheel
                            .shadow(radius: 2)
                    }
                    
                    
                    // Challenge text immediately below the wheel
                    if let challenge = showChallenge {
                        Text(challenge.description)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(width: 250)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 5)
                    }
                    
                    // Spin Button
                    if weekChallenges.count < 7 {
                        Button(action: spinWheel) {
                            Text("Tourner !")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(canSpin ? Color.blue : Color.gray)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        .disabled(!canSpin)
                        .padding(.top, 5)
                    }
                    
                    // Weekly challenge cards
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
                                        Button(action: { markChallengeDone(index: index) }) {
                                            Text("Terminé")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(weekChallenges[index].isDone ? Color.green : Color.gray)
                                                .cornerRadius(5)
                                        }
                                        .disabled(weekChallenges[index].isDone || weekChallenges[index].isSkipped)
                                        
                                        Button(action: { markChallengeSkipped(index: index) }) {
                                            Text("Passer")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(weekChallenges[index].isSkipped ? Color.red : Color.gray)
                                                .cornerRadius(5)
                                        }
                                        .disabled(weekChallenges[index].isDone || weekChallenges[index].isSkipped)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.top, 5)
                    
                    // Week result & New Challenge buttons
                    if isWeekCompleted {
                        VStack(spacing: 10) {
                            NavigationLink(
                                destination: NewWeekChallengeResult(doneCount: weekChallenges.filter { $0.isDone }.count),
                                isActive: $navigateToResult
                            ) {
                                Text("Cliquez ici pour voir le résultat")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: startNewWeek) {
                                Text("New Challenge")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                    // Completed challenges navigation
                    NavigationLink(destination: NewCompletedChallengesView(completedData: completedData)) {
                        Text("Voir toutes mes missions")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .padding(.top, 5)
                    
                    Spacer() // pushes content up, leaves room for TabView below
                }
                .padding(.top, 20) // add a bit of padding at top
            }
            .onAppear { loadChallenges() }
        }
    }
    
    
    //Load Challenges
    func loadChallenges() {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([NewChallengeItem].self, from: data)
            self.challenges = decoded
        } catch {
            print("Error loading JSON: \(error)")
        }
    }
    
    // Spin Wheel
    func spinWheel() {
        guard !challenges.isEmpty else { return }
        
        // 1. Chọn slice trước
        let randomIndex = Int.random(in: 0..<4)  // 0,1,2,3
        
        // 2. Chọn những task còn khả dụng có id % 4 == randomIndex
        let available = challenges.filter { c in
            !weekChallenges.contains(where: { $0.challenge.id == c.id }) && c.id % 4 == randomIndex
        }
        
        guard !available.isEmpty else { return }
        
        // 3. Chọn random trong các task phù hợp với slice
        let selected = available.randomElement()!
        
        // 4. Tính rotation
        let fullRotations = Double.random(in: 3...6)
        let extraRotation = Double(randomIndex) * (360/4)
        let totalRotation = fullRotations*360 + extraRotation
        
        withAnimation(.easeOut(duration: 2)) {
            rotation += totalRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showChallenge = selected
            weekChallenges.insert(NewChallengeStatus(id: selected.id, challenge: selected), at: 0)
        }
    }
    
    
    // Mark Challenge
    func markChallengeDone(index: Int) {
        guard !weekChallenges[index].isDone && !weekChallenges[index].isSkipped else { return }
        weekChallenges[index].isDone = true
        weekChallenges[index].isSkipped = false
        updateCompletedWeeks()
    }
    
    func markChallengeSkipped(index: Int) {
        guard !weekChallenges[index].isDone && !weekChallenges[index].isSkipped else { return }
        weekChallenges[index].isDone = false
        weekChallenges[index].isSkipped = true
        updateCompletedWeeks()
    }
    
    //  Update Completed Weeks
    func updateCompletedWeeks() {
        if let idx = completedData.completedWeeks.firstIndex(where: { $0.weekNumber == currentWeekNumber }) {
            completedData.completedWeeks[idx].challenges = weekChallenges.filter { $0.isDone }
        } else {
            let newWeek = NewCompletedWeek(weekNumber: currentWeekNumber, challenges: weekChallenges.filter { $0.isDone })
            completedData.completedWeeks.append(newWeek)
        }
    }
    
    //  Start New Week
    func startNewWeek() {
        weekChallenges.removeAll()
        showChallenge = nil
        rotation = 0
        currentWeekNumber += 1
    }
}

// Pie Slice & Pointer
struct NewPieSlice: Shape {
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

struct NewPointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let stemWidth = width * 0.2
        let stemHeight = height * 0.6
        path.addRect(CGRect(x: rect.midX - stemWidth/2,
                            y: rect.minY,
                            width: stemWidth,
                            height: stemHeight))
        
        path.move(to: CGPoint(x: rect.midX - width*0.4, y: stemHeight))
        path.addLine(to: CGPoint(x: rect.midX + width*0.4, y: stemHeight))
        path.addLine(to: CGPoint(x: rect.midX, y: height))
        path.closeSubpath()
        
        return path
    }
}

//Week Challenge Result

struct NewWeekChallengeResult: View {
    let doneCount: Int
    @Environment(\.dismiss) var dismiss
    
    var resultMessage: String {
        switch doneCount {
        case 0: return "Dommage, tu n’as fait aucune mission cette semaine."
        case 1: return "Vous avez accompli une mission, félicitations."
        case 2...4: return "Tu es très assidu !"
        case 5...6: return "🎁 Bravo !"
        case 7: return "🎉 Tu es trop fort !"
        default: return "Je te souhaite une bonne journée!"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text(resultMessage)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Button(action: { dismiss() }) {
                Text("Fermer")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Résultat de la semaine")
    }
}

//Completed Challenges View

struct NewCompletedChallengesView: View {
    @ObservedObject var completedData: NewCompletedWeeksData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(completedData.completedWeeks) { week in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Week \(week.weekNumber):")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        
                        if week.challenges.isEmpty {
                            Text("Quel dommage, vous n'avez accompli aucune mission cette semaine.")
                                .italic()
                                .foregroundColor(.gray)
                        } else {
                            ForEach(Array(week.challenges.enumerated()), id: \.offset) { index, item in
                                HStack {
                                    Text("\(index + 1).").bold()
                                    Text(item.challenge.description)
                                }
                            }
                        }
                    }
                    Divider()
                }
            }
            .padding()
        }
        .navigationTitle("Missions complétées")
    }
}

//

struct NewChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        NewChallengeView()
    }
}
