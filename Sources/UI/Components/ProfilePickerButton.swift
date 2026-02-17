import SwiftUI

struct ProfilePickerButton: View {
    @EnvironmentObject private var store: AppStore
    @State private var isShowingProfilePicker = false

    var body: some View {
        Button {
            isShowingProfilePicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                Text(selectedProfileText)
                    .font(.subheadline)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("プロフィール切替")
        .accessibilityValue(selectedProfileText)
        .confirmationDialog("プロフィール切替", isPresented: $isShowingProfilePicker, titleVisibility: .visible) {
            if store.profiles.isEmpty {
                Button("プロフィールがありません", role: .cancel) {}
            } else {
                ForEach(store.profiles) { profile in
                    Button(profile.birthDate.formatted(Date.FormatStyle().year().month(.twoDigits).day(.twoDigits))) {
                        store.selectProfile(profile)
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
        } message: {
            if store.profiles.isEmpty {
                Text("Settingsタブでプロフィールを追加してください。")
            }
        }
    }

    private var selectedProfileText: String {
        guard let selected = store.selectedProfile else {
            return "プロフィール未選択"
        }
        return selected.birthDate.formatted(Date.FormatStyle().year().month(.twoDigits).day(.twoDigits))
    }
}

#Preview {
    ProfilePickerButton()
        .environmentObject(AppStore())
        .padding()
}
