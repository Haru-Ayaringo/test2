import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var locationManager = LocationManager()

    @State private var region = MKCoordinateRegion(
        center: AppLocation.tokyoStation.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var isShowingLocationPicker = false
    
    private var board: Board {
        store.currentBoard()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ProfilePickerButton()
                DateBarView()

                Picker("盤種", selection: $store.selectedBoardType) {
                    ForEach(BoardType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                ZStack(alignment: .topTrailing) {
                    Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                        .modifier(MapStyleModifier(mapStyle: store.displaySettings.mapStyle))

                    BoardCanvasView(board: board, selectedCellPosition: .constant(.center))
                        .padding(12)
                        .frame(width: 170, height: 170)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .opacity(store.displaySettings.overlayOpacity)
                        .padding(12)
                        .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(maxHeight: .infinity)

                controlsSection
            }
            .padding()
            .navigationTitle("Map")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("地点を選ぶ") {
                        isShowingLocationPicker = true
                    }

                    Button("現在地へ") {
                        moveCameraToCurrentOrSelectedLocation()
                    }
                }
            }
            .onAppear {
                syncRegionToSelectedLocation(animated: false)
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocationIfAuthorized()
            }
            .onChange(of: store.selectedLocation) { _ in
                syncRegionToSelectedLocation(animated: true)
            }
            .onReceive(locationManager.$currentCoordinate.compactMap { $0 }) { coordinate in
                store.updateCurrentCoordinate(coordinate)
            }
            .sheet(isPresented: $isShowingLocationPicker) {
                LocationPickerSheet(initialCoordinate: region.center) { selected in
                    store.updateSelectedLocation(
                        AppLocation(
                            latitude: selected.latitude,
                            longitude: selected.longitude,
                            name: "手動地点"
                        )
                    )
                }
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("盤オーバーレイ透明度")
                Slider(value: $store.displaySettings.overlayOpacity, in: 0...1)
                Text(store.displaySettings.overlayOpacity, format: .number.precision(.fractionLength(2)))
                    .font(.caption)
                    .frame(width: 38)
            }

            Picker("地図スタイル", selection: $store.displaySettings.mapStyle) {
                ForEach(DisplaySettings.MapStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.segmented)

            LegendCardView(markers: Marker.allCases, isCollapsible: true)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func moveCameraToCurrentOrSelectedLocation() {
        if let current = store.currentCoordinate {
            withAnimation {
                region.center = current
            }
            return
        }

        withAnimation {
            region.center = store.selectedLocation.coordinate
        }
    }

    private func syncRegionToSelectedLocation(animated: Bool) {
        let target = store.currentCoordinate ?? store.selectedLocation.coordinate
        if animated {
            withAnimation {
                region.center = target
            }
        } else {
            region.center = target
        }
    }
}

private struct MapStyleModifier: ViewModifier {
    let mapStyle: DisplaySettings.MapStyle

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            switch mapStyle {
            case .standard:
                content.mapStyle(.standard)
            case .hybrid:
                content.mapStyle(.hybrid)
            }
        } else {
            content
        }
    }
}

private struct LocationPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var region: MKCoordinateRegion
    let onConfirm: (CLLocationCoordinate2D) -> Void

    init(initialCoordinate: CLLocationCoordinate2D, onConfirm: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onConfirm = onConfirm
        _region = State(
            initialValue: MKCoordinateRegion(
                center: initialCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region)
                    .ignoresSafeArea(edges: .bottom)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.red)
                    .shadow(radius: 3)
            }
            .navigationTitle("地点を選ぶ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("確定") {
                        onConfirm(region.center)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(AppStore())
}
