import Foundation
import PlaygroundSupport

extension LiveViewController: PlaygroundLiveViewMessageHandler, MockLiveViewMessageHandler {
    // MARK: - PlaygroundLiveViewMessageHandler
    
    // Only sending Command right now / comes back on main thread
    public func receive(_ message: PlaygroundValue) {
        log(message: "")
        //M: ExploreLTC
        // extend to take key
        
        guard let liveViewMessage = Message(value: message) else { return }
        
        if let operationsAndCondition = liveViewMessage.type(Array<PlaygroundValue>.self, forKey: .operationsAndCondition),
            operationsAndCondition.count == 2,
            case let .array(operationValues) = operationsAndCondition[0],
            let condition = BlockCondition(playgroundValue: operationsAndCondition[1]) {
                
            let operations = operationValues.flatMap({ operationValue in
                Operation(playgroundValue: operationValue)
            })
            
            assert(operations.count == operationValues.count, "Operation count was not equal to operationValues count")
            
            communicationLayer?.run(operations: operations, condition: condition)

        } else if let operationValues = liveViewMessage.type([PlaygroundValue].self, forKey: .replyOperations) {
            let operations = operationValues.flatMap({ ReplyOperation(playgroundValue: $0) })
            assert(operations.count == operationValues.count, "One or more values in message failed to deserialize from PlaygroundValue")
            
            communicationLayer?.run(operations: operations, isUserInitiated: true)
        } else {
            fatalError("Unsupported key \(liveViewMessage)")
        }
    }
    
    public func liveViewMessageConnectionOpened() {
        log(message: "")
    }
    
    public func liveViewMessageConnectionClosed() {
        log(message: "")
    }
}


