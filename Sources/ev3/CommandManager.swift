import Foundation

protocol CommandManager {
    func command(for operations: [Operation], with condition: BlockCondition) -> Command
    func command(for operations: [ReplyOperation], isUserInitiated: Bool) -> Command
    func readReply(for messageNumber: UInt16, with payload: Data) -> [ReplyOperationReply]?
    func isUserInitiated(_ messageNumber: UInt16) -> Bool
}

class DefaultCommandManager: CommandManager {
    
    //M: rename
    private struct SentReplyCommand {
        let operations: [ReplyOperation]
        let isUserInitiated: Bool
    }
    
    private var replyMessages = [UInt16: SentReplyCommand]()
    
    // Max of 256
    private let systemMessageIndexMax: UInt16 = 255
    private let systemMessageIndexMin: UInt16 = 10
    
    private let userMessageIndexMax: UInt16 = 10
    private let userMessageIndexMin: UInt16 = 0
    
    private var systemMessageIndex: UInt16 = 10
    private var userMessageIndex: UInt16 = 0
    

    // MARK: - Creating Message
    
    func command(for operations: [Operation], with condition: BlockCondition) -> Command {
        let sequence: UInt16 = nextMessageIndex(forUser: true)
        var messageParameters = [
            encodedMessageIndex(for: sequence),
            CommandType.direct(reply: false).encoded(),
            encodedMemoryUsed()
        ]
        
        for operation in operations {
            messageParameters.append(operation.encoded())
        }
        
        var message = Data()
        messageParameters.forEach { message.append($0) }
        let encodedLength = encodedMessageLength(for: message)
        message.insert(contentsOf: encodedLength, at: 0)
        
        logHex(message)
        return Command(bytes: [UInt8](message), messageNumber: Int(sequence),  condition: condition, requiresReply: false, isUserInitiated: true, isEmpty: operations.isEmpty)
    }
    
    func command(for operations: [ReplyOperation], isUserInitiated: Bool) -> Command {
        let sequence: UInt16 = nextMessageIndex(forUser: isUserInitiated)
        replyMessages[sequence] = SentReplyCommand(operations: operations, isUserInitiated: isUserInitiated)
        
        var messageParameters = [
            encodedMessageIndex(for: sequence),
            CommandType.direct(reply: true).encoded()
        ]
        
        var bytesToRead: Int32 = 0
        
        for operation in operations {
            messageParameters.append(operation.encoded(withGlobalVarIndex: bytesToRead))
            bytesToRead += Int32(operation.bytesToRead)
        }

        messageParameters.insert(encodedMemoryUsed(for: bytesToRead), at: 2)
        
        var message = messageParameters.reduce(Data(), +)
        let encodedLength = encodedMessageLength(for: message)
        message.insert(contentsOf: encodedLength, at: 0)
        
        logHex(message)
        return Command(bytes: [UInt8](message), messageNumber: Int(sequence), condition: .reply,requiresReply: true, isUserInitiated: isUserInitiated, isEmpty: operations.isEmpty)
    }
    
    // MARK: - Reading Replies
    
    func readReply(for messageNumber: UInt16, with payload: Data) -> [ReplyOperationReply]? {
        guard let replyMessage = replyMessages[messageNumber] else {
            log(message: "No message for \(messageNumber)")
            return nil
        }
        var data = payload
        let replies = replyMessage.operations.map { (operation) -> ReplyOperationReply in
            let reply =  operation.parse(data)
            let bytesRead = operation.bytesToRead
            data = data.subdata(in: bytesRead..<data.count)
            return reply
        }
        return replies
    }
    
    func isUserInitiated(_ messageNumber: UInt16) -> Bool {
        if let replyMessage = replyMessages[messageNumber], replyMessage.isUserInitiated {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Encoding Headers

    private func nextMessageIndex(forUser isUserInitiated: Bool = true) -> UInt16 {
        if isUserInitiated {
            userMessageIndex = (userMessageIndex + 1) % userMessageIndexMax
            return userMessageIndex
        } else {
            systemMessageIndex = max((systemMessageIndex + 1) % systemMessageIndexMax, systemMessageIndexMin + 1)
            return systemMessageIndex
        }
    }
    
    private func encodedMessageIndex(for index: UInt16) -> Data {
        let byte0 = UInt8(index)
        let byte1 = UInt8(index >> 8)
        return Data(bytes: [byte0, byte1])
    }
    
    private func encodedMessageLength(for message: Data) -> Data {
        let bufferSize = message.count
        let byte0 = UInt8(bufferSize)
        let byte1 = UInt8(bufferSize >> 8)
        return Data(bytes: [byte0, byte1])
    }
    
    private func encodedMemoryUsed(for bytes: Int32 = 0) -> Data {
        let globalAndLocalMemorySize = UInt16(bytes)
        let byte0 = UInt8(globalAndLocalMemorySize)
        let byte1 = UInt8(globalAndLocalMemorySize >> 8)
        return Data(bytes: [byte0, byte1])
    }
}
