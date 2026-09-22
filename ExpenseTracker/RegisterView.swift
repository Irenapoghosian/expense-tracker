//
//  RegisterView.swift
//  ExpenseTracker
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var securityQuestion = AuthManager.securityQuestions[0]
    @State private var securityAnswer = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Create Account")) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.oneTimeCode)
                        .accessibilityHint("Choose a username, at least 3 characters")

                    PasswordField(placeholder: "Password", text: $password)
                        .accessibilityHint("Choose a password, at least 6 characters")

                    PasswordField(placeholder: "Confirm Password", text: $confirmPassword)
                        .accessibilityHint("Re-enter your password")

                    Picker("Security Question", selection: $securityQuestion) {
                        ForEach(AuthManager.securityQuestions, id: \.self) { question in
                            Text(question).tag(question)
                        }
                    }

                    TextField("Answer", text: $securityAnswer)
                        .autocorrectionDisabled()
                        .textContentType(.oneTimeCode)
                        .accessibilityHint("Used to recover your password if you forget it")
                }

                Section {
                    Text("Your security question is used to reset your password if you forget it.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let errorMessage = authManager.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        let success = authManager.register(
                            username: username,
                            password: password,
                            confirmPassword: confirmPassword,
                            securityQuestion: securityQuestion,
                            securityAnswer: securityAnswer
                        )
                        if success {
                            dismiss()
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty || confirmPassword.isEmpty || securityAnswer.isEmpty)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}
