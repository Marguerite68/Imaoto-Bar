import AppKit
import SwiftUI

struct PreferencesView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var manager: NowPlayingManager
    @ObservedObject var audioQualityManager: AudioQualityManager
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager
    @State private var selectedTab: PreferencesTab = .display

    var body: some View {
        Group {
            switch selectedTab {
            case .display:
            DisplayPreferencesView(
                settings: settings,
                mediaInfo: manager.mediaInfo,
                audioQualityManager: audioQualityManager
            )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            case .general:
                GeneralPreferencesView(
                    settings: settings,
                    launchAtLoginManager: launchAtLoginManager
                )
                    .padding(20)

            case .about:
                AboutPreferencesView()
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 540, height: 500)
        .environment(\.locale, settings.language.locale)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker(
                    L10n.text(.preferences, language: settings.language),
                    selection: $selectedTab
                ) {
                    ForEach(PreferencesTab.allCases) { tab in
                        Text(tab.title(language: settings.language)).tag(tab)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 210)
                // AppKit retains toolbar items between SwiftUI body updates.
                // A language-specific identity replaces the cached segmented control.
                .id(settings.language)
            }
        }
    }
}

private enum PreferencesTab: CaseIterable, Identifiable {
    case display
    case general
    case about

    var id: Self { self }

    func title(language: AppLanguage) -> String {
        switch self {
        case .display: L10n.text(.display, language: language)
        case .general: L10n.text(.general, language: language)
        case .about: L10n.text(.about, language: language)
        }
    }
}

private struct DisplayPreferencesView: View {
    @ObservedObject var settings: AppSettings
    let mediaInfo: MediaInfo?
    @ObservedObject var audioQualityManager: AudioQualityManager
    @State private var maximumCharactersInput: String
    @FocusState private var isMaximumCharactersFieldFocused: Bool

    init(
        settings: AppSettings,
        mediaInfo: MediaInfo?,
        audioQualityManager: AudioQualityManager
    ) {
        _settings = ObservedObject(wrappedValue: settings)
        self.mediaInfo = mediaInfo
        _audioQualityManager = ObservedObject(wrappedValue: audioQualityManager)
        _maximumCharactersInput = State(initialValue: String(settings.maximumCharacters))
    }

    private var previewPresentation: StatusBarPresentation {
        let previewMedia = (mediaInfo ?? Self.previewMedia)
            .replacingPlaybackState(with: .playing)
        return StatusBarPresentation(
            mediaInfo: previewMedia,
            displayMode: settings.displayMode,
            hideStatusItemWhenNoMedia: settings.hideStatusItemWhenNoMedia,
            maximumCharacters: settings.maximumCharacters,
            scrollingEnabled: settings.scrollingEnabled,
            marqueeMode: settings.marqueeMode,
            scrollingSpeed: settings.scrollingSpeed,
            fontWeight: settings.fontWeight,
            audioQuality: audioQualityManager.quality
        )
    }

    var body: some View {
        Form {
            Section(L10n.text(.menuBarDisplay)) {
                Picker(L10n.text(.displayContent), selection: $settings.displayMode) {
                    ForEach(MenuBarDisplayMode.allCases) { mode in
                        VStack(alignment: .leading) {
                            Text(mode.displayName)
                            Text(mode.example)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)

                Toggle(
                    L10n.text(.hideWhenNoMedia),
                    isOn: $settings.hideStatusItemWhenNoMedia
                )

                Picker(L10n.text(.fontWeight), selection: $settings.fontWeight) {
                    ForEach(MenuBarFontWeight.allCases) { weight in
                        Text(weight.displayName).tag(weight)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(L10n.text(.scrollingDisplay)) {
                HStack(spacing: 8) {
                    Text(L10n.text(.maximumCharacters))
                        .font(.body)
                    Spacer(minLength: 16)

                    Button {
                        adjustMaximumCharacters(by: -MarqueeSettingRange.characterStep)
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(settings.maximumCharacters <= MarqueeSettingRange.minimumCharacters)

                    TextField("", text: $maximumCharactersInput)
                        .labelsHidden()
                        .frame(width: 42)
                        .multilineTextAlignment(.center)
                        .focused($isMaximumCharactersFieldFocused)
                        .onSubmit(commitMaximumCharactersInput)
                        .onChange(of: maximumCharactersInput) { newValue in
                            applyValidMaximumCharacters(newValue)
                        }

                    Button {
                        adjustMaximumCharacters(by: MarqueeSettingRange.characterStep)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(settings.maximumCharacters >= MarqueeSettingRange.maximumCharacters)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Text(
                    String(
                        format: L10n.text(.characterRange),
                        locale: settings.language.locale,
                        MarqueeSettingRange.minimumCharacters,
                        MarqueeSettingRange.maximumCharacters
                    )
                )
                .font(.caption)
                .foregroundColor(isMaximumCharactersInputValid ? .secondary : .red)

                Toggle(L10n.text(.autoScroll), isOn: $settings.scrollingEnabled)

                if settings.scrollingEnabled {
                    Picker(L10n.text(.scrollingMode), selection: $settings.marqueeMode) {
                        ForEach(MarqueeMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    LabeledContent(L10n.text(.scrollingSpeed)) {
                        HStack(spacing: 6) {
                            Image(systemName: "tortoise.fill")
                                .foregroundStyle(.secondary)
                            Slider(
                                value: $settings.scrollingSpeed,
                                in: MarqueeSettingRange.minimumSpeed...MarqueeSettingRange.maximumSpeed,
                                step: MarqueeSettingRange.speedStep
                            )
                            Image(systemName: "hare.fill")
                                .foregroundStyle(.secondary)
                            Text("\(Int(settings.scrollingSpeed)) pt/s")
                                .monospacedDigit()
                                .frame(width: 58, alignment: .trailing)
                        }
                    }
                }
            }

            Section(L10n.text(.qualityRecognition)) {
                Toggle(
                    L10n.text(.showAppleMusicQuality),
                    isOn: Binding(
                        get: { settings.audioQualityRecognitionEnabled },
                        set: { enabled in
                            audioQualityManager.setRecognitionEnabled(
                                enabled,
                                promptForPermission: enabled
                            )
                        }
                    )
                )

                if settings.audioQualityRecognitionEnabled {
                    Text(L10n.text(.qualityRecognitionHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if audioQualityManager.unavailableReason == .accessibilityPermissionRequired {
                        Button(L10n.text(.openAccessibilitySettings)) {
                            AccessibilitySettingsOpener.open()
                        }
                        .controlSize(.small)
                    }
                }
            }

            Section(L10n.text(.preview)) {
                HStack(spacing: 6) {
                    Image(systemName: previewPresentation.iconName)
                    if !previewPresentation.title.isEmpty {
                        MarqueeTextPreview(presentation: previewPresentation)
                            .frame(
                                width: previewPresentation.textViewportWidth,
                                height: 18
                            )
                    }
                    if let quality = audioQualityManager.quality {
                        QualityBadgeView(tier: quality.tier)
                    }
                }
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 7))

                Text(L10n.text(.settingsApplyImmediately))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if mediaInfo == nil {
                    Label(
                        L10n.text(.noMediaWarning),
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            clearMaximumCharactersFocus()
        }
        .onDisappear {
            isMaximumCharactersFieldFocused = false
        }
        .onChange(of: isMaximumCharactersFieldFocused) { isFocused in
            if !isFocused {
                commitMaximumCharactersInput()
            }
        }
        .onChange(of: settings.maximumCharacters) { newValue in
            if !isMaximumCharactersFieldFocused {
                maximumCharactersInput = String(newValue)
            }
        }
    }

    private var isMaximumCharactersInputValid: Bool {
        guard let value = Int(maximumCharactersInput) else { return false }
        return (MarqueeSettingRange.minimumCharacters...MarqueeSettingRange.maximumCharacters)
            .contains(value)
    }

    private func clearMaximumCharactersFocus() {
        isMaximumCharactersFieldFocused = false
        DispatchQueue.main.async {
            isMaximumCharactersFieldFocused = false
        }
    }

    private func applyValidMaximumCharacters(_ input: String) {
        guard let value = Int(input),
              (MarqueeSettingRange.minimumCharacters...MarqueeSettingRange.maximumCharacters)
                .contains(value) else { return }
        settings.maximumCharacters = value
    }

    private func commitMaximumCharactersInput() {
        let enteredValue = Int(maximumCharactersInput) ?? settings.maximumCharacters
        let clampedValue = min(
            max(enteredValue, MarqueeSettingRange.minimumCharacters),
            MarqueeSettingRange.maximumCharacters
        )
        settings.maximumCharacters = clampedValue
        maximumCharactersInput = String(clampedValue)
    }

    private func adjustMaximumCharacters(by delta: Int) {
        let newValue = min(
            max(
                settings.maximumCharacters + delta,
                MarqueeSettingRange.minimumCharacters
            ),
            MarqueeSettingRange.maximumCharacters
        )
        settings.maximumCharacters = newValue
        maximumCharactersInput = String(newValue)
    }

    private static let previewMedia = MediaInfo(
        id: "settings-preview",
        title: "Blinding Lights (Live From ImaotoBar)",
        artist: "The Weeknd",
        album: "After Hours",
        application: .appleMusic,
        playbackState: .playing
    )
}

private struct GeneralPreferencesView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager

    var body: some View {
        Form {
            Section(L10n.text(.general)) {
                Picker(L10n.text(.language), selection: $settings.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }

                Toggle(
                    L10n.text(.launchAtLogin),
                    isOn: Binding(
                        get: { launchAtLoginManager.isEnabled },
                        set: { launchAtLoginManager.setEnabled($0) }
                    )
                )

                if let errorMessage = launchAtLoginManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section(L10n.text(.mediaPriority)) {
                List {
                    ForEach(
                        Array(settings.mediaSourcePriority.enumerated()),
                        id: \.element.id
                    ) { index, source in
                        MediaSourcePriorityRow(
                            source: source,
                            priority: index + 1
                        )
                        .listRowInsets(
                            EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
                        )
                        .listRowBackground(Color.clear)
                    }
                    .onMove { sourceOffsets, destinationOffset in
                        settings.mediaSourcePriority.move(
                            fromOffsets: sourceOffsets,
                            toOffset: destinationOffset
                        )
                    }
                }
                .environment(\.defaultMinListRowHeight, 30)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .frame(height: CGFloat(settings.mediaSourcePriority.count) * 32)

                Text(L10n.text(.mediaPriorityHint))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            launchAtLoginManager.refresh()
        }
    }

}

private struct MediaSourcePriorityRow: View {
    let source: MediaSource
    let priority: Int

    var body: some View {
        HStack(spacing: 8) {
            MediaSourceIcon(source: source, applicationURL: applicationURL)
                .frame(width: 20, height: 20)

            Text(source.displayName)
                .font(.callout)

            Spacer()

            if applicationURL == nil {
                Text(L10n.text(.notInstalled))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }

            Text("\(priority)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 12, alignment: .trailing)

            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .frame(minHeight: 28)
        .contentShape(Rectangle())
    }

    private var applicationURL: URL? {
        guard let url = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: source.bundleIdentifier
        ), FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }
}

private struct MediaSourceIcon: View {
    let source: MediaSource
    let applicationURL: URL?

    var body: some View {
        Group {
            if let icon = applicationIcon {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: source.fallbackSymbolName)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityHidden(true)
    }

    private var applicationIcon: NSImage? {
        guard let applicationURL else { return nil }
        return NSWorkspace.shared.icon(forFile: applicationURL.path)
    }
}

private struct AboutPreferencesView: View {
    private let repositoryURL = URL(
        string: "https://github.com/Marguerite68/Imaoto-Bar"
    )!

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            Text("ImaotoBar")
                .font(.title2.weight(.semibold))
            Text("Version 0.1.1")
                .foregroundStyle(.secondary)
            Text(L10n.text(.appDescription))
                .font(.callout)
                .foregroundStyle(.secondary)

            Link(destination: repositoryURL) {
                GitHubIcon()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
            .help(L10n.text(.openRepository))
            .accessibilityLabel(L10n.text(.openRepository))

            (Text("Made with ") + Text("❤️") + Text(" by Marguerite"))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct GitHubIcon: View {
    private static let image = Bundle.main
        .url(forResource: "github", withExtension: "svg", subdirectory: "Assets")
        .flatMap(NSImage.init(contentsOf:))

    var body: some View {
        Group {
            if let image = Self.image {
                Image(nsImage: image)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
            } else {
                Image(systemName: "link")
            }
        }
        .foregroundStyle(.primary)
    }
}
