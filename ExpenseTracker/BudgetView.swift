import SwiftUI

struct BudgetView: View {
    @StateObject private var viewModel: BudgetViewModel
    @State private var showingAddBudget = false

    init(repository: TransactionRepository) {
        _viewModel = StateObject(wrappedValue: BudgetViewModel(repository: repository))
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.budgetStatuses.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        Text("No budgets set")
                            .font(.headline)
                        Text("Tap + to set a budget for a category")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                } else {
                    List(viewModel.budgetStatuses) { status in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                let category = Category.from(status.category)
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                    .accessibilityHidden(true)
                                Text(category.displayName)
                                    .font(.headline)
                                Spacer()
                                Text(status.spent, format: .currency(code: "USD"))
                                    .foregroundColor(status.isOverBudget ? .red : .primary)
                                Text("/")
                                    .foregroundColor(.secondary)
                                Text(status.limit, format: .currency(code: "USD"))
                                    .foregroundColor(.secondary)
                            }

                            ProgressView(value: status.percentUsed)
                                .tint(status.isOverBudget ? .red : .green)
                                .animation(.easeInOut(duration: 0.4), value: status.percentUsed)
                                .accessibilityLabel("Budget used")
                                .accessibilityValue("\(Int(status.percentUsed * 100)) percent")

                            if status.isOverBudget {
                                Text("Over budget by \(abs(status.remaining), format: .currency(code: "USD"))")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else {
                                Text("\(status.remaining, format: .currency(code: "USD")) remaining")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .accessibilityElement(children: .combine)
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.budgetStatuses.map(\.id))
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddBudget = true }, label: {
                        Label("Set Budget", systemImage: "plus")
                    })
                }
            }
            .sheet(isPresented: $showingAddBudget, onDismiss: {
                viewModel.loadBudgets()
            }, content: {
                SetBudgetView(viewModel: viewModel)
            })
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
