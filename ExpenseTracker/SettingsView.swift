//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 18.09.26.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var profileManager: ProfileManager
    @State private var showingLogoutConfirmation = false
    @State private var showingEditProfile = false
    @State private var showingDeleteConfirmation = false
    @State private var showingDeleteFinalConfirmation = false

    private var formattedBirthday: String? {
        guard let birthday = profileManager.birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthday)
    }

    var body: some View {
        NavigationView {
            Form {
                if let username = authManager.currentUsername {
                    Section(header: Text("Account")) {
                        Button {
                            showingEditProfile = true
                        } label: {
                            HStack(spacing: 12) {
                                if let image = profileManager.profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.blue)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(profileManager.fullName.isEmpty ? username : profileManager.fullName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("@\(username)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if !profileManager.email.isEmpty {
                                        Text(profileManager.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    if let formattedBirthday {
                                        Text(formattedBirthday)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Edit Profile")

                        NavigationLink(destination: ChangePasswordView()) {
                            Label("Change Password", systemImage: "lock.rotation")
                        }

                        Button(role: .destructive, action: {
                            showingLogoutConfirmation = true
                        }, label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        })
                    }

                    Section {
                        Button(role: .destructive, action: {
                            showingDeleteConfirmation = true
                        }, label: {
                            Label("Delete Account", systemImage: "trash")
                        })
                    } footer: {
                        Text("This permanently deletes your account, password, and profile data from this device. This cannot be undone.")
                    }
                }

                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.displayName, systemImage: theme.icon)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .accessibilityLabel("Theme")
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)

                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $showingLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Delete Account?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Continue", role: .destructive) {
                    showingDeleteFinalConfirmation = true
                }
            } message: {
                Text("This will permanently delete your account and all profile data. This cannot be undone.")
            }
            .alert("Are you absolutely sure?", isPresented: $showingDeleteFinalConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Account", role: .destructive) {
                    authManager.deleteAccount(profileManager: profileManager)
                }
            } message: {
                Text("There is no way to recover your account after this. This action is final.")
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
        .environmentObject(ProfileManager())
}
