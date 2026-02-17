import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var selectedDate: Date
    @Published var selectedBoardType: BoardType
    @Published var selectedProfileId: UUID?
    @Published var profiles: [Profile]
    @Published var selectedLocation: AppLocation
    @Published var displaySettings: DisplaySettings

    init(
        selectedDate: Date = .now,
        selectedBoardType: BoardType = .day,
        selectedProfileId: UUID? = nil,
        profiles: [Profile] = [],
        selectedLocation: AppLocation = .tokyoStation,
        displaySettings: DisplaySettings = .default
    ) {
        self.selectedDate = selectedDate
        self.selectedBoardType = selectedBoardType
        self.selectedProfileId = selectedProfileId
        self.profiles = profiles
        self.selectedLocation = selectedLocation
        self.displaySettings = displaySettings
    }

    var selectedProfile: Profile? {
        guard let selectedProfileId else { return nil }
        return profiles.first(where: { $0.id == selectedProfileId })
    }
}
