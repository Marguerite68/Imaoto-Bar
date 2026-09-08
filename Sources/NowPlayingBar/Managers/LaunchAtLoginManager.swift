import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    private enum ErrorState {
        case approvalRequired
        case enableFailed(String)
        case disableFailed(String)
    }

    @Published private(set) var isEnabled: Bool
    @Published private var errorState: ErrorState?

    var errorMessage: String? {
        switch errorState {
        case .approvalRequired:
            L10n.text(.launchAtLoginApproval)
        case .enableFailed(let message):
            String(format: L10n.text(.enableLaunchAtLoginFailed), message)
        case .disableFailed(let message):
            String(format: L10n.text(.disableLaunchAtLoginFailed), message)
        case nil:
            nil
        }
    }

    init() {
        isEnabled = Self.status == .enabled
        errorState = nil
    }

    func refresh() {
        isEnabled = Self.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            isEnabled = Self.status == .enabled
            errorState = enabled && Self.status == .requiresApproval
                ? .approvalRequired
                : nil
        } catch {
            isEnabled = Self.status == .enabled
            errorState = enabled
                ? .enableFailed(error.localizedDescription)
                : .disableFailed(error.localizedDescription)
        }
    }

    private static var status: SMAppService.Status {
        SMAppService.mainApp.status
    }
}
