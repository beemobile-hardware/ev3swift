import Foundation
import UIKit
import PlaygroundSupport

extension LiveViewController: EV3CommunicationLayerDelegate {
    
    func communicationLayerConnected() {
        log(message: "")
    }
    
    func communicationLayerDisconnected() {
        log(message: "")
        let alertController = UIAlertController(title: "EV3 Disconnected", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        if !loadedFromPlayground {
            mockRobotThread = nil
        }
    }
    
    func communicationLayerConditionFulfilled() {
        log(message: "")
        sendToUserProcess(.integer(1), forKey: .conditionFulfilled)
    }
    
    
    func communicationLayer(_ communicationLayer: EV3CommunicationLayer, didReadPortData portData: [PortData]) {
        log(message: "")
        
        allPortData.append(portData)
        DispatchQueue.main.async {
            // For debug ui
            self.gotNewPortData()
            self.drawShapes()
            self.hardwareCollectionView.updatedPorts(data: self.allPortData[self.currentIndex - 1])
        }
        
        let array = portData.map { $0.playgroundValue }
        sendToUserProcess(.array(array), forKey: .portData)
    }
    
    
    func communicationLayer(_ communicationLayer: EV3CommunicationLayer, didReadReplies replies: [ReplyOperationReply]) {
        let array = replies.map { $0.playgroundValue }
        sendToUserProcess(.array(array), forKey: .replyOperationReplies)
    }
    
    func sendToUserProcess(_ value: PlaygroundValue, forKey key: Message.Key) {
        log(message: "")
        if loadedFromPlayground {
            send(value, forKey: key)
        } else {
            mockRemoteLiveViewProxy?.send(value, forKey: key, toUserProcess: true)
        }
    }
}
