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
    @State private var isShowingCurrentLocationUnavailableAlert = false

    private var board: Board {
        store.currentBoard()
    }

    private var locationPermissionDenied: Bool {
        locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ProfilePickerButton()
                DateBarView()

                if store.profiles.isEmpty {
                    InfoCardView(
                        title: "プロフィール未登録",
                        message: "Settingsタブでプロフィールを追加すると、地図上の盤表示をプロフィール前提で検証できます。",
                        systemImage: "person.crop.circle.badge.plus"
                    )
                }

                if locationPermissionDenied {
                    InfoCardView(
                        title: "位置情報が使えません",
                        message: "位置情報が未許可のため、手動地点で表示しています。「地点を選ぶ」から地点を設定してください。",
                        systemImage: "location.slash"
                    )
                }

                Picker("盤種", selection: $store.selectedBoardType) {
                    ForEach(BoardType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("盤種")

                ZStack(alignment: .topTrailing) {
                    Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                        .modifier(MapStyleModifier(mapStyle: store.displaySettings.mapStyle))
                        .accessibilityLabel("地図")

                    BoardCanvasView(board: board, selectedCellPosition: .constant(.center))
                        .padding(12)
                        .frame(width: 170, height: 170)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .opacity(store.displaySettings.overlayOpacity)
                        .padding(12)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
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
                    .accessibilityHint("手動で地点を設定")

                    Button("現在地へ") {
                        moveCameraToCurrentOrSelectedLocation()
                    }
                    .accessibilityHint("現在地が使えない場合は設定地点に移動")

                    Button("現在地を地点に設定") {
                        if !store.setSelectedLocationToCurrentCoordinate(name: "現在地") {
                            isShowingCurrentLocationUnavailableAlert = true
                        }
                    }
                    .accessibilityHint("現在地座標を地点として保存")
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
            .alert("現在地が取得できません", isPresented: $isShowingCurrentLocationUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("位置情報の許可を確認し、Map画面を開いた状態でしばらく待ってから再度お試しください。")
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("盤オーバーレイ透明度")
                Slider(value: $store.displaySettings.overlayOpacity, in: 0...1)
                    .accessibilityLabel("盤オーバーレイ透明度")
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
            .accessibilityLabel("地図スタイル")

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
        // 地図の自動同期は、ユーザーが選んだ手動地点を常に優先する。
        // GPS現在地は「現在地へ」ボタン押下時のみ利用し、選択地点を上書きしない。
        let target = store.selectedLocation.coordinate
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
                    .accessibilityLabel("中心ピン")
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
