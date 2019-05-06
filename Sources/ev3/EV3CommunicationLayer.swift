import Foundation
import ExternalAccessory
import PlaygroundSupport

protocol EV3CommunicationLayerDelegate {
    func communicationLayer(_ communicationLayer: EV3CommunicationLayer, didReadReplies replies: [ReplyOperationReply])
    func communicationLayer(_ communicationLayer: EV3CommunicationLayer, didReadPortData portData: [PortData])
    
    func communicationLayerConnected()
    func communicationLayerDisconnected()
    func communicationLayerConditionFulfilled()
}

class EV3CommunicationLayer: EV3CommunicatorDelegate {
    let commandManager: CommandManager
    let delegate: EV3CommunicationLayerDelegate
    
    var communicator: EV3Communicator?
    var isConnected = false
    var brickName: String?
    
    init(commandManager: CommandManager, delegate: EV3CommunicationLayerDelegate) {
        self.commandManager = commandManager
        self.delegate = delegate
    }
    
    public func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(connected), name: .EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnected), name: .EAAccessoryDidDisconnect, object: nil)
        EAAccessoryManager.shared().registerForLocalNotifications()
        
        findAndConnect()
        keepSessionAlive()
    }
    
    public func disconnect() {
        log(message: "Disconnecting from accessory: \(String(describing: communicator?.accessory))")
        communicator?.killSession()
        isConnected = false
        PlaygroundKeyValueStore.current.selectedBrickConnectionID = nil
        delegate.communicationLayerDisconnected()
    }
    
    private func findAndConnect() {
        log(message: "Connecting to selected brick: \(String(describing: PlaygroundKeyValueStore.current.selectedBrickConnectionID))")
        if  let connectionID = PlaygroundKeyValueStore.current.selectedBrickConnectionID,
            case let connectedAccessories = EAAccessoryManager.shared().connectedAccessories,
            let selectedAccessory = connectedAccessories.first(where: {$0.connectionID == connectionID}),
            selectedAccessory.isEV3Accessory() {
            log(message: "Connecting to selected accessory: \(selectedAccessory)")
            set(accessory: selectedAccessory)
        }
    }
    
    @objc func connected(_ notification: NSNotification) {
        if  let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory,
            accessory.isEV3Accessory() {
            log(message: "Connected to accessory: \(accessory)")
            set(accessory: accessory)
        } else {
            log(message: "Failed to connect to accessory")
        }
    }
    
    @objc func disconnected(_ notification: NSNotification) {
        if  let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory,
            let selectedBrickConnectionID = PlaygroundKeyValueStore.current.selectedBrickConnectionID,
            accessory.connectionID == selectedBrickConnectionID {
            log(message: "Disconnected from accessory: \(accessory)")
            communicator?.shouldRun = false
            isConnected = false
            delegate.communicationLayerDisconnected()
        }
    }
    
    private func keepSessionAlive() {
        DispatchQueue.global(qos: .background).async {
            while true {
                if !self.isConnected && PlaygroundKeyValueStore.current.selectedBrickConnectionID != nil {
                    log(message: "Lost session, trying to reestablish...")
                    DispatchQueue.main.async {
                        log(message: "Retrying session")
                        self.findAndConnect()
                    }
                }
                sleep(2)
            }
        }
    }
    
    public func set(accessory: EAAccessory) {
        guard accessory.isEV3Accessory() else {
            return
        }
        // Kill old session
        communicator?.killSession()
        
        communicator = EV3Communicator(accessory: accessory, delegate: self)
        communicator?.start(postAction: {
            self.getPortData()
            self.saveBrickName(connectionID: accessory.connectionID)
            log(message: "Saving selectedBrickConnectionID = \(accessory.connectionID)")
            PlaygroundKeyValueStore.current.selectedBrickConnectionID = accessory.connectionID
        })
        isConnected = true
        delegate.communicationLayerConnected()
    }
    
    // Call on main thread
    
    func run(operations: [Operation], condition: BlockCondition) {
        // We can't run user commands before we have the first batch-read
        if latestPortData == nil {
            let batchReadCommand = commandManager.command(for: [.playgroundsGetPortData], isUserInitiated: false)
            communicator?.enqueue(command: batchReadCommand)
        }
        
        let command = commandManager.command(for: operations, with: condition)
        communicator?.enqueue(command: command)
    }
    
    func run(operations: [ReplyOperation], isUserInitiated: Bool) {
        let command = commandManager.command(for: operations, isUserInitiated: isUserInitiated)
        communicator?.enqueue(command: command)
    }
    
    func _temporaryWorkAroundUntilTheStopBugIsFixed() {
        communicator?._killSession_UntilBugFixed(postAction: {
            log(message: "Running post-kill action (bootstrapping portdata loop)")
            self.getPortData()
        })
    }
    
    var activeCondition: BlockCondition?
    var originalPortData: [PortData]?
    var latestPortData: [PortData]?
    
    func checkCondition(receivedUserInitiatedReply: Bool = true) {
        guard let condition = activeCondition else { return }
        
        let conditionFulfilled: Bool

        switch condition {
        case .reply:
            conditionFulfilled = receivedUserInitiatedReply
        case .absoluteValue(_, _, _):
            conditionFulfilled = checkActiveValueCondition()
        case let .rateChange(delta, port):
            conditionFulfilled = checkRateChangeCondition(delta: delta, port: port)
            if !conditionFulfilled {
                originalPortData = latestPortData
            }
        case let .anyChange(delta, port):
            conditionFulfilled = checkAnyChange(delta: delta, port: port)
        default:
            return
        }

        if conditionFulfilled {
            activeCondition = nil
            self.originalPortData = nil
            delegate.communicationLayerConditionFulfilled()
        }
    }

    private func checkAnyChange(delta: Float, port: Port) -> Bool {
        if  let original = originalPortData,
            let current = latestPortData {
            
            let x = current[port.batchReadIndex].value
            let y = original[port.batchReadIndex].value
            let distance = abs(x - y)
            
            return distance >= delta
        }
        return false
    }
    
    private func checkRateChangeCondition(delta: Float, port: Port) -> Bool {
        if  let original = originalPortData,
            let current = latestPortData {
            
            let rate = current[port.batchReadIndex].value - original[port.batchReadIndex].value
            let fulfilled = (delta < 0 && rate <= delta) || (delta >= 0 && rate >= delta)
            log(message: "Rate change on \(port): \(rate), expected: \(delta), fulfilled: \(fulfilled)")
            
            return fulfilled
        }
        
        return false
    }
    
    func checkActiveValueCondition() -> Bool {
        guard let absoluteValue = activeCondition?.absoluteValue,
            let portData = latestPortData,
                portData.count == 8 else {
                return false
        }
        
        let relevantPortData = portData[absoluteValue.port.batchReadIndex]
        let conditionFulfilled: Bool
        
        switch absoluteValue.relation {
        case .lessThanOrEqual:
            conditionFulfilled = relevantPortData.value <= absoluteValue.value
        case .equal:
            conditionFulfilled = relevantPortData.value == absoluteValue.value
        case .notEqual:
            conditionFulfilled = relevantPortData.value != absoluteValue.value
        case .greaterThanOrEqual:
            conditionFulfilled = relevantPortData.value >= absoluteValue.value
        case .greaterThan:
            conditionFulfilled = relevantPortData.value > absoluteValue.value
        case .lessThan:
            conditionFulfilled = relevantPortData.value < absoluteValue.value
        }
        return conditionFulfilled
    }
    
    private func saveBrickName(connectionID: Int) {
        DispatchQueue.global(qos: .background).async {
            if let brickName = self.readBrickName() {
                var connectedBricks = PlaygroundKeyValueStore.current.connectedBricks ?? [:]
                // Clean up disconnected bricks
                let accessories = EAAccessoryManager.shared().connectedAccessories
                for id in connectedBricks.keys {
                    if !accessories.contains(where: {$0.connectionID == id}) {
                        connectedBricks.removeValue(forKey: id)
                    }
                }
                // Add the new connected brick
                connectedBricks[connectionID] = brickName
                PlaygroundKeyValueStore.current.connectedBricks = connectedBricks
                log(message: "Saved brick name '\(brickName)' for connection ID \(connectionID)")
            } else {
                log(message: "Failed to save brick name for connection ID \(connectionID)")
            }
        }
    }
    
    // Blocks while waiting for the name to be set
    func readBrickName() -> String? {
        guard isConnected else {
            return nil
        }
        brickName = nil
        run(operations: [.opCom_Get_GET_BRICKNAME(maxLength: 13)], isUserInitiated: false)
        while brickName == nil {
            usleep(10_000)
        }
        return brickName
    }
    
    func writeBrickName(name: String) {
        if isConnected,
            name.characters.count <= 13 {
            // Set new name
            run(operations: [.opCom_Set_SET_BRICKNAME(name: name)], condition: .time(milliseconds: 1))
            
            // Save name to playground keyvaluestore
            if let connID = communicator?.accessory.connectionID {
                saveBrickName(connectionID: connID)
            }
        }
    }

    // MARK: - EV3CommunicatorDelegate

    func communicator(_ communicator: EV3Communicator, proceedAfter condition: BlockCondition) {
        log(message: "")
        activeCondition = condition // if this is a .soundNotBusy we'll add the sound busy check
        log(message: "condition \(condition)")
        
        switch condition {
        case .time(let time):
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .conditionFulfilled(after: time)) {
                self.delegate.communicationLayerConditionFulfilled()
            }
        case .rateChange(_, _), .anyChange(_, _):
            originalPortData = latestPortData
        default:
            break
        }
    }
    
    // MARK: - Port Data
    
    func communicator(_ communicator: EV3Communicator, didReadIndex messageIndex: UInt16, with payload: Data) {
        guard let replies = commandManager.readReply(for: messageIndex, with: payload) else  {
            return
        }
        
        for reply in replies {
            switch reply {
                case let .brickName(name):
                    log(message: "Setting brick name: \(name)")
                    brickName = name
                default:
                    break
            }
        }
        
        log(message: replies.description)
        
        // Checking if system issued, is port data
        let isUserInitiatedReply = commandManager.isUserInitiated(messageIndex)
        guard !isUserInitiatedReply else {
            delegate.communicationLayer(self, didReadReplies: replies)
            checkCondition()
            return
        }
        
        guard let portDataReply = replies.first, case let .portData(portData) = portDataReply, portData.count == 8 else {
            return
        }
        
        latestPortData = portData
        checkCondition(receivedUserInitiatedReply: false)
        
        if replies.count == 2 {
            if case let .soundBusy(flag) = replies[1] {
                if !flag {
                    activeCondition = nil
                    delegate.communicationLayerConditionFulfilled()
                }
            } else if case let .outputPortBusy(busy) = replies[1], activeCondition != nil {
                log(message:"Checking output busy flag...\(busy)")
                if !busy {
                    activeCondition = nil
                    delegate.communicationLayerConditionFulfilled()
                }
            }
        }
        
        delegate.communicationLayer(self, didReadPortData: portData)
        getPortData()
    }
    
    func communicatorFailedToReadIndex(_ communicator: EV3Communicator, messageIndex: UInt16) {}
    
    private func getPortData() {
        var ops = [ReplyOperation.playgroundsGetPortData]
        if case .soundNotBusy? = activeCondition {
            ops.append(ReplyOperation.opSound_Test)
        } else if case let .outputBusy(ports)? = activeCondition {
            let portValue = ports.map({$0.rawValue}).reduce(0x00, { $0 | $1 })
            ops.append(ReplyOperation.opOutput_Test(port: portValue))
        }
        let command = commandManager.command(for: ops, isUserInitiated: false)
        communicator?.enqueue(command: command)
    }
}

extension DispatchTime {
    public static func initalSyncTime() -> DispatchTime {
        return .now() + .milliseconds(2000)
    }
    
    public static func conditionFulfilled(after milliseconds: Int) -> DispatchTime {
        return .now() + .milliseconds(milliseconds)
    }
}

extension EAAccessory {
    func isEV3Accessory() -> Bool {
        return protocolStrings.contains("COM.LEGO.MINDSTORMS.EV3")
    }
}
