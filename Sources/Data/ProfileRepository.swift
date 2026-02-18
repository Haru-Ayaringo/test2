import Foundation

struct ProfileRepository {
    private let defaults: UserDefaults
    private let key = "profiles_v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadProfiles() -> [Profile] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? decoder.decode([Profile].self, from: data)) ?? []
    }

    func saveProfiles(_ profiles: [Profile]) {
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: key)
    }
}
