import Foundation
import ExternalAccessory

protocol EV3CommunicatorDelegate {
    func communicatorFailedToReadIndex(_ communicator: EV3Communicator, messageIndex: UInt16)
    func communicator(_ communicator: EV3Communicator, didReadIndex messageIndex: UInt16, with payload: Data)
    func communicator(_ communicator: EV3Communicator, proceedAfter condition: BlockCondition)
}

class EV3Communicator: NSObject, EAAccessoryDelegate, StreamDelegate {
    
    let accessory: EAAccessory
    private var runLoop: RunLoop?
    
    private var thread: Thread?
    private var session: EASession?
    var shouldRun = false
    private var readStream: InputStream?
    private var writeStream: OutputStream?
    
    let delegate: EV3CommunicatorDelegate
    
    private var commandQueue = [Command]()
    private var isWaitingForSpace = false
    
    private var isExecutingCommand = false
    
    var _responseTimes = [Double]()
    var _lastWriteTime = Date()
    let _writeTimeFormatter = NumberFormatter()
    
    private var lastMessageNumberRead = 0
    
    private var waitingForReply = false
    private var expectedReplyNumber = 0
    
    init(accessory: EAAccessory, delegate: EV3CommunicatorDelegate) {
        self.accessory = accessory
        self.delegate = delegate
        super.init()
        accessory.delegate = self
         _writeTimeFormatter.maximumFractionDigits = 4
    }
    
    func start(postAction: @escaping () -> ()) {
        // called from the main thread
        if !shouldRun {
            shouldRun = true
            thread = Thread {
                self.runLoop = RunLoop.current
                self.openSession()
                postAction()
                while self.shouldRun {
                    let wait = Date(timeIntervalSinceNow: 1.0)
                    self.runLoop!.run(mode: .defaultRunLoopMode, before: wait)
                }
                log(message: "finished")
            }
            thread?.start()
        }
    }
    
    func killSession() {
        shouldRun = false
        closeSession()
        commandQueue.removeAll()
        isExecutingCommand = false
    }
    
    func _killSession_UntilBugFixed(postAction: @escaping () -> ()) {
        killSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.start(postAction: postAction)
        }
    }
    
    func enqueue(command: Command) {
        commandQueue.append(command)
        sendNextCommand()
    }
    
    private func sendNextCommand() {
        log(message: "\(commandQueue.count)")
        
        guard shouldRun, let sess = session, let output = sess.outputStream else {
            log(message: "Couldn't get output")
            return
        }
        
        guard !isWaitingForSpace, output.hasSpaceAvailable else {
            log(message: "Couldn't get output with space")
            isWaitingForSpace = true
            return
        }
        
        if waitingForReply {
            log(message: "Still waiting for reply from last message... MESSAGE NUMBER \(expectedReplyNumber)")
            _ = readDirectCommandReply()
        }
        
        // No command in queue
        guard !isExecutingCommand, let command = commandQueue.first else { return }
        
        isExecutingCommand = true
        commandQueue.removeFirst()

        if !command.isEmpty {
            output.write(command.bytes, maxLength: command.bytes.count)
            waitingForReply = command.requiresReply
            if waitingForReply {
                expectedReplyNumber = command.messageNumber
            }
            log(message: "SENDING MESSAGE NUMBER \(command.messageNumber) requires reply: \(command.requiresReply)")
            log(message: "Writing command w/ byte count: \(command.bytes.count)")
        }
        
        if command.isUserInitiated {
            processCondition(command.condition)
        }
    }
    
    func processCondition(_ condition: BlockCondition) {
        delegate.communicator(self, proceedAfter: condition)
        
        switch condition {
        case .time(_), .soundNotBusy, .absoluteValue(_, _, _), .outputBusy(_), .rateChange(_, _), .anyChange(_, _):
            DispatchQueue.main.asyncAfter(deadline: .hackyDelayTime()) {
                self.isExecutingCommand = false
                self.sendNextCommand()
            }
        default:
            break
        }
    }

    private func readDirectCommandReply() -> Bool {
        guard let replySizeHeader = read(length: 2) else {
            log(message: "Couldn't read reply size header")
            return false
        }
        
        let size = (Int(replySizeHeader[1]) << 8) | Int(replySizeHeader[0])
        log(message: "Reply size is \(size)")
        
        guard size > 0, let replyPayload = read(length: size) else {
            log(message: "Couldn't read reply payload")
            return false
        }
        
        let responseBuffer = Data(replyPayload.dropFirst(3))
        let messageIndex = (Int(replyPayload[1]) << 8) | Int(replyPayload[0])
        
        lastMessageNumberRead = messageIndex
        log(message: "RECEIVING MESSAGE NUMBER \(messageIndex)")
        if lastMessageNumberRead != expectedReplyNumber {
            log(message: "UNEXPECTED MESSAGE NUMBER \(messageIndex), expected \(expectedReplyNumber). Discarding...")
            return false
        }
        
        waitingForReply = false
        
        if replyPayload[2] == 0x02 {
            log(message: "Payload response successfully read (#\(messageIndex))")
            delegate.communicator(self, didReadIndex: UInt16(messageIndex), with: responseBuffer)
            return true
        } else if replyPayload[2] == 0x04 {
            log(message: "Payload response error (#\(messageIndex))")
        } else {
            log(message: "Payload response malformed (#\(messageIndex))")
        }
        delegate.communicatorFailedToReadIndex(self, messageIndex: UInt16(messageIndex))
        return false
    }
    
    private func read(length: Int) -> Data? {
        guard let s = session, let stream = s.inputStream, stream.hasBytesAvailable else {
            log(message: "Failed to get input stream with bytes available: \(session), \(session?.inputStream), \(session?.inputStream?.hasBytesAvailable)")
            return nil
        }
        
        var data = Data()
        var buffer: [UInt8] = Array(repeating: 0, count: length)
        let bytesRead = stream.read(&buffer, maxLength: length)
        data.append(&buffer, count: bytesRead)
        
        guard data.count >= length else {
            log(message: "Read of length \(length) failed. Only have \(data.count) bytes.")
            return nil
        }
        
        return data
    }
    
    func accessoryDidDisconnect(_ accessory: EAAccessory) {
        closeSession()
    }
    
    func stream(_ stream: Stream, handle code: Stream.Event) {
        log(message: "stream = \(stream) eventCode = \(code)")
        if stream == readStream {
            log(message: "read")
            if isExecutingCommand && readDirectCommandReply() {
                isExecutingCommand = false
                calculateAverageResponseTime()
                sendNextCommand()
            }
        } else if stream == writeStream {
            log(message: "write")
            _lastWriteTime = Date()
            if code == .hasSpaceAvailable && isWaitingForSpace {
                isWaitingForSpace = false
                sendNextCommand()
            }
        }
    }
    
    private func closeSession() {
        if let s = session, let r = runLoop {
            s.inputStream?.delegate = nil
            s.inputStream?.remove(from: r, forMode: .defaultRunLoopMode)
            s.inputStream?.close()
            
            s.outputStream?.delegate = nil
            s.outputStream?.remove(from: r, forMode: .defaultRunLoopMode)
            s.outputStream?.close()
            session = nil
        }
    }
    
    private func openSession() {
        if let r = runLoop {
            session = EASession(accessory: accessory, forProtocol: "COM.LEGO.MINDSTORMS.EV3")
            self.readStream = session?.inputStream
            self.writeStream = session?.outputStream
            session?.inputStream?.delegate = self
            session?.inputStream?.schedule(in: r, forMode: .defaultRunLoopMode)
            session?.inputStream?.open()
            
            session?.outputStream?.delegate = self
            session?.outputStream?.schedule(in: r, forMode: .defaultRunLoopMode)
            session?.outputStream?.open()
        }
    }
    
    private func calculateAverageResponseTime() {
        _responseTimes.append(-_lastWriteTime.timeIntervalSinceNow)
        if _responseTimes.count % 25 == 0 {
            let averageTime = NSNumber(floatLiteral: 1.0 / (_responseTimes.reduce(0, +) / Double(_responseTimes.count)))
            log(message: "Averaging \(_writeTimeFormatter.string(from: averageTime)!) reads a second")
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension DispatchTime {
    public static func hackyDelayTime() -> DispatchTime {
        return .now() + .milliseconds(20)
    }
}
