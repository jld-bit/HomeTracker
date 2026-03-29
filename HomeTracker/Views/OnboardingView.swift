import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.teal.opacity(0.5), Color.purple.opacity(0.4), Color.orange.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                Label("Track what you own", systemImage: "house.fill")
                Label("Snap photos for faster recall", systemImage: "camera.fill")
                Label("See value by room and category", systemImage: "chart.pie.fill")
                Label("Upgrade when you need exports & backup", systemImage: "sparkles")

                Spacer()

                Button(action: onContinue) {
                    Text("Start in 30 seconds")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 12, y: 8)
                }
            }
            .padding(24)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
        }
    }
}
