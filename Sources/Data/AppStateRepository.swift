import Foundation

struct PersistedAppState: Codable {
    var selectedProfileId: UUID?
    var selectedDate: Date
    var selectedBoardType: BoardType
    var selectedLocation: AppLocation
}

struct AppStateRepository {
    private let defaults: UserDefaults
    private let key = "app_state_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadState() -> PersistedAppState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(PersistedAppState.self, from: data)
    }

    func saveState(_ state: PersistedAppState) {
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}
