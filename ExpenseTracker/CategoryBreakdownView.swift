//
//  CategoryBreakdownView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//

import SwiftUI
import Charts

struct CategoryBreakdownView: View {
    @StateObject private var viewModel: CategoryBreakdownViewModel

    private static let palette: [Color] = [
        .blue, .green, .orange, .purple, .pink,
        .teal, .yellow, .red, .indigo, .mint
    ]

    init(repository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: CategoryBreakdownViewModel(repository: repository))
    }

    private var total: Double {
        viewModel.breakdown.reduce(0) { $0 + $1.amount }
    }

    private func color(for category: String) -> Color {
        let sortedCategories = viewModel.breakdown.map(\.category).sorted()
        let index = sortedCategories.firstIndex(of: category) ?? 0
        return Self.palette[index % Self.palette.count]
    }

    private func percentage(for amount: Double) -> String {
        guard total > 0 else { return "0%" }
        let percent = (amount / total) * 100
        return String(format: "%.0f%%", percent)
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.breakdown.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        Text("No data yet")
                            .font(.headline)
                        Text("Add some transactions to see the breakdown")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    Spacer()
                } else {
                    VStack(spacing: 4) {
                        Text("Total Spent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(total, format: .currency(code: "USD"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }
                    .padding(.top, 12)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Total spent \(total.formatted(.currency(code: "USD")))")

                    Chart(viewModel.breakdown) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(color(for: item.category))
                        .cornerRadius(4)
                    }
                    .frame(height: 240)
                    .padding()
                    .accessibilityHidden(true)

                    List(viewModel.breakdown) { item in
                        HStack {
                            Circle()
                                .fill(color(for: item.category))
                                .frame(width: 12, height: 12)
                            Text(item.category.capitalized)
                            Spacer()
                            Text(percentage(for: item.amount))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.amount, format: .currency(code: "USD"))
                                .foregroundColor(.secondary)
                                .frame(minWidth: 70, alignment: .trailing)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.category.capitalized), \(percentage(for: item.amount)) of total, \(item.amount.formatted(.currency(code: "USD")))")
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Breakdown")
            .onAppear {
                viewModel.loadBreakdown()
            }
        }
    }
}
