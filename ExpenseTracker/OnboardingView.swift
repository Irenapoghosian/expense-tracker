//
//  OnboardingView.swift
//  ExpenseTracker
//
//  Created by Iren Poghosyan on 15.09.26.
//


import SwiftUI

struct OnboardingPage {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "list.bullet.rectangle.fill",
            color: .blue,
            title: "Track Your Expenses",
            description: "Quickly add and organize every expense by category, all in one place."
        ),
        OnboardingPage(
            icon: "chart.pie.fill",
            color: .purple,
            title: "See Where It Goes",
            description: "Visual breakdowns show you exactly how much you spend in each category."
        ),
        OnboardingPage(
            icon: "target",
            color: .green,
            title: "Set Budgets",
            description: "Define monthly limits per category and get notified when you're close to going over."
        )
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: pages[index].icon)
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .frame(width: 140, height: 140)
                            .background(pages[index].color.gradient)
                            .clipShape(Circle())
                            .shadow(color: pages[index].color.opacity(0.4), radius: 20, y: 10)

                        Text(pages[index].title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)

                        Text(pages[index].description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)

            VStack {
                Spacer()
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        withAnimation { isPresented = false }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pages[currentPage].color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        withAnimation { isPresented = false }
                    }
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
