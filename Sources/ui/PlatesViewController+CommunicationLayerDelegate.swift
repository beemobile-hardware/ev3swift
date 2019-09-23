import UIKit
import PlaygroundSupport

/// Extend `PlatesViewController` to conform to the `EV3CommunicationLayerDelegate` protocol.
extension PlatesViewController: EV3CommunicationLayerDelegate {
    func communicationLayerConnected() {
        // Dismiss the connection view controller if it's been presented.
        if presentedViewController as? ConnectionViewController != nil {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func communicationLayerDisconnected() {
        DispatchQueue.main.async {
            self.removeAllConnections()
            
            // Show the connection view controller.
            let connectionController: ConnectionViewController = ConnectionViewController.instantiateFromMainStoryboard()
            self.present(connectionController, animated: false, completion: nil)
        }
    }
    
    func communicationLayerConditionFulfilled() {
        sendToUserProcess(.integer(1), forKey: .conditionFulfilled)
    }
    
    func communicationLayer(_ communicationLayer: EV3CommunicationLayer, didReadReplies replies: [ReplyOperationReply]) {
        let array = replies.map { $0.playgroundValue }
        sendToUserProcess(.array(array), forKey: .replyOperationReplies)
    }
    
    func communicationLayer(_ communicationLayer: EV3CommunicationLayer, didReadPortData portData: [PortData]) {
        DispatchQueue.main.async {
            // Record the current grid layout plate style.
            let gridLayout = self.collectionView.collectionViewLayout as? PlateGridViewLayout
            let plateStyle = gridLayout?.plateStyle
            
            // Maintain an array of connections that aren't represented in the `PortData` array.
            var connectionsToRemove = self.connections
            var connectionsAdded: [PlateConnection] = []
            
            // Create empty dictionaries for port modes and data values per connection.
            var newModes: [PlateConnection: PortMode] = [:]
            var newData: [PlateConnection: Float] = [:]
            
            for portDataItem in portData {
                // Create a `PlateConnection` and `PortMode` from the `PortData`.
                guard let connection = PlateConnection(portData: portDataItem),
                    let mode = PortMode(portType: connection.type, mode: portDataItem.mode)
                    else { continue }
                
                if let index = connectionsToRemove.index(of: connection) {
                    // The connection is already in the collection view, don't remove it.
                    connectionsToRemove.remove(at: index)
                }
                else {
                    // Add the connection to the collection view.
                    connectionsAdded.append(connection)
                    self.addConnection(connection)
                }
                
                newModes[connection] = mode
                newData[connection] = portDataItem.value
            }
            
            // Remove any connections that are in the collection view but not in the
            // array of `PortData`.
            for connection in connectionsToRemove {
                guard let index = self.connections.index(of: connection) else { continue }
                self.removeConnection(at: index)
            }
            
            // Update the port views to match the connections.
            self.updatePortViews()
            
            // Record the mapped data.
            self.record(modes: newModes, data: newData)

            if gridLayout?.plateStyle != plateStyle {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
            
            // Announce any changes via Voice Over.
            self.announceConfigurationChange(forNewConnections: connectionsAdded, removedConnections: connectionsToRemove)
        }

        let array = portData.map { $0.playgroundValue }
        sendToUserProcess(.array(array), forKey: .portData)
    }
    
    private func announceConfigurationChange(forNewConnections newConnections: [PlateConnection], removedConnections: [PlateConnection]) {
        // Split the arrays into arrays for inputs and outputs, sort them and
        // map them to their accessible port descriptipons.
        let newInputPorts = newConnections.filter({ $0.port is InputPort }).sorted(by: { return $0.port.inputValue < $1.port.inputValue }).map { $0.port.accessibleDescription }
        let newOutputPorts = newConnections.filter({ $0.port is OutputPort }).sorted(by: { return $0.port.inputValue < $1.port.inputValue }).map { $0.port.accessibleDescription }
        let removedInputPorts = removedConnections.filter({ $0.port is InputPort }).sorted(by: { return $0.port.inputValue < $1.port.inputValue }).map { $0.port.accessibleDescription }
        let removedOutputPorts = removedConnections.filter({ $0.port is OutputPort }).sorted(by: { return $0.port.inputValue < $1.port.inputValue }).map { $0.port.accessibleDescription }
        
        // Build the announcement strings. This is very verbose and doesn't scale
        // at all, but since we have a strictly limited set of ports, it does make
        // localization very straightforward.
        var announcements: [String] = []
        
        if newOutputPorts.count == 1 {
            announcements.append(String(format: NSLocalizedString("Motor connected to %@", comment: "Voice Over announcement when a single motor is connected"),
                                        newOutputPorts[0]))
        }
        else if newOutputPorts.count == 2 {
            announcements.append(String(format: NSLocalizedString("Motors connected to %@ and %@", comment: "Voice Over announcement when 2 motors are connected"),
                                        newOutputPorts[0], newOutputPorts[1]))
        }
        else if newOutputPorts.count == 3 {
            announcements.append(String(format: NSLocalizedString("Motors connected to %@, %@ and %@", comment: "Voice Over announcement when 3 motors are connected"),
                                        newOutputPorts[0], newOutputPorts[1], newOutputPorts[2]))
        }
        else if newOutputPorts.count == 4 {
            announcements.append(String(format: NSLocalizedString("Motors connected to %@, %@, %@ and %@", comment: "Voice Over announcement when 4 motors are connected"),
                                        newOutputPorts[0], newOutputPorts[1], newOutputPorts[2], newOutputPorts[3]))
        }

        if newInputPorts.count == 1 {
            announcements.append(String(format: NSLocalizedString("Sensor connected to %@", comment: "Voice Over announcement when a single sensor is connected"),
                                        newInputPorts[0]))
        }
        else if newInputPorts.count == 2 {
            announcements.append(String(format: NSLocalizedString("Sensors connected to %@ and %@", comment: "Voice Over announcement when 2 sensors are connected"),
                                        newInputPorts[0], newInputPorts[1]))
        }
        else if newInputPorts.count == 3 {
            announcements.append(String(format: NSLocalizedString("Sensors connected to %@, %@ and %@", comment: "Voice Over announcement when 3 sensors are connected"),
                                        newInputPorts[0], newInputPorts[1], newInputPorts[2]))
        }
        else if newInputPorts.count == 4 {
            announcements.append(String(format: NSLocalizedString("Sensors connected to %@, %@, %@ and %@", comment: "Voice Over announcement when 4 sensors are connected"),
                                        newInputPorts[0], newInputPorts[1], newInputPorts[2], newInputPorts[3]))
        }
        
        if removedOutputPorts.count == 1 {
            announcements.append(String(format: NSLocalizedString("Motor disconnected from %@", comment: "Voice Over announcement when a single motor is disconnected"),
                                        removedOutputPorts[0]))
        }
        else if removedOutputPorts.count == 2 {
            announcements.append(String(format: NSLocalizedString("Motors disconnected from %@ and %@", comment: "Voice Over announcement when 2 motors are disconnected"),
                                        removedOutputPorts[0], removedOutputPorts[1]))
        }
        else if removedOutputPorts.count == 3 {
            announcements.append(String(format: NSLocalizedString("Motors disconnected from %@, %@ and %@", comment: "Voice Over announcement when 3 motors are disconnected"),
                                        removedInputPorts[0], removedInputPorts[1], removedInputPorts[2]))
        }
        else if removedOutputPorts.count == 4 {
            announcements.append(String(format: NSLocalizedString("Motors disconnected from %@, %@, %@ and %@", comment: "Voice Over announcement when 4 motors are disconnected"),
                                        removedOutputPorts[0], removedOutputPorts[1], removedOutputPorts[2], removedOutputPorts[3]))
        }
        
        if removedInputPorts.count == 1 {
            announcements.append(String(format: NSLocalizedString("Sensor disconnected from %@", comment: "Voice Over announcement when a single sensor is disconnected"),
                                        removedInputPorts[0]))
        }
        else if removedInputPorts.count == 2 {
            announcements.append(String(format: NSLocalizedString("Sensors disconnected from %@ and %@", comment: "Voice Over announcement when 2 sensors are disconnected"),
                                        removedInputPorts[0], removedInputPorts[1]))
        }
        else if removedInputPorts.count == 3 {
            announcements.append(String(format: NSLocalizedString("Sensors disconnected from %@, %@ and %@", comment: "Voice Over announcement when 3 sensors are disconnected"),
                                        removedInputPorts[0], removedInputPorts[1], removedInputPorts[2]))
        }
        else if removedInputPorts.count == 4 {
            announcements.append(String(format: NSLocalizedString("Sensors disconnected from %@, %@, %@ and %@", comment: "Voice Over announcement when 4 sensors are disconnected"),
                                        removedInputPorts[0], removedInputPorts[1], removedInputPorts[2], removedInputPorts[3]))
        }
        
        if !announcements.isEmpty {
            // Announce the summary of changes.
            let fullAnnouncement = announcements.joined(separator: ". ")
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, fullAnnouncement)
        }
    }
    
    private func sendToUserProcess(_ value: PlaygroundValue, forKey key: Message.Key) {
        #if !SUPPORTINGCONTENT
            send(value, forKey: key)
        #endif
    }
}
