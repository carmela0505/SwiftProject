//
//  Profil.swift
//  TESTING
//
//  Created by apprenant130 on 14/09/2025.
//
import SwiftUI

// MARK: - Bindings
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

// MARK: - Reusable styles
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
            .foregroundColor(.black) // typed text in black
    }
}

extension View {
    /// Apply the styled text-field background + border
    func inputField(bg: Color = Color.yellow.opacity(0.25)) -> some View {
        self.modifier(InputFieldModifier(bg: bg))
    }

    /// Card container style used around groups/sections
    func cardStyle() -> some View {
        self
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            .listRowBackground(Color.clear)
    }
}

// MARK: - Form
struct ProfilParentFormView: View {
    // Champs
    @State private var nom = ""
    @State private var prenom = ""
    @State private var prenomEnfant = ""
    @State private var email = ""
    @State private var dateNaissance = Date()
    @State private var relation = "Mère"

    // UI
    @State private var showAlert = false
    @State private var alertMessage = ""

    @FocusState private var focus: Champ?
    enum Champ: Hashable { case nom, prenom, prenomEnfant, email }

    private let relations = ["Mère", "Père", "Tuteur·trice"]

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
    private var formOK: Bool {
        isValidName(nom) && isValidName(prenom) && isValidName(prenomEnfant) && isValidEmail(email)
    }

    private var backgroundColor: Color { Color.orange.opacity(0.8) }

    // MARK: Small field views (keeps the big body simple)
    private var nomField: some View {
        TextField("", text: $nom.nameCased(),
                  prompt: Text("Nom").foregroundColor(.black.opacity(0.6)))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($focus, equals: .nom)
            .submitLabel(.next)
            .inputField()
    }

    private var prenomField: some View {
        TextField("", text: $prenom.nameCased(),
                  prompt: Text("Prénom").foregroundColor(.black.opacity(0.6)))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($focus, equals: .prenom)
            .submitLabel(.next)
            .inputField()
    }

    private var prenomEnfantField: some View {
        TextField("", text: $prenomEnfant.nameCased(),
                  prompt: Text("Prénom de l’enfant").foregroundColor(.black.opacity(0.6)))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .focused($focus, equals: .prenomEnfant)
            .submitLabel(.next)
            .inputField()
    }

    private var emailField: some View {
        TextField("", text: $email.lowercasedInput(),
                  prompt: Text("Email").foregroundColor(.black.opacity(0.6)))
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focus, equals: .email)
            .submitLabel(.done)
            .inputField()
    }

    private var datePickerField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date de naissance").font(.subheadline.weight(.semibold)).foregroundColor(.black)
            DatePicker("", selection: $dateNaissance, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .tint(.black)
        }
        .inputField(bg: Color.yellow.opacity(0.18))
    }

    // Tiny helper for errors
    @ViewBuilder
    private func errorText(_ show: Bool, _ text: String) -> some View {
        if show {
            Text(text)
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                Form {
                    // Identité du parent
                    Section {
                        VStack(spacing: 12) {
                            nomField
                            errorText(!nom.isEmpty && !isValidName(nom),
                                      "Le nom doit contenir au moins 3 caractères.")

                            prenomField
                            errorText(!prenom.isEmpty && !isValidName(prenom),
                                      "Le prénom doit contenir au moins 3 caractères.")

                            datePickerField

                            Picker("Relation", selection: $relation) {
                                ForEach(relations, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        .cardStyle()
                    } header: {
                        Text("Identité du parent")
                            .font(.headline)
                            .textCase(nil)
                    }

                    // Enfant
                    Section {
                        VStack(spacing: 12) {
                            prenomEnfantField
                            errorText(!prenomEnfant.isEmpty && !isValidName(prenomEnfant),
                                      "Le prénom de l’enfant doit contenir au moins 3 caractères.")
                        }
                        .cardStyle()
                    } header: {
                        Text("Enfant")
                            .font(.headline)
                            .textCase(nil)
                    }

                    // Email
                    Section {
                        VStack(spacing: 12) {
                            emailField
                            errorText(!email.isEmpty && !isValidEmail(email),
                                      "Email invalide.")
                        }
                        .cardStyle()
                    } header: {
                        Text("Email")
                            .font(.headline)
                            .textCase(nil)
                    }

                    // Navigation
                    Section {
                        NavigationLink {
                            ProfileEnfant(prenomEnfant: prenomEnfant)
                        } label: {
                            Text("Continuer vers le profil enfant")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 14))
                        .tint(.blue)
                        .disabled(!formOK)
                    } footer: {
                        Text("Les prénoms doivent commencer par une majuscule et faire au moins 3 caractères.")
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profil parent")
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit {
                switch focus {
                case .nom:          focus = .prenom
                case .prenom:       focus = .prenomEnfant
                case .prenomEnfant: focus = .email
                default:            focus = nil
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Terminé") { focus = nil }
                }
            }
            .alert("Information", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    NavigationStack { ProfilParentFormView() }
}
