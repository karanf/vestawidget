//
//  MessageComposerViewModel.swift
//  VestaWidget
//
//  ViewModel for composing and posting messages to Vestaboard
//  Handles validation, posting, templates, and message history
//

import Foundation
import Combine
import WidgetKit

/// ViewModel for message composition and posting
@MainActor
class MessageComposerViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current message text being composed
    @Published var messageText: String = "" {
        didSet {
            validateMessage()
        }
    }

    /// Whether a post operation is in progress
    @Published var isPosting: Bool = false

    /// Current error message
    @Published var errorMessage: String?

    /// Current success message
    @Published var successMessage: String?

    /// Whether the message is valid for posting
    @Published var isValid: Bool = false

    /// Array of unsupported characters in current message
    @Published var unsupportedCharacters: [Character] = []

    /// Message history
    @Published var messageHistory: [VestaboardMessage] = []

    /// Saved templates
    @Published var templates: [MessageTemplate] = []

    /// Whether to show template sheet
    @Published var showingTemplates: Bool = false

    /// Whether to show save template sheet
    @Published var showingSaveTemplate: Bool = false

    // MARK: - Private Properties

    private let api: VestaboardAPI
    private let keychain = KeychainService.shared
    private let storage = AppGroupStorage.shared

    // MARK: - Initialization

    init(api: VestaboardAPI = VestaboardAPI()) {
        self.api = api
        loadHistory()
        loadTemplates()
    }

    // MARK: - Computed Properties

    /// Character count of current message
    var characterCount: Int {
        return messageText.count
    }

    /// Whether message exceeds maximum length
    var exceedsMaxLength: Bool {
        return characterCount > AppConstants.maxMessageLength
    }

    /// Character count display string
    var characterCountText: String {
        return "\(characterCount) / \(AppConstants.maxMessageLength)"
    }

    /// Preview of how message will appear on board
    var messagePreview: [[Int]] {
        return VestaboardCharacterSet.boardLayout(for: messageText)
    }

    // MARK: - Public Methods

    /// Validates the current message
    private func validateMessage() {
        // Check if empty
        guard !messageText.isBlankOrEmpty else {
            isValid = false
            unsupportedCharacters = []
            return
        }

        // Check length
        guard !exceedsMaxLength else {
            isValid = false
            return
        }

        // Check for unsupported characters
        let unsupported = VestaboardCharacterSet.unsupportedCharacters(in: messageText)
        unsupportedCharacters = unsupported
        isValid = unsupported.isEmpty
    }

    /// Posts the current message to Vestaboard
    func postMessage() async {
        guard isValid else {
            errorMessage = "Please fix validation errors before sending"
            return
        }

        do {
            // Get credentials
            let config = try keychain.retrieve()

            // Update state
            isPosting = true
            errorMessage = nil
            successMessage = nil

            // Post message
            try await api.postMessage(
                text: messageText,
                apiKey: config.apiKey,
                apiSecret: config.apiSecret
            )

            // Save to history
            var message = VestaboardMessage(text: messageText, status: .sent)
            message.markAsSent()
            try storage.addToHistory(message)

            // Fetch updated content for widgets
            let content = try await api.getCurrentMessage(
                apiKey: config.apiKey,
                apiSecret: config.apiSecret
            )
            try storage.saveContent(content)

            // Update widgets
            WidgetCenter.shared.reloadAllTimelines()

            // Update UI
            successMessage = AppConstants.SuccessMessages.messageSent
            messageText = ""  // Clear input
            loadHistory()  // Refresh history

            // Haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif

        } catch {
            errorMessage = error.userFriendlyMessage

            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            #endif
        }

        isPosting = false
    }

    /// Sanitizes the current message by replacing unsupported characters
    func sanitizeMessage() {
        messageText = VestaboardCharacterSet.sanitize(messageText)
    }

    /// Loads message history from storage
    func loadHistory() {
        messageHistory = storage.retrieveMessageHistory()
    }

    /// Clears message history
    func clearHistory() {
        storage.clearHistory()
        messageHistory = []
    }

    /// Loads a message from history
    /// - Parameter message: Message to load
    func loadMessage(_ message: VestaboardMessage) {
        messageText = message.text
    }

    /// Resends a failed message
    /// - Parameter message: Message to resend
    func resendMessage(_ message: VestaboardMessage) async {
        messageText = message.text
        await postMessage()
    }

    // MARK: - Template Methods

    /// Loads templates from storage
    func loadTemplates() {
        templates = storage.retrieveTemplates()
    }

    /// Saves current message as a template
    /// - Parameter name: Name for the template
    func saveAsTemplate(name: String) {
        guard !messageText.isBlankOrEmpty else { return }
        guard !name.isBlankOrEmpty else {
            errorMessage = "Please enter a template name"
            return
        }

        let template = MessageTemplate(name: name, text: messageText)

        do {
            try storage.addTemplate(template)
            loadTemplates()
            successMessage = AppConstants.SuccessMessages.templateSaved
            showingSaveTemplate = false
        } catch {
            errorMessage = "Failed to save template: \(error.localizedDescription)"
        }
    }

    /// Loads a template into the composer
    /// - Parameter template: Template to load
    func loadTemplate(_ template: MessageTemplate) {
        messageText = template.text

        // Update usage count
        var updatedTemplate = template
        updatedTemplate.recordUsage()

        do {
            try storage.updateTemplate(updatedTemplate)
            loadTemplates()
        } catch {
            // Silently fail - not critical
        }

        showingTemplates = false
    }

    /// Deletes a template
    /// - Parameter template: Template to delete
    func deleteTemplate(_ template: MessageTemplate) {
        do {
            try storage.removeTemplate(withID: template.id)
            loadTemplates()
            successMessage = AppConstants.SuccessMessages.templateDeleted
        } catch {
            errorMessage = "Failed to delete template: \(error.localizedDescription)"
        }
    }

    /// Clears all messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
