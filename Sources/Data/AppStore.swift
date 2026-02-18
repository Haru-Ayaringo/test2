import Foundation
import CoreLocation

@MainActor
final class AppStore: ObservableObject {
    @Published var selectedDate: Date {
        didSet { persistAppStateIfReady() }
    }
    @Published var selectedBoardType: BoardType {
        didSet { persistAppStateIfReady() }
    }
    @Published var selectedProfileId: UUID? {
        didSet { persistAppStateIfReady() }
    }
    @Published var profiles: [Profile] {
        didSet {
            profileRepository.saveProfiles(profiles)
            normalizeSelectedProfileIfNeeded()
        }
    }
    @Published var selectedLocation: AppLocation {
        didSet { persistAppStateIfReady() }
    }
    @Published var displaySettings: DisplaySettings {
        didSet { settingsRepository.saveDisplaySettings(displaySettings) }
    }
    @Published var currentCoordinate: CLLocationCoordinate2D?

    let engine: KyuseiEngine

    private let profileRepository: ProfileRepository
    private let appStateRepository: AppStateRepository
    private let settingsRepository: SettingsRepository
    private let calendar: Calendar
    private let userDefaults: UserDefaults
    private let initialLocationSeededKey = "initial_location_seeded_v1"
    private var hasLoadedInitialState = false

    init(
        engine: KyuseiEngine = StubKyuseiEngine(),
        profileRepository: ProfileRepository = ProfileRepository(),
        appStateRepository: AppStateRepository = AppStateRepository(),
        settingsRepository: SettingsRepository = SettingsRepository(),
        calendar: Calendar = .current,
        userDefaults: UserDefaults = .standard
    ) {
        self.engine = engine
        self.profileRepository = profileRepository
        self.appStateRepository = appStateRepository
        self.settingsRepository = settingsRepository
        self.calendar = calendar
        self.userDefaults = userDefaults

        let loadedProfiles = profileRepository.loadProfiles()
        let loadedState = appStateRepository.loadState()
        let loadedSettings = settingsRepository.loadDisplaySettings()

        self.profiles = loadedProfiles
        self.selectedDate = loadedState?.selectedDate ?? .now
        self.selectedBoardType = loadedState?.selectedBoardType ?? .day
        self.selectedProfileId = loadedState?.selectedProfileId
        self.selectedLocation = loadedState?.selectedLocation ?? .tokyoStation
        self.displaySettings = loadedSettings ?? .default
        self.currentCoordinate = nil

        normalizeSelectedProfileIfNeeded()
        hasLoadedInitialState = true
        persistAppStateIfReady()
        settingsRepository.saveDisplaySettings(displaySettings)
    }

    var selectedProfile: Profile? {
        guard let selectedProfileId else { return nil }
        return profiles.first(where: { $0.id == selectedProfileId })
    }

    var resolvedProfileForBoard: Profile {
        selectedProfile ?? Profile(name: "デフォルト", birthDate: Date(timeIntervalSince1970: 0))
    }

    func currentBoard() -> Board {
        engine.makeBoard(profile: resolvedProfileForBoard, date: selectedDate, type: selectedBoardType)
    }

    func addProfile(birthDate: Date, name: String = "") {
        if let existing = profiles.first(where: { calendar.isDate($0.birthDate, inSameDayAs: birthDate) }) {
            selectedProfileId = existing.id
            return
        }

        let profile = Profile(name: name, birthDate: birthDate)
        profiles.append(profile)
        profiles.sort { $0.createdAt > $1.createdAt }
        selectedProfileId = profile.id
    }

    func deleteProfiles(at offsets: IndexSet) {
        let deletingIds = offsets.map { profiles[$0].id }
        profiles.remove(atOffsets: offsets)

        if let selectedProfileId, deletingIds.contains(selectedProfileId) {
            self.selectedProfileId = profiles.first?.id
        }
    }

    func selectProfile(_ profile: Profile) {
        selectedProfileId = profile.id
    }

    func updateCurrentCoordinate(_ coordinate: CLLocationCoordinate2D?) {
        currentCoordinate = coordinate
        if let coordinate {
            seedSelectedLocationWithCurrentCoordinateIfNeeded(coordinate)
        }
    }

    func updateSelectedLocation(_ location: AppLocation) {
        userDefaults.set(true, forKey: initialLocationSeededKey)
        selectedLocation = location
    }

    func setSelectedLocationToCurrentCoordinate(name: String = "現在地") -> Bool {
        guard let currentCoordinate else { return false }

        updateSelectedLocation(
            AppLocation(
                latitude: currentCoordinate.latitude,
                longitude: currentCoordinate.longitude,
                name: name
            )
        )
        return true
    }

    private func seedSelectedLocationWithCurrentCoordinateIfNeeded(_ coordinate: CLLocationCoordinate2D) {
        let isSeeded = userDefaults.bool(forKey: initialLocationSeededKey)
        guard !isSeeded else { return }
        guard selectedLocation == .tokyoStation else { return }

        selectedLocation = AppLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            name: "現在地"
        )
        userDefaults.set(true, forKey: initialLocationSeededKey)
    }

    private func persistAppStateIfReady() {
        guard hasLoadedInitialState else { return }
        let state = PersistedAppState(
            selectedProfileId: selectedProfileId,
            selectedDate: selectedDate,
            selectedBoardType: selectedBoardType,
            selectedLocation: selectedLocation
        )
        appStateRepository.saveState(state)
    }

    private func normalizeSelectedProfileIfNeeded() {
        if let selectedProfileId, profiles.contains(where: { $0.id == selectedProfileId }) {
            persistAppStateIfReady()
            return
        }

        self.selectedProfileId = profiles.first?.id
    }
}
