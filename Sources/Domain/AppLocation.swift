import Foundation
import CoreLocation

struct AppLocation: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var name: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let tokyoStation = AppLocation(
        latitude: 35.681236,
        longitude: 139.767125,
        name: "東京駅"
    )
}
