//
//  LoginView.swift
//  ExpenseTracker
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingForgotPassword = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.blue.gradient)
                        Text("Welcome Back")
                            .font(.largeTitle.bold())
                        Text("Log in to track your expenses")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 12) {
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.oneTimeCode)
                            .accessibilityHint("Enter your username")

                        PasswordField(placeholder: "Password", text: $password, boxed: true)
                            .accessibilityHint("Enter your password")
                    }
                    .padding(.horizontal)

                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        authManager.login(username: username, password: password)
                    }, label: {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    })
                    .padding(.horizontal)
                    .disabled(username.isEmpty || password.isEmpty)

                    Button("Forgot Password?") {
                        authManager.errorMessage = nil
                        showingForgotPassword = true
                    }
                    .font(.footnote)

                    HStack {
                        VStack { Divider() }
                        Text("or")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        VStack { Divider() }
                    }
                    .padding(.horizontal)

                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.fullName]
                    }, onCompletion: { result in
                        authManager.handleAppleSignIn(result)
                    })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    Button("Don't have an account? Sign Up") {
                        authManager.errorMessage = nil
                        showingRegister = true
                    }
                    .font(.footnote)
                    .padding(.top, 8)

                    Spacer(minLength: 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
