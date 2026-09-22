//
//  PasswordField.swift
//  ExpenseTracker
//

import SwiftUI

struct PasswordField: View {
    let placeholder: String
    @Binding var text: String
    var boxed: Bool = false
    @State private var isSecured: Bool = true

    var body: some View {
        HStack {
            Group {
                if isSecured {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textContentType(.oneTimeCode)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            Button(action: { isSecured.toggle() }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSecured ? "Show password" : "Hide password")
        }
        .padding(boxed ? 10 : 0)
        .background {
            if boxed {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PasswordField(placeholder: "Password", text: .constant(""), boxed: true)
        PasswordField(placeholder: "Password", text: .constant(""))
    }
    .padding()
}
