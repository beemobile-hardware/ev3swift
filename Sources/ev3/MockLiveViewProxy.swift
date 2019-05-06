import Foundation
import PlaygroundSupport

public protocol MockRemoteLiveViewProxyDelegate: class {
    // Using same method as real proxy
    func remoteLiveViewProxy(_ remoteLiveViewProxy: MockRemoteLiveViewProxy, received message: PlaygroundValue)
}

public protocol MockLiveViewMessageHandler: class {
    // Using same method as real handler
    func receive(_ message: PlaygroundValue)
}

public protocol MockRemoteLiveViewProxy {
    var delegate: MockRemoteLiveViewProxyDelegate? { get set }
    var messageHandler: MockLiveViewMessageHandler? { get set }

    func receive(_ message: PlaygroundValue)
    func send(_ message: PlaygroundValue, toRobot: Bool)
    func send(_ value: PlaygroundValue, forKey key: Message.Key, toUserProcess: Bool)
}

public class DefaultMockRemoteLiveViewProxy: MockRemoteLiveViewProxy{
    
    public var delegate: MockRemoteLiveViewProxyDelegate?
    public var messageHandler: MockLiveViewMessageHandler?
    
    public init(){}
    
    public func receive(_ message: PlaygroundValue) {
        #if SUPPORTINGCONTENT
        delegate?.remoteLiveViewProxy(self, received: message)
        #endif
    }
    
    public func send(_ message: PlaygroundValue, toRobot: Bool) {
        
    }
    
    public func send(_ value: PlaygroundValue, forKey key: Message.Key, toUserProcess: Bool) {
        // Messages can always be sent from the User Process, or while the connection is open in the LVP.
        //        guard !Process.isLiveViewProcess || Process.isLiveViewConnectionOpen else {
        //            log(message: "Attempting to send, but the connection is closed.\nMessageKey:  \(key)\n\(value)")
        //            return
        //        }
        #if SUPPORTINGCONTENT
            if toUserProcess {
                delegate?.remoteLiveViewProxy(self, received: .dictionary([key.rawValue: value]))
            } else {
                DispatchQueue.main.async {
                    self.messageHandler?.receive(.dictionary([key.rawValue: value]))
                }
            }
        #endif
    }
}
