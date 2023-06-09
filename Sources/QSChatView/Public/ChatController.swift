//
//  File.swift
//  
//
//  Created by SplittyDev on 13.04.23.
//

import Foundation
import SwiftUI

/// The chat controller used by ``QSChatView``.
public class ChatController: ObservableObject {
    @Published var textInputContent: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var config: ChatConfig
    
    // MARK: - Internal Interface
    
    /// Fulfill a ``ChatMessagePromise``, replacing the contents of the original message.
    func fulfill(
        _ promise: ChatMessagePromise,
        withContent content: ChatMessageContent,
        timestamp: Date = Date()
    ) {
        guard let messageIndex = messages.firstIndex(where: { $0.id == promise.messageId }) else { return }
        messages[messageIndex].replaceContent(with: content, timestamp: timestamp)
    }
    
    /// Reject a ``ChatMessagePromise``, removing it from the chat.
    func reject(_ promise: ChatMessagePromise) {
        guard let messageIndex = messages.firstIndex(where: { $0.id == promise.messageId }) else { return }
        messages.remove(at: messageIndex)
    }
    
    // MARK: - Public Interface
    
    /// Create a new instance of ``ChatController``
    public init(messages: [ChatMessage] = [], config: ChatConfig? = nil) {
        self.messages = messages
        self.config = config ?? .default
    }
    
    /// Send a ``ChatMessage``
    public func send(_ message: ChatMessage) {
        messages.append(message)
    }
    
    /// Send a temporary ``ChatMessage`` with a loading indicator.
    ///
    /// Use ``ChatMessagePromise/fulfill(withContent:timestamp:)`` to replace the message contents later.
    public func sendPromise(from participant: ChatParticipant) -> ChatMessagePromise {
        let message = ChatMessage(from: participant, content: .typingIndicator)
        self.send(message)
        return ChatMessagePromise(controller: self, messageId: message.id)
    }
    
    /// Delete the message with the specified `id`.
    public func delete(id: UUID) {
        messages.removeAll(where: { $0.id == id })
    }
    
    /// Delete the specified message.
    public func delete(message: ChatMessage) {
        delete(id: message.id)
    }
}
