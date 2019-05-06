import UIKit
import PlaygroundSupport

extension PlatesViewController: PlaygroundLiveViewMessageHandler {
    public func liveViewMessageConnectionOpened() {
        userCodeState = .running
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard let message = Message(value: message), let communicationLayer = communicationLayer else { return }
        
        if let operationsAndCondition = message.type(Array<PlaygroundValue>.self, forKey: .operationsAndCondition),
                operationsAndCondition.count == 2,
                case let .array(operationValues) = operationsAndCondition[0],
                let condition = BlockCondition(playgroundValue: operationsAndCondition[1]) {
            
            let operations = operationValues.flatMap { Operation(playgroundValue: $0) }
            assert(operations.count == operationValues.count, "Operation count was not equal to operationValues count")
            
            communicationLayer.run(operations: operations, condition: condition)
            
        } else if let operationValues = message.type([PlaygroundValue].self, forKey: .replyOperations) {
            let operations = operationValues.flatMap { ReplyOperation(playgroundValue: $0) }
            assert(operations.count == operationValues.count, "One or more values in message failed to deserialize from PlaygroundValue")
            
            communicationLayer.run(operations: operations, isUserInitiated: true)
        } else if let errorValues = message.type([PlaygroundValue].self, forKey: .robotError) {
            if let configError = RobotError(playgroundValue: .array(errorValues)) {
                handleRobotError(error: configError)
                self.communicationLayerConditionFulfilled()
            } else {
                fatalError("Unable to deserialize robot error value: \(errorValues)")
            }
        } else {
            fatalError("Unsupported key \(message)")
        }
    }
    
    
    private func handleRobotError(error: RobotError) {
        switch error {
            case .noError: break
            case let .portMismatchError(port, expectedType, actualType, method):
                log(message: "Live view received robot error on port \(port): expected \(expectedType), robot has \(actualType). Error comes from API-method \(method)")
                
                if !accumulatedErrors.contains(error) {
                    accumulatedErrors.append(error)
                } else {
                    log(message: "Error already recorded for this run, ignoring this one.")
                }
        }
    }
    
    private func showErrors() {
        if accumulatedErrors.isEmpty { return }
        let errorMessage = accumulatedErrors.map{$0.toString()}.joined(separator: "\n\n")
        
        let alertTitle = NSLocalizedString("Error During User Program", comment: "Alert modal title")
        let dismissTitle = NSLocalizedString("Dismiss", comment: "Alert modal dismiss button text")

        let alert = UIAlertController(title: alertTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: dismissTitle, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func liveViewMessageConnectionClosed() {
        log(message: "")
        
        userCodeState = .finished
        
        let systemVersion = ProcessInfo().operatingSystemVersion
        
        communicationLayer?._temporaryWorkAroundUntilTheStopBugIsFixed()

        // Clean up the robot
        communicationLayer?.run(operations: Robot.cleanUpOperations, condition: BlockCondition.time(milliseconds: 0))
        
        // If any errors, pop up
        showErrors()
        
        // Reset errors
        accumulatedErrors = []
    }
}
