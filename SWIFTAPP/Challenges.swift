import SwiftUI

// MARK: - Models

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

class CompletedWeeksData: ObservableObject {
    @Published var completedWeeks: [CompletedWeek] = []
}

struct CompletedWeek: Identifiable {
    let id = UUID()
    let weekNumber: Int
    var challenges: [ChallengeStatus]
}

// MARK: - Main View

struct MyChallengeView: View {
    @State private var rotation: Double = 0
    @State private var showChallenge: ChallengeItem? = nil
    @State private var challenges: [ChallengeItem] = []

    @State private var weekChallenges: [ChallengeStatus] = []
    @State private var currentWeekNumber: Int = 1

    @StateObject private var completedData = CompletedWeeksData()
    @State private var navigateToResult = false

    let sliceColors: [Color] = [
        Color(.sRGB, red: 0.90, green: 0.33, blue: 0.49, opacity: 1),
        Color(.sRGB, red: 0.95, green: 0.60, blue: 0.30, opacity: 1),
        Color(.sRGB, red: 0.55, green: 0.80, blue: 0.30, opacity: 1),
        Color(.sRGB, red: 0.35, green: 0.65, blue: 0.85, opacity: 1),
        Color(.sRGB, red: 0.80, green: 0.40, blue: 0.70, opacity: 1),
        Color(.sRGB, red: 0.90, green: 0.75, blue: 0.25, opacity: 1),
        Color(.sRGB, red: 0.50, green: 0.60, blue: 0.90, opacity: 1)
    ]

    // MARK: - Computed Properties

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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.sRGB, red: 1.0, green: 0.69, blue: 0.20, opacity: 1)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Wheel
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

                    PointerShape()
                        .fill(Color.white)
                        .frame(width: 40, height: 80)
                        .offset(y: -350)
                        .shadow(radius: 2)

                    // Spin button
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
                    }

                    // Current challenge
                    if let challenge = showChallenge {
                        Text(challenge.description)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // Weekly stack
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
                                            markChallengeDone(index: index)
                                        }) {
                                            Text("Terminé")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(weekChallenges[index].isDone ? Color.green : Color.gray)
                                                .cornerRadius(5)
                                        }
                                        .disabled(weekChallenges[index].isDone || weekChallenges[index].isSkipped)

                                        Button(action: {
                                            markChallengeSkipped(index: index)
                                        }) {
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

                    // Weekly result & New Challenge buttons
                    if isWeekCompleted {
                        VStack(spacing: 10) {
                            NavigationLink(
                                destination: WeekChallengeResult(doneCount: weekChallenges.filter { $0.isDone }.count),
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
                    }

                    // Completed challenges navigation
                    NavigationLink(destination: CompletedChallengesView(completedData: completedData)) {
                        Text("Voir toutes mes missions")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical)
            }
            .onAppear { loadChallenges() }
        }
    }

    // MARK: - Load Challenges

    func loadChallenges() {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ChallengeItem].self, from: data)
            self.challenges = decoded
        } catch {
            print("Error loading JSON: \(error)")
        }
    }

    // MARK: - Spin Wheel

    func spinWheel() {
        guard !challenges.isEmpty else { return }
        let available = challenges.filter { c in
            !weekChallenges.contains(where: { $0.challenge.id == c.id })
        }
        guard !available.isEmpty else { return }

        let selected = available.randomElement()!
        let randomIndex = Int.random(in: 0..<7)
        let fullRotations = Double.random(in: 3...6)
        let extraRotation = Double(randomIndex) * (360/7)
        let totalRotation = fullRotations*360 + extraRotation

        withAnimation(.easeOut(duration: 2)) {
            rotation += totalRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showChallenge = selected
            weekChallenges.insert(ChallengeStatus(id: selected.id, challenge: selected), at: 0)
        }
    }

    // MARK: - Mark Challenge

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

    // MARK: - Update Completed Weeks

    func updateCompletedWeeks() {
        if let idx = completedData.completedWeeks.firstIndex(where: { $0.weekNumber == currentWeekNumber }) {
            completedData.completedWeeks[idx].challenges = weekChallenges.filter { $0.isDone }
        } else {
            let newWeek = CompletedWeek(weekNumber: currentWeekNumber, challenges: weekChallenges.filter { $0.isDone })
            completedData.completedWeeks.append(newWeek)
        }
    }

    // MARK: - Show Week Result

    func showWeekResult() {
        navigateToResult = true
    }

    // MARK: - Start New Week

    func startNewWeek() {
        weekChallenges.removeAll()
        showChallenge = nil
        rotation = 0
        currentWeekNumber += 1
    }
}

// MARK: - Week Challenge Result

struct WeekChallengeResult: View {
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

// MARK: - Completed Challenges View

struct CompletedChallengesView: View {
    @ObservedObject var completedData: CompletedWeeksData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(completedData.completedWeeks) { week in
                    VStack(alignment: .leading, spacing: 5) {
                        // Week header
                        Text("Week \(week.weekNumber):")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        
                        // If no challenges were completed
                        if week.challenges.isEmpty {
                            Text("Quel dommage, vous n'avez accompli aucune mission cette semaine.")
                                .italic()
                                .foregroundColor(.gray)
                        } else {
                            // List of completed challenges
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

// MARK: - Pie Slice & Pointer

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

struct PointerShape: Shape {
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

// MARK: - Preview

struct MyChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        MyChallengeView()
    }
}

