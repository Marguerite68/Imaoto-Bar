import AppKit
import QuartzCore
import SwiftUI

private struct MarqueeRenderState: Equatable {
    let title: String
    let fullText: String
    let viewportWidth: CGFloat
    let shouldScroll: Bool
    let isPlaying: Bool
    let trackID: String
    let mode: MarqueeMode
    let speed: CGFloat
    let fontWeight: MenuBarFontWeight
}

private struct TemplateTextRenderState: Equatable {
    let text: String
    let minimumWidth: CGFloat
    let fontWeight: MenuBarFontWeight
}

@MainActor
final class MarqueeLayerView: NSView {
    private static let animationKey = "NowPlayingBar.marquee"
    private let textImageView = NSImageView()
    private var renderState: MarqueeRenderState?
    private var templateRenderState: TemplateTextRenderState?
    private var needsAnimationRestart = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true

        textImageView.imageAlignment = .alignLeft
        textImageView.imageScaling = .scaleNone
        textImageView.wantsLayer = true
        addSubview(textImageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func layout() {
        super.layout()
        guard let renderState else { return }

        let contentLayout = MarqueeContentLayout.make(
            text: renderState.fullText,
            viewportWidth: bounds.width,
            mode: renderState.mode,
            fontWeight: renderState.fontWeight
        )
        let renderedText = renderState.shouldScroll
            ? contentLayout.renderedText
            : renderState.title
        let newTemplateRenderState = TemplateTextRenderState(
            text: renderedText,
            minimumWidth: bounds.width,
            fontWeight: renderState.fontWeight
        )
        if newTemplateRenderState != templateRenderState {
            templateRenderState = newTemplateRenderState
            textImageView.image = MenuBarTemplateImageRenderer.textImage(
                text: renderedText,
                font: .systemFont(
                    ofSize: MenuBarLayout.fontSize,
                    weight: renderState.fontWeight.nsWeight
                ),
                height: 17,
                minimumWidth: bounds.width
            )
        }
        let textWidth = textImageView.image?.size.width ?? bounds.width
        textImageView.frame = CGRect(
            x: 0,
            y: floor((bounds.height - 17) / 2),
            width: textWidth,
            height: 17
        )

        if needsAnimationRestart {
            installAnimationIfNeeded()
        }
    }

    func update(with presentation: StatusBarPresentation) {
        let newState = MarqueeRenderState(
            title: presentation.title,
            fullText: presentation.fullText,
            viewportWidth: presentation.textViewportWidth,
            shouldScroll: presentation.shouldScroll,
            isPlaying: presentation.isPlaying,
            trackID: presentation.trackID,
            mode: presentation.marqueeMode,
            speed: presentation.scrollingSpeed,
            fontWeight: presentation.fontWeight
        )
        guard newState != renderState else { return }

        renderState = newState
        templateRenderState = nil
        stopAndReset()
        needsLayout = true

        if newState.shouldScroll && newState.isPlaying {
            needsAnimationRestart = true
            layoutSubtreeIfNeeded()
        }
    }

    func stopAndReset() {
        textImageView.layer?.removeAnimation(forKey: Self.animationKey)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        textImageView.layer?.setAffineTransform(.identity)
        CATransaction.commit()
        needsAnimationRestart = false
    }

    private func installAnimationIfNeeded() {
        guard let renderState,
              renderState.shouldScroll,
              renderState.isPlaying,
              bounds.width > 0 else { return }

        let contentLayout = MarqueeContentLayout.make(
            text: renderState.fullText,
            viewportWidth: bounds.width,
            mode: renderState.mode,
            fontWeight: renderState.fontWeight
        )
        guard let plan = MarqueeAnimationPlan.make(
            travelDistance: contentLayout.travelDistance,
            mode: renderState.mode,
            pointsPerSecond: renderState.speed
        ) else {
            needsAnimationRestart = false
            return
        }

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = plan.values
        animation.keyTimes = plan.keyTimes
        animation.duration = plan.duration
        animation.repeatCount = .infinity
        animation.calculationMode = .linear
        animation.isRemovedOnCompletion = false
        textImageView.layer?.add(animation, forKey: Self.animationKey)
        needsAnimationRestart = false
    }
}

@MainActor
final class StatusItemContentView: NSView {
    private let iconView = NSImageView()
    private let marqueeView = MarqueeLayerView()
    private let qualityBadgeView = QualityBadgeNSView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(iconView)
        addSubview(marqueeView)
        addSubview(qualityBadgeView)
        iconView.imageScaling = .scaleProportionallyDown
        qualityBadgeView.isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func layout() {
        super.layout()
        let iconX = MenuBarLayout.horizontalPadding
        iconView.frame = CGRect(
            x: iconX,
            y: floor((bounds.height - MenuBarLayout.iconWidth) / 2),
            width: MenuBarLayout.iconWidth,
            height: MenuBarLayout.iconWidth
        )
        let badgeSpacing: CGFloat = qualityBadgeView.isHidden ? 0 : 5
        let badgeWidth = qualityBadgeView.isHidden ? 0 : qualityBadgeView.badgeWidth
        qualityBadgeView.frame = CGRect(
            x: bounds.width - MenuBarLayout.horizontalPadding - badgeWidth,
            y: floor((bounds.height - 14) / 2),
            width: badgeWidth,
            height: 14
        )
        marqueeView.frame = CGRect(
            x: iconView.frame.maxX + MenuBarLayout.iconTextSpacing,
            y: 0,
            width: max(0, bounds.width - iconView.frame.maxX
                - MenuBarLayout.iconTextSpacing - MenuBarLayout.horizontalPadding
                - badgeSpacing - badgeWidth),
            height: bounds.height
        )
    }

    func update(with presentation: StatusBarPresentation) {
        let image = NSImage(
            systemSymbolName: presentation.iconName,
            accessibilityDescription: "NowPlayingBar"
        )
        image?.isTemplate = true
        iconView.image = image
        qualityBadgeView.update(tier: presentation.qualityBadge)
        marqueeView.isHidden = presentation.title.isEmpty
        marqueeView.update(with: presentation)
        needsLayout = true
    }
}

@MainActor
private final class QualityBadgeNSView: NSView {
    private var tier: AudioQualityTier?
    private let imageView = NSImageView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        imageView.imageScaling = .scaleProportionallyDown
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var badgeWidth: CGFloat {
        tier?.badgeWidth ?? 0
    }

    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func layout() {
        super.layout()
        imageView.frame = bounds
    }

    func update(tier: AudioQualityTier?) {
        guard self.tier != tier else { return }
        self.tier = tier
        isHidden = tier == nil
        imageView.image = tier.map { tier in
            AudioQualityBadgeAsset.image(for: tier)
                ?? MenuBarTemplateImageRenderer.qualityBadgeImage(
                    tier: tier,
                    size: NSSize(width: tier.badgeWidth, height: 14)
                )
        }
        imageView.isHidden = tier == nil
        needsDisplay = true
    }
}

struct MarqueeTextPreview: NSViewRepresentable {
    let presentation: StatusBarPresentation

    func makeNSView(context: Context) -> MarqueeLayerView {
        MarqueeLayerView()
    }

    func updateNSView(_ nsView: MarqueeLayerView, context: Context) {
        nsView.update(with: presentation)
    }

    static func dismantleNSView(_ nsView: MarqueeLayerView, coordinator: ()) {
        nsView.stopAndReset()
    }
}
