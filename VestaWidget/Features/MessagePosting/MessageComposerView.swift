//
//  MessageComposerView.swift
//  VestaWidget
//
//  SwiftUI view for composing and posting messages to Vestaboard
//  Includes text input, validation, preview, and template support
//

import SwiftUI

/// Main view for composing and sending messages to Vestaboard
struct MessageComposerView: View {

    // MARK: - Properties

    @StateObject private var viewModel = MessageComposerViewModel()
    @State private var showingHistory = false
    @State private var templateName = ""

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // Message Input Section
                messageInputSection

                // Character Counter & Validation
                validationSection

                // Preview Section
                previewSection

                // Actions Section
                actionsSection

                // Messages Section
                if viewModel.errorMessage != nil || viewModel.successMessage != nil {
                    messagesSection
                }

                // Quick Actions Section
                quickActionsSection
            }
            .navigationTitle("Post Message")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingHistory = true
                    }) {
                        Image(systemName: "clock")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingTemplates = true
                    }) {
                        Image(systemName: "doc.text")
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                MessageHistoryView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingTemplates) {
                TemplatesView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingSaveTemplate) {
                SaveTemplateView(templateName: $templateName, onSave: {
                    viewModel.saveAsTemplate(name: templateName)
                    templateName = ""
                })
            }
        }
    }

    // MARK: - View Components

    /// Message input section
    private var messageInputSection: some View {
        Section(header: Text("Message")) {
            TextEditor(text: $viewModel.messageText)
                .frame(minHeight: 100)
                .autocapitalization(.characters)  // Vestaboard uses uppercase

            if !viewModel.unsupportedCharacters.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Unsupported Characters")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }

                    Text("The following characters are not supported: ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    + Text(viewModel.unsupportedCharacters.map { String($0) }.joined(separator: ", "))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)

                    Button(action: {
                        viewModel.sanitizeMessage()
                    }) {
                        Label("Replace Unsupported Characters", systemImage: "wand.and.stars")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
        }
    }

    /// Validation and character count section
    private var validationSection: some View {
        Section {
            HStack {
                Text("Character Count")
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.characterCountText)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.exceedsMaxLength ? .red : .primary)
            }

            HStack {
                Text("Status")
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isValid ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(viewModel.isValid ? "Ready to Send" : "Contains Errors")
                        .font(.callout)
                        .foregroundColor(viewModel.isValid ? .green : .orange)
                }
            }
        }
    }

    /// Message preview section
    private var previewSection: some View {
        Section(header: Text("Preview")) {
            VStack(spacing: 0) {
                Text("How your message will appear:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)

                MessagePreviewView(layout: viewModel.messagePreview)
                    .frame(height: 180)
            }
            .padding(.vertical, 8)
        }
    }

    /// Actions section with send button
    private var actionsSection: some View {
        Section {
            if viewModel.isPosting {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("Sending...")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            } else {
                Button(action: {
                    Task {
                        await viewModel.postMessage()
                    }
                }) {
                    Label("Send to Vestaboard", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .disabled(!viewModel.isValid || viewModel.messageText.isEmpty)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    /// Messages section for errors and success
    private var messagesSection: some View {
        Section {
            if let error = viewModel.errorMessage {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }

            if let success = viewModel.successMessage {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(success)
                        .font(.callout)
                        .foregroundColor(.green)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
        }
    }

    /// Quick actions section
    private var quickActionsSection: some View {
        Section(header: Text("Quick Actions")) {
            Button(action: {
                viewModel.showingSaveTemplate = true
            }) {
                Label("Save as Template", systemImage: "square.and.arrow.down")
            }
            .disabled(viewModel.messageText.isEmpty)

            Button(action: {
                viewModel.messageText = ""
            }) {
                Label("Clear Message", systemImage: "trash")
            }
            .disabled(viewModel.messageText.isEmpty)

            Link(destination: URL(string: "https://docs.vestaboard.com/character-codes")!) {
                Label("View Supported Characters", systemImage: "questionmark.circle")
            }
        }
    }
}

// MARK: - Message Preview View

/// Displays a visual preview of how the message will appear on Vestaboard
struct MessagePreviewView: View {
    let layout: [[Int]]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<layout.count, id: \.self) { rowIndex in
                HStack(spacing: 1) {
                    ForEach(0..<layout[rowIndex].count, id: \.self) { colIndex in
                        CharacterPreviewCell(code: layout[rowIndex][colIndex])
                    }
                }
            }
        }
        .padding(8)
        .background(Color.vestaboardBlack)
        .cornerRadius(8)
    }
}

/// Individual character cell for preview
struct CharacterPreviewCell: View {
    let code: Int

    var body: some View {
        Text(character)
            .font(.system(size: 8, weight: .medium, design: .monospaced))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(2)
    }

    private var character: String {
        return String(VestaboardCharacterSet.character(for: code))
    }

    private var backgroundColor: Color {
        if VestaboardCharacterSet.isColorCode(code) {
            return Color.vestaboardColor(for: code)
        }
        return Color.vestaboardBlack
    }

    private var foregroundColor: Color {
        if VestaboardCharacterSet.isColorCode(code) {
            return .clear
        }
        return Color.vestaboardCharacter
    }
}

// MARK: - Save Template View

struct SaveTemplateView: View {
    @Binding var templateName: String
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Name")) {
                    TextField("e.g., Morning Greeting", text: $templateName)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Save Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(templateName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Templates View

struct TemplatesView: View {
    @ObservedObject var viewModel: MessageComposerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                if viewModel.templates.isEmpty {
                    Text("No templates saved yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(viewModel.templates) { template in
                        Button(action: {
                            viewModel.loadTemplate(template)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .font(.headline)

                                Text(template.preview)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)

                                if template.usageCount > 0 {
                                    Text("Used \(template.usageCount) times")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTemplate(viewModel.templates[index])
                        }
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if !viewModel.templates.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct MessageComposerView_Previews: PreviewProvider {
    static var previews: some View {
        MessageComposerView()
    }
}
