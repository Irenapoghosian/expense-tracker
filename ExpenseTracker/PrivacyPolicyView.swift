//
//  PrivacyPolicyView.swift
//  ExpenseTracker
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 4)

                Text("Last updated: September 2026")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                policySection(
                    title: "Overview",
                    body: """
                    ExpenseTracker is a personal finance tool built to help you track your expenses and budgets. \
                    This policy explains what data the app works with and how it is handled.
                    """
                )

                policySection(
                    title: "Data We Store",
                    body: """
                    All transaction and budget data you enter — titles, amounts, categories, and dates — is stored \
                    locally on your device using Apple's Core Data framework. This data is never uploaded to any \
                    external server, and ExpenseTracker does not operate any backend service of its own.
                    """
                )

                policySection(
                    title: "Data Sharing",
                    body: """
                    ExpenseTracker does not collect, transmit, or share your data with the developer, advertisers, \
                    or any third party. The only way data leaves the app is if you explicitly choose to export it \
                    (for example, using the CSV export feature), in which case you control where that file is sent \
                    or saved through the system share sheet.
                    """
                )

                policySection(
                    title: "Analytics & Tracking",
                    body: """
                    This app does not use any analytics, advertising, or tracking frameworks. No usage data is \
                    collected or transmitted.
                    """
                )

                policySection(
                    title: "Data Deletion",
                    body: """
                    You can delete individual transactions or budgets at any time from within the app. Deleting \
                    the app from your device permanently removes all locally stored data.
                    """
                )

                policySection(
                    title: "Children's Privacy",
                    body: """
                    ExpenseTracker is not directed at children and does not knowingly collect any information \
                    from children, as it does not collect information from anyone.
                    """
                )

                policySection(
                    title: "Changes to This Policy",
                    body: """
                    This policy may be updated as the app evolves. Continued use of the app after changes \
                    constitutes acceptance of the revised policy.
                    """
                )

                policySection(
                    title: "Contact",
                    body: """
                    This app is a personal portfolio project. If you have questions about this privacy policy, \
                    please reach out via the project's GitHub repository.
                    """
                )
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
}
