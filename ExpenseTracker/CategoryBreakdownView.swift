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

    init(repository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: CategoryBreakdownViewModel(repository: repository))
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
                    Chart(viewModel.breakdown) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.5),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", item.category.capitalized))
                        .cornerRadius(4)
                    }
                    .frame(height: 260)
                    .padding()
                    .accessibilityHidden(true)

                    List(viewModel.breakdown) { item in
                        HStack {
                            Text(item.category.capitalized)
                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .navigationTitle("Breakdown")
            .onAppear {
                viewModel.loadBreakdown()
            }
        }
    }
}
