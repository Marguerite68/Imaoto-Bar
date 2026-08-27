import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var errorMessage: String?

    init() {
        isEnabled = Self.status == .enabled
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
            errorMessage = enabled && Self.status == .requiresApproval
                ? "请在“系统设置 → 通用 → 登录项”中允许 ImaotoBar 开机自启。"
                : nil
        } catch {
            isEnabled = Self.status == .enabled
            errorMessage = enabled
                ? "无法开启开机自启：\(error.localizedDescription)"
                : "无法关闭开机自启：\(error.localizedDescription)"
        }
    }

    private static var status: SMAppService.Status {
        SMAppService.mainApp.status
    }
}
