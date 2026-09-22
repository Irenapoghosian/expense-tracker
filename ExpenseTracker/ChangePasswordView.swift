//
//  ChangePasswordView.swift
//  ExpenseTracker
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject private var authManager: AuthManager

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var successMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Current Password")) {
                PasswordField(placeholder: "Current Password", text: $currentPassword)
            }

            Section(header: Text("New Password")) {
                PasswordField(placeholder: "New Password", text: $newPassword)
                PasswordField(placeholder: "Confirm New Password", text: $confirmPassword)
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

            Section {
                Button("Update Password") {
                    let success = authManager.changePassword(
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                        confirmPassword: confirmPassword
                    )
                    if success {
                        successMessage = "Your password has been updated."
                        currentPassword = ""
                        newPassword = ""
                        confirmPassword = ""
                    } else {
                        successMessage = nil
                    }
                }
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
            }
        }
        .navigationTitle("Change Password")
        .onAppear {
            authManager.errorMessage = nil
        }
    }
}

#Preview {
    NavigationView {
        ChangePasswordView()
            .environmentObject(AuthManager())
    }
}
