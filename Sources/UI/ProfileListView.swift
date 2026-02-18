import SwiftUI

struct ProfileListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var isShowingAddSheet = false

    var body: some View {
        Section("プロフィール管理") {
            if store.profiles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("プロフィールがありません")
                        .font(.headline)
                    Text("右上の＋ボタンから生年月日を追加してください。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(store.profiles) { profile in
                    Button {
                        store.selectProfile(profile)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.birthDate.formatted(date: .long, time: .omitted))
                                    .foregroundStyle(.primary)
                                if !profile.name.isEmpty {
                                    Text(profile.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if store.selectedProfileId == profile.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: store.deleteProfiles)
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddProfileSheet { birthDate in
                store.addProfile(birthDate: birthDate)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("プロフィール追加")
            }
        }
    }
}

private struct AddProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var birthDate: Date = .now

    let onSave: (Date) -> Void

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("生年月日", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            .navigationTitle("プロフィール追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(birthDate)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            ProfileListView()
        }
        .environmentObject(AppStore())
    }
}
