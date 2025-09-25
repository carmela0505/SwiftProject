import SwiftUI

// Binding helpers
extension Binding where Value == String {
    func nameCased() -> Binding<String> {
        Binding(
            get: { self.wrappedValue },
            set: { new in
                let lower = new.lowercased()
                if let first = lower.first {
                    self.wrappedValue = String(first).uppercased() + lower.dropFirst()
                } else {
                    self.wrappedValue = ""
                }
            }
        )
    }
    func lowercasedInput() -> Binding<String> {
        Binding(
            get: { self.wrappedValue },
            set: { new in self.wrappedValue = new.lowercased() }
        )
    }
}

// Reusable styling
struct InputFieldModifier: ViewModifier {
    var bg: Color
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(bg)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundColor(.black)
    }
}
extension View {
    func inputField(bg: Color = Color.yellow.opacity(0.25)) -> some View {
        modifier(InputFieldModifier(bg: bg))
    }
    func cardStyle() -> some View {
        padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            .listRowBackground(Color.clear)
    }
}

// Small error view
private struct ErrorText: View {
    let show: Bool
    let text: String
    var body: some View {
        Group {
            if show {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct ProfilParentFormView: View {
    // Parent fields
    @State private var nom = "Gunther"
    @State private var prenom = "Lulu"
    @State private var email = "lg@gmail.com"
    @State private var dateNaissance = Date()
    
    

    // Active player (single child, read by ProfileEnfant)
    @AppStorage("prenomEnfant") private var prenomEnfant: String = ""

    // All children (names only) persisted as JSON
    @AppStorage("prenomsEnfants") private var prenomsEnfantsData: Data = Data()
    @State private var enfants: [String] = []

    // Add-child dedicated input
    @State private var newChildName: String = ""

    // UI
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var focus: Champ?
    enum Champ: Hashable { case nom, prenom, email, newChild, activeChild }
    
    
    init(selectedTab: Binding<TabTag>) {
        self._selectedTab = selectedTab
        // Default the date to the latest allowed so the form can pass validation immediately
        let sixYearsAgo = Calendar.current.date(byAdding: .year, value: -6, to: Date()) ?? Date()
        _dateNaissance = State(initialValue: sixYearsAgo)
    }
    
    
    
    
    
    private var backgroundColor: Color { Color.orange.opacity(0.80) }

    // Validation
    private func isValidName(_ s: String) -> Bool {
        s.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }
    private func normalizeEmail(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    private func isValidEmail(_ input: String) -> Bool {
        let mail = normalizeEmail(input)
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return mail.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }

    // Age rule: must be ≥ 6 years old
    private var latestAllowedDOB: Date {
        Calendar.current.date(byAdding: .year, value: -6, to: Date()) ?? Date()
    }
    private var isAgeOK: Bool { dateNaissance <= latestAllowedDOB }

    // Flags (parent)
    private var showNomError: Bool { !nom.isEmpty && !isValidName(nom) }
    private var showPrenomError: Bool { !prenom.isEmpty && !isValidName(prenom) }
    private var showEmailError: Bool { !email.isEmpty && !isValidEmail(email) }

    // Children flags
    private var hasAtLeastOneChild: Bool { !enfants.isEmpty }
    private var allChildrenValid: Bool { enfants.allSatisfy { isValidName($0) } }
    private var showActiveChildError: Bool { !prenomEnfant.isEmpty && !isValidName(prenomEnfant) }

    private var canAddNewChild: Bool {
        let trimmed = newChildName.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidName(trimmed) && !enfants.contains(trimmed)
    }

    private var formOK: Bool {
        isValidName(nom) &&
        isValidName(prenom) &&
        isValidEmail(email) &&
        isAgeOK &&
        isValidName(prenomEnfant) // active player must be valid
    }

    // Fields
    private var nomField: some View {
        TextField("", text: $nom.nameCased(),
                  prompt: Text("Nom").foregroundColor(.black.opacity(0.6)))
            .textContentType(.oneTimeCode)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($focus, equals: .nom)
            .submitLabel(.next)
            .inputField()
    }

    private var prenomField: some View {
        TextField("", text: $prenom.nameCased(),
                  prompt: Text("Prénom").foregroundColor(.black.opacity(0.6)))
            .textContentType(.oneTimeCode)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($focus, equals: .prenom)
            .submitLabel(.next)
            .onSubmit { prenom = prenom.capitalized }
                    .onChange(of: prenom) { s in
                        // optional: keep only one initial uppercase, don’t fight each keystroke
                        if s.count == 1 { prenom = s.uppercased() }
                    }
                    .inputField()
    }

    private var emailField: some View {
        TextField("", text: $email.lowercasedInput(),
                  prompt: Text("Email").foregroundColor(.black.opacity(0.6)))
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focus, equals: .email)
            .submitLabel(.done)
            .inputField()
    }

    @Binding var selectedTab: TabTag
    
    
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Date de naissance")
//                .font(.subheadline.weight(.semibold))
//                .foregroundColor(.black)
//
//            DatePicker("",
//                       selection: $dateNaissance,
//                       in: ...latestAllowedDOB,
//                       displayedComponents: .date)
//                .labelsHidden()
//                .tint(.black)
//
//            ErrorText(show: !isAgeOK, text: " l'enfant doit avoir au moins 6 ans.")
//        }
//        .inputField(bg: Color.yellow.opacity(0.18))
//    }

       
    private var datePickerField: some View {
        VStack(spacing: 4) {
            DatePicker(
                "Date de naissance",
                selection: $dateNaissance,
                in: ...latestAllowedDOB,
                displayedComponents: .date
            )
            .labelsHidden()
            .tint(.black)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading) // 👈 stretch full width
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.yellow.opacity(0.25))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundColor(.black)

            ErrorText(show: !isAgeOK, text: " l'enfant doit avoir au moins 6 ans.")
        }
    }

        
        
    // Sections
    private var identiteSection: some View {
        Section {
            VStack(spacing: 4) {
                nomField
                ErrorText(show: showNomError, text: "Le nom doit contenir au moins 3 caractères.")

                prenomField
                ErrorText(show: showPrenomError, text: "Le prénom doit contenir au moins 3 caractères.")

                datePickerField
            }
            .cardStyle()
        } header: {
            Text("Identité du parent").font(.headline).textCase(nil)
        }
    }

    private var activeChildSection: some View {
        Section {
            VStack() {
 
//
//                ErrorText(show: showActiveChildError, text: "Le prénom doit contenir au moins 3 caractères.")

                if hasAtLeastOneChild {
                    Menu {
                        ForEach(enfants, id: \.self) { name in
                            Button("Utiliser « \(name) »") { prenomEnfant = name }
                        }
                    } label: {
//                        Label("Choisir depuis la liste des enfants", systemImage: "person.crop.circle.badge.checkmark")
                    }
                }
            }
            .cardStyle()
        } header: {
//            Text("Enfant joueur").font(.headline).textCase(nil)
        } footer: {
//            Text("Ce prénom sera utilisé par l’écran Profil Enfant.")
        }
    }

    private var enfantsSection: some View {
        Section {
            VStack(spacing: 8) {

                // --- Add child input ---
                HStack(spacing: 8) {
                    TextField("Ajouter un prénom", text: $newChildName.nameCased())
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($focus, equals: .newChild)
                        .submitLabel(.done)
                        .inputField()

                    Button {
                        let trimmed = newChildName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard isValidName(trimmed), !enfants.contains(trimmed) else { return }
                        withAnimation {
                            enfants.append(trimmed)
                        }
                        // If no active player yet, set it to this one
                        if !isValidName(prenomEnfant) { prenomEnfant = trimmed }
                        newChildName = ""
                        saveChildrenToStorage()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                    .disabled(!canAddNewChild)
                    .tint(.blue)
                    .accessibilityLabel("Ajouter l’enfant")
                }

                // --- Children list ---
                if enfants.isEmpty {
                    Text("Aucun enfant ajouté pour l’instant.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(enfants, id: \.self) { name in
                        HStack {
                            Text(name)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if name != prenomEnfant {
                                Button {
                                    prenomEnfant = name
                                } label: {
                                    Label("Définir comme joueur", systemImage: "checkmark.circle")
                                }
                                .buttonStyle(.borderless)
                            } else {
                                Label("Joueur actuel", systemImage: "star.fill")
                                    .foregroundColor(.orange)
                            }

                            Button(role: .destructive) {
                                withAnimation {
                                    if let idx = enfants.firstIndex(of: name) {
                                        let removed = enfants.remove(at: idx)
                                        if removed == prenomEnfant {
                                            prenomEnfant = enfants.first ?? ""
                                        }
                                    }
                                }
                                saveChildrenToStorage()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .imageScale(.large)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("Supprimer l’enfant")
                        }
                    }
                }
            }
            .cardStyle()
        } header: {
            Text("Enfants (liste + ajout)").font(.headline).textCase(nil)
        } footer: {
//            Text("Entrez un prénom (≥3 caractères), puis touchez + pour l’ajouter. Sélectionnez un enfant pour le définir comme joueur.")
        }
    }

    private var emailSection: some View {
        Section {
            VStack(spacing: 6) {
                emailField
                ErrorText(show: showEmailError, text: "Email invalide.")
            }
            .cardStyle()
        } header: {
            Text("Email").font(.headline).textCase(nil)
        }
    }

    private var navSection: some View {
        Section {
//            Button {
//                // ProfileEnfant should read @AppStorage("prenomEnfant")
////                ProfileEnfant(selectedTab: $selectedTab)
//            } label: {
//                Text("Enregistrer vos informations")
//                    .frame(maxWidth: .infinity)
//                    .font(.system(size: 18, weight: .bold, design: .rounded))
//            }
////            .buttonStyle(.borderedProminent)
////            .buttonBorderShape(.roundedRectangle(radius: 14))
//            .tint(.blue)
//            .disabled(!formOK)
//        }
//        .listRowBackground(Color.clear)
//    }

            NavigationLink {
                       ProfileEnfant(selectedTab: $selectedTab)
                   } label: {
                       Text("Enregistrer vos informations")
                           .frame(maxWidth: .infinity)
                           .font(.system(size: 18, weight: .bold, design: .rounded))
                           .padding(.vertical, 10)
                           .background(formOK ? Color.blue : Color.gray.opacity(0.4))
                           .foregroundColor(.white)
                           .clipShape(RoundedRectangle(cornerRadius: 14))
                   }
                   .disabled(!formOK)
               }
               .listRowBackground(Color.clear)
           }
            
            
            
            
            // Persistence
    private func saveChildrenToStorage() {
        do {
            let data = try JSONEncoder().encode(enfants)
            prenomsEnfantsData = data
        } catch {
            print("Failed to encode children names: \(error)")
        }
    }
    private func loadChildrenFromStorage() {
        guard !prenomsEnfantsData.isEmpty else { return }
        do {
            let decoded = try JSONDecoder().decode([String].self, from: prenomsEnfantsData)
            enfants = decoded
        } catch {
            print("Failed to decode children names: \(error)")
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea(edges: .top)

                Form {
                    //METTRE VALEUR DEFAUT POUR LE DATE PICKER
                    identiteSection
                    emailSection
//                    activeChildSection
                    enfantsSection
                    navSection
                }
                .scrollContentBackground(.hidden)
                .safeAreaPadding(.bottom, 16)
                .padding(.bottom, 8)
            }
            
            .navigationTitle("Profil parent")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit {
                switch focus {
                case .nom:    focus = .prenom
                case .prenom: focus = .email
                case .email:  focus = nil
                default:      focus = nil
                }
            }
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("Terminé") { focus = nil }
//                }
//            }
            .alert("Information", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadChildrenFromStorage()
                // keep active child consistent with list on first load
                if enfants.isEmpty, isValidName(prenomEnfant) {
                    enfants = [prenomEnfant]
                    saveChildrenToStorage()
                } else if prenomEnfant.isEmpty, let first = enfants.first {
                    prenomEnfant = first
                }
            }

        }
    }
}

#Preview {
    NavigationStack { ProfilParentFormView(selectedTab: .constant(.challenges)) }
}

