import Foundation

struct SettingsRepository {
    private let defaults: UserDefaults
    private let key = "display_settings_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDisplaySettings() -> DisplaySettings? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(DisplaySettings.self, from: data)
    }

    func saveDisplaySettings(_ settings: DisplaySettings) {
        guard let data = try? encoder.encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
