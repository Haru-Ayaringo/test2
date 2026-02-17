import SwiftUI

struct DateBarView: View {
    @EnvironmentObject private var store: AppStore
    @State private var isShowingDatePicker = false

    private static let minDate: Date = {
        var components = DateComponents()
        components.year = 1900
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components) ?? .distantPast
    }()

    private static let maxDate: Date = {
        var components = DateComponents()
        components.year = 2100
        components.month = 12
        components.day = 31
        return Calendar.current.date(from: components) ?? .distantFuture
    }()

    var body: some View {
        HStack(spacing: 12) {
            Button {
                moveDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Button {
                isShowingDatePicker = true
            } label: {
                Text(store.selectedDate.formatted(Date.FormatStyle().year().month(.twoDigits).day(.twoDigits)))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
            }

            Button {
                moveDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }

            Button {
                isShowingDatePicker = true
            } label: {
                Image(systemName: "calendar")
            }
        }
        .buttonStyle(.bordered)
        .sheet(isPresented: $isShowingDatePicker) {
            NavigationStack {
                Form {
                    DatePicker(
                        "日付",
                        selection: Binding(
                            get: { clamped(store.selectedDate) },
                            set: { store.selectedDate = clamped($0) }
                        ),
                        in: Self.minDate...Self.maxDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                .navigationTitle("日付選択")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("閉じる") {
                            isShowingDatePicker = false
                        }
                    }
                }
            }
        }
    }

    private func moveDate(by days: Int) {
        let baseDate = clamped(store.selectedDate)
        let moved = Calendar.current.date(byAdding: .day, value: days, to: baseDate) ?? baseDate
        store.selectedDate = clamped(moved)
    }

    private func clamped(_ date: Date) -> Date {
        min(max(date, Self.minDate), Self.maxDate)
    }
}

#Preview {
    DateBarView()
        .environmentObject(AppStore())
        .padding()
}
