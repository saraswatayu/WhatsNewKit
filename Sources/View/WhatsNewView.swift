import SwiftUI

// MARK: - WhatsNewView

/// A WhatsNewView
public struct WhatsNewView {
    
    // MARK: Properties
    
    /// The WhatsNew object
    private let whatsNew: WhatsNew
    
    /// The WhatsNewVersionStore
    private let whatsNewVersionStore: WhatsNewVersionStore?
    
    /// The WhatsNew Layout
    private let layout: WhatsNew.Layout
    
    /// The View that is presented by the SecondaryAction
    @State
    private var secondaryActionPresentedView: WhatsNew.SecondaryAction.Action.PresentedView?
    
    /// The PresentationMode
    @Environment(\.presentationMode)
    private var presentationMode
    
    // MARK: Initializer
    
    /// Creates a new instance of `WhatsNewView`
    /// - Parameters:
    ///   - whatsNew: The WhatsNew object
    ///   - versionStore: The optional WhatsNewVersionStore. Default value `nil`
    ///   - layout: The WhatsNew Layout. Default value `.default`
    public init(
        whatsNew: WhatsNew,
        versionStore: WhatsNewVersionStore? = nil,
        layout: WhatsNew.Layout = .default
    ) {
        self.whatsNew = whatsNew
        self.whatsNewVersionStore = versionStore
        self.layout = layout
    }
    
}

// MARK: - View

extension WhatsNewView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        ZStack {
            // Content ScrollView
            ScrollView(
                .vertical,
                showsIndicators: self.layout.showsScrollViewIndicators
            ) {
                // Content Stack
                VStack(
                    spacing: self.layout.contentSpacing
                ) {
                    // Title
                    self.title
                    // Feature List
                    VStack(
                        alignment: .leading,
                        spacing: self.layout.featureListSpacing
                    ) {
                        // Feature
                        ForEach(
                            self.whatsNew.features,
                            id: \.self,
                            content: self.feature
                        )
                    }
                    .modifier(FeaturesPadding())
                    .padding(self.layout.featureListPadding)
                }
                .padding(.horizontal)
                .padding(self.layout.contentPadding)
                // ScrollView bottom content inset
                Color.clear
                    .padding(
                        .bottom,
                        self.layout.scrollViewBottomContentInset
                    )
            }
            .alwaysBounceVertical(false)
            
            // Footer
            VStack {
                Spacer()
                self.footer
                    .modifier(FooterPadding())
                    #if os(iOS)
                    .background(
                        UIVisualEffectView
                            .Representable()
                            .edgesIgnoringSafeArea(.horizontal)
                            .padding(self.layout.footerVisualEffectViewPadding)
                    )
                    #endif
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(
            item: self.$secondaryActionPresentedView,
            content: { $0.view }
        )
        .onDisappear {
            // Save presented WhatsNew Version, if available
            self.whatsNewVersionStore?.save(
                presentedVersion: self.whatsNew.version
            )
        }
    }
    
}

// MARK: - Title

private extension WhatsNewView {
    
    /// The Title View
    var title: some View {
        Text(
            text: self.whatsNew.title.text
        )
        .font(.title.bold())
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }
    
}

// MARK: - Feature

private extension WhatsNewView {
    
    /// The Feature View
    /// - Parameter feature: A WhatsNew Feature
    func feature(
        _ feature: WhatsNew.Feature
    ) -> some View {
        HStack(
            alignment: self.layout.featureHorizontalAlignment,
            spacing: self.layout.featureHorizontalSpacing
        ) {
            feature
                .image
                .view()
                .frame(width: self.layout.featureImageWidth)
            VStack(
                alignment: .leading,
                spacing: self.layout.featureVerticalSpacing
            ) {
                Text(
                    whatsNewText: feature.title
                )
                .font(.body.bold())
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                
                Text(
                    whatsNewText: feature.subtitle
                )
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.leading)
        }.accessibilityElement(children: .combine)
    }
    
}

// MARK: - Footer

private extension WhatsNewView {
    
    /// The Footer View
    var footer: some View {
        VStack(
            spacing: self.layout.footerActionSpacing
        ) {
            // Check if a secondary action is available
            if let secondaryAction = self.whatsNew.secondaryAction {
                // Secondary Action Button
                Button(
                    action: {
                        // Invoke HapticFeedback, if available
                        secondaryAction.hapticFeedback?()
                        // Switch on Action
                        switch secondaryAction.action {
                        case .present(let view):
                            // Set secondary action presented view
                            self.secondaryActionPresentedView = .init(view: view)
                        case .custom(let action):
                            // Invoke action with PresentationMode
                            action(self.presentationMode)
                        }
                    }
                ) {
                    Text(
                        whatsNewText: secondaryAction.title
                    )
                }
                #if os(macOS)
                .buttonStyle(
                    PlainButtonStyle()
                )
                #endif
                .foregroundColor(secondaryAction.foregroundColor)
            }
            
            Button {
                whatsNew.primaryAction.hapticFeedback?()
                presentationMode.wrappedValue.dismiss()
                whatsNew.primaryAction.onDismiss?()
            } label: {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.black)
                    Text(text: whatsNew.primaryAction.title)
                        .font(.system(.body).weight(.bold).monospaced())
                        .foregroundColor(.white)
                        .padding([.top, .bottom], 16)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
}
