import Foundation

enum MenuBarDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case iconOnly
    case title
    case titleAndArtist

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .iconOnly:
            L10n.text(.iconOnly)
        case .title:
            L10n.text(.iconAndTitle)
        case .titleAndArtist:
            L10n.text(.iconAndTitleAndArtist)
        }
    }

    var example: String {
        switch self {
        case .iconOnly:
            "♫"
        case .title:
            "♫ Blinding Lights"
        case .titleAndArtist:
            "♫ Blinding Lights · The Weeknd"
        }
    }

    func text(for mediaInfo: MediaInfo?) -> String? {
        guard self != .iconOnly else { return nil }
        guard let mediaInfo else { return nil }

        switch self {
        case .iconOnly:
            return nil
        case .title:
            return mediaInfo.title
        case .titleAndArtist:
            return mediaInfo.menuBarText
        }
    }
}

enum MarqueeMode: String, CaseIterable, Identifiable, Sendable {
    case loop
    case pingPong

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .loop: L10n.text(.loop)
        case .pingPong: L10n.text(.pingPong)
        }
    }
}

enum MenuBarFontWeight: String, CaseIterable, Identifiable, Sendable {
    case regular
    case medium
    case semibold
    case bold

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .regular: L10n.text(.regular)
        case .medium: L10n.text(.medium)
        case .semibold: L10n.text(.semibold)
        case .bold: L10n.text(.bold)
        }
    }
}

enum MarqueeSettingRange {
    static let minimumCharacters = 8
    static let maximumCharacters = 30
    static let characterStep = 1
    static let minimumSpeed = 12.0
    static let maximumSpeed = 60.0
    static let speedStep = 2.0
}

@MainActor
final class AppSettings: ObservableObject {
    private enum Key {
        static let displayMode = "menuBarDisplayMode"
        static let hideStatusItemWhenNoMedia = "hideStatusItemWhenNoMedia"
        static let maximumCharacters = "maximumCharacters"
        static let scrollingEnabled = "scrollingEnabled"
        static let marqueeMode = "marqueeMode"
        static let scrollingSpeed = "scrollingSpeed"
        static let fontWeight = "fontWeight"
        static let audioQualityRecognitionEnabled = "audioQualityRecognitionEnabled"
        static let didRequestAudioQualityAccessibility = "didRequestAudioQualityAccessibility"
        static let mediaSourcePriority = "mediaSourcePriority"
        static let language = "appLanguage"
    }

    @Published var displayMode: MenuBarDisplayMode {
        didSet { defaults.set(displayMode.rawValue, forKey: Key.displayMode) }
    }

    @Published var hideStatusItemWhenNoMedia: Bool {
        didSet { defaults.set(hideStatusItemWhenNoMedia, forKey: Key.hideStatusItemWhenNoMedia) }
    }

    @Published var maximumCharacters: Int {
        didSet { defaults.set(maximumCharacters, forKey: Key.maximumCharacters) }
    }

    @Published var scrollingEnabled: Bool {
        didSet { defaults.set(scrollingEnabled, forKey: Key.scrollingEnabled) }
    }

    @Published var marqueeMode: MarqueeMode {
        didSet { defaults.set(marqueeMode.rawValue, forKey: Key.marqueeMode) }
    }

    @Published var scrollingSpeed: Double {
        didSet { defaults.set(scrollingSpeed, forKey: Key.scrollingSpeed) }
    }

    @Published var fontWeight: MenuBarFontWeight {
        didSet { defaults.set(fontWeight.rawValue, forKey: Key.fontWeight) }
    }

    @Published var audioQualityRecognitionEnabled: Bool {
        didSet {
            defaults.set(
                audioQualityRecognitionEnabled,
                forKey: Key.audioQualityRecognitionEnabled
            )
        }
    }

    @Published var mediaSourcePriority: [MediaSource] {
        didSet {
            defaults.set(
                mediaSourcePriority.map(\.rawValue),
                forKey: Key.mediaSourcePriority
            )
        }
    }

    @Published var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Key.language) }
    }

    var didRequestAudioQualityAccessibility: Bool {
        didSet {
            defaults.set(
                didRequestAudioQualityAccessibility,
                forKey: Key.didRequestAudioQualityAccessibility
            )
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        displayMode = defaults.string(forKey: Key.displayMode)
            .flatMap(MenuBarDisplayMode.init(rawValue:)) ?? .titleAndArtist

        if defaults.object(forKey: Key.hideStatusItemWhenNoMedia) == nil {
            hideStatusItemWhenNoMedia = false
        } else {
            hideStatusItemWhenNoMedia = defaults.bool(forKey: Key.hideStatusItemWhenNoMedia)
        }

        let storedMaximumCharacters = defaults.integer(forKey: Key.maximumCharacters)
        maximumCharacters = storedMaximumCharacters == 0 ? 20 : min(
            max(storedMaximumCharacters, MarqueeSettingRange.minimumCharacters),
            MarqueeSettingRange.maximumCharacters
        )
        scrollingEnabled = defaults.object(forKey: Key.scrollingEnabled) == nil
            ? true
            : defaults.bool(forKey: Key.scrollingEnabled)
        marqueeMode = defaults.string(forKey: Key.marqueeMode)
            .flatMap(MarqueeMode.init(rawValue:)) ?? .loop
        let storedSpeed = defaults.double(forKey: Key.scrollingSpeed)
        scrollingSpeed = storedSpeed == 0 ? 28 : min(
            max(storedSpeed, MarqueeSettingRange.minimumSpeed),
            MarqueeSettingRange.maximumSpeed
        )
        fontWeight = defaults.string(forKey: Key.fontWeight)
            .flatMap(MenuBarFontWeight.init(rawValue:)) ?? .medium
        audioQualityRecognitionEnabled = defaults.bool(
            forKey: Key.audioQualityRecognitionEnabled
        )
        didRequestAudioQualityAccessibility = defaults.bool(
            forKey: Key.didRequestAudioQualityAccessibility
        )
        mediaSourcePriority = MediaSource.normalizedPriority(
            from: defaults.stringArray(forKey: Key.mediaSourcePriority)
        )
        language = defaults.string(forKey: Key.language)
            .flatMap(AppLanguage.init(rawValue:)) ?? .simplifiedChinese
    }

    init(
        transientDisplayMode: MenuBarDisplayMode,
        hideStatusItemWhenNoMedia: Bool = false,
        maximumCharacters: Int = 20,
        scrollingEnabled: Bool = true,
        marqueeMode: MarqueeMode = .loop,
        scrollingSpeed: Double = 28,
        fontWeight: MenuBarFontWeight = .medium,
        audioQualityRecognitionEnabled: Bool = false,
        mediaSourcePriority: [MediaSource] = MediaSource.allCases,
        language: AppLanguage = .simplifiedChinese
    ) {
        defaults = .standard
        displayMode = transientDisplayMode
        self.hideStatusItemWhenNoMedia = hideStatusItemWhenNoMedia
        self.maximumCharacters = maximumCharacters
        self.scrollingEnabled = scrollingEnabled
        self.marqueeMode = marqueeMode
        self.scrollingSpeed = scrollingSpeed
        self.fontWeight = fontWeight
        self.audioQualityRecognitionEnabled = audioQualityRecognitionEnabled
        didRequestAudioQualityAccessibility = false
        self.mediaSourcePriority = mediaSourcePriority
        self.language = language
    }
}
