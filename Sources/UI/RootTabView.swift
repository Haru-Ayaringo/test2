import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            BoardView()
                .tabItem {
                    Label("Board", systemImage: "square.grid.3x3")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppStore())
}
