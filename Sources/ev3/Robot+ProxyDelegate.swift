import Foundation
import PlaygroundSupport

extension Robot: PlaygroundRemoteLiveViewProxyDelegate, MockRemoteLiveViewProxyDelegate {
    // MARK: - PlaygroundRemoteLiveViewProxyDelegate
    func remoteLiveViewProxyReceived(message: PlaygroundValue) {
        guard let liveViewMessage = Message(value: message) else { return }

        if let _ = liveViewMessage.type(Int.self, forKey: .conditionFulfilled) {
            log(message: "conditionFulfilled")
            conditionFulfilled()
        } else if let portData = liveViewMessage.type(Array<PlaygroundValue>.self, forKey: .portData) {
            let mapped = portData.flatMap({ PortData(playgroundValue: $0) })
            set(portData: mapped)
        } else if let replies = liveViewMessage.type(Array<PlaygroundValue>.self, forKey: .replyOperationReplies) {
            let mapped = replies.flatMap({ ReplyOperationReply(playgroundValue: $0) })
            set(replies: mapped)
        } else {
            fatalError("Unsupported key \(liveViewMessage)")
        }
    }
    
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        remoteLiveViewProxyReceived(message: message)
    }
    
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: MockRemoteLiveViewProxy, received message: PlaygroundValue) {
        remoteLiveViewProxyReceived(message: message)
    }
    
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        log(message: "")
    }
}

