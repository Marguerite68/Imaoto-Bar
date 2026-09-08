import Foundation

enum AudioQualityTier: String, Hashable, Sendable {
    case lossless
    case hiResLossless

    var displayName: String {
        switch self {
        case .lossless: L10n.text(.lossless)
        case .hiResLossless: L10n.text(.hiResLossless)
        }
    }

    var badgeText: String {
        switch self {
        case .lossless: "LOSSLESS"
        case .hiResLossless: "HI-RES"
        }
    }

    var badgeWidth: CGFloat {
        switch self {
        case .lossless: 47
        case .hiResLossless: 45
        }
    }

    var appleMusicAssetName: String {
        switch self {
        case .lossless: "audioBadgeLosslessTemplate"
        case .hiResLossless: "audioBadgeHi-ResLosslessTemplate"
        }
    }
}

struct VerifiedAudioQuality: Equatable, Sendable {
    let tier: AudioQualityTier
    let sampleRate: Int?
    let bitDepth: Int?
    let bitRate: Int?
    let evidenceDescription: String
    let providerIdentifier: String
}

enum AudioQualityUnavailableReason: Equatable, Sendable {
    case accessibilityPermissionRequired
    case noCurrentMedia
    case unsupportedSource
    case noPlaybackEvidence
    case providerUnavailable

    var explanation: String {
        switch self {
        case .accessibilityPermissionRequired:
            L10n.text(.accessibilityPermissionExplanation)
        case .noCurrentMedia:
            L10n.text(.noCurrentMediaExplanation)
        case .unsupportedSource:
            L10n.text(.unsupportedSourceExplanation)
        case .noPlaybackEvidence:
            L10n.text(.noPlaybackEvidenceExplanation)
        case .providerUnavailable:
            L10n.text(.providerUnavailableExplanation)
        }
    }
}

enum AudioQualityDetailsState: Equatable, Sendable {
    case hidden
    case verified(VerifiedAudioQuality)
    case unavailable(AudioQualityUnavailableReason)

    init(
        recognitionEnabled: Bool,
        quality: VerifiedAudioQuality?,
        unavailableReason: AudioQualityUnavailableReason
    ) {
        guard recognitionEnabled else {
            self = .hidden
            return
        }
        if let quality {
            self = .verified(quality)
        } else {
            self = .unavailable(unavailableReason)
        }
    }
}
