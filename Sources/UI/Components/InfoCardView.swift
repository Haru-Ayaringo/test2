import SwiftUI

struct InfoCardView: View {
    let title: String
    let message: String
    var systemImage: String = "info.circle"

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    InfoCardView(
        title: "プロフィール未登録",
        message: "Settingsタブからプロフィールを追加してください。"
    )
    .padding()
}
