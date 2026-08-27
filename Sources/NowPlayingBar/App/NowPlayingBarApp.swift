import SwiftUI

@main
@MainActor
struct ImaotoBarApp: App {
    @StateObject private var manager: NowPlayingManager
    @StateObject private var settings: AppSettings
    @StateObject private var audioQualityManager: AudioQualityManager
    @StateObject private var launchAtLoginManager: LaunchAtLoginManager
    @StateObject private var statusBarController: StatusBarController

    init() {
        let settings = AppSettings()
        let manager = NowPlayingManager(provider: SystemNowPlayingProvider())
        let launchAtLoginManager = LaunchAtLoginManager()
        let audioQualityManager = AudioQualityManager(
            mediaManager: manager,
            settings: settings,
            provider: AppleMusicAccessibilityQualityProvider()
        )

        _settings = StateObject(wrappedValue: settings)
        _manager = StateObject(wrappedValue: manager)
        _audioQualityManager = StateObject(wrappedValue: audioQualityManager)
        _launchAtLoginManager = StateObject(wrappedValue: launchAtLoginManager)
        _statusBarController = StateObject(
            wrappedValue: StatusBarController(
                manager: manager,
                settings: settings,
                audioQualityManager: audioQualityManager,
                launchAtLoginManager: launchAtLoginManager
            )
        )
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
