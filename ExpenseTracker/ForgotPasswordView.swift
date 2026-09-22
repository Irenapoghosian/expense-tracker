//
//  ForgotPasswordView.swift
//  ExpenseTracker
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var foundQuestion: String?
    @State private var securityAnswer = ""
    @State private var newPassword = ""
    @State private var confirmPassword = "x"
    @State private var successMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Find Your Account")) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.oneTimeCode)

                    Button("Find Account") {
                        authManager.errorMessage = nil
                        successMessage = nil
                        if let question = authManager.securityQuestion(for: username) {
                            foundQuestion = question
                        } else {
                            foundQuestion = nil
                            authManager.errorMessage = "No account found with that username."
                        }
                    }
                    .disabled(username.isEmpty)
                }

                if let foundQuestion {
                    Section(header: Text("Security Question")) {
                        Text(foundQuestion)
                            .font(.subheadline)
                        PasswordField(placeholder: "Your Answer", text: $securityAnswer)
                    }

                    Section(header: Text("New Password")) {
                        PasswordField(placeholder: "New Password", text: $newPassword)
                        PasswordField(placeholder: "Confirm New Password", text: $confirmPassword)
                    }

                    Section {
                        Button("Reset Password") {
                            let success = authManager.resetPassword(
                                username: username,
                                securityAnswer: securityAnswer,
                                newPassword: newPassword,
                                confirmPassword: confirmPassword
                            )
                            if success {
                                successMessage = "Password updated. You can now log in."
                            }
                        }
                        .disabled(securityAnswer.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                    }
                }

                if let errorMessage = authManager.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                if let successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Reset Password")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                if successMessage != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
            .onAppear {
                authManager.errorMessage = nil
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthManager())
}
