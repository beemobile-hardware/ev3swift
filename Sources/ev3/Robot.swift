import Foundation
import PlaygroundSupport

extension RobotFoundation {
    func run(_ operations: [Operation]) {
        run(operations, condition: BlockCondition.time(milliseconds: 0))
    }
}

/*
 
 This protocol is enough to implement the remaining RobotAPI methods.
 The methods for RobotAPI are implemented through protocol extensions 
 of RobotFoundation in Robot****Methods.swift
 
 */
extension RobotFoundation {
    func readSensor(on port: Port, type: PortType, mode: PortMode, caller: String = #function) -> Float
    {
        return readSensor(on: port, type: type, mode: mode, caller: caller)
    }
}
protocol RobotFoundation {
    
    var portData: [UInt8: PortData]? { get }
    
    func changeModeAndRead(from port: Port, type: PortType, mode: PortMode) -> Float?
    func readSensor(on port: Port, type: PortType, mode: PortMode, caller: String) -> Float
    
    func send(_ value: PlaygroundValue, forKey key: Message.Key)
    
    @discardableResult
    func run(_ operations: [ReplyOperation]) -> [ReplyOperationReply]?
    func run(_ operations: [Operation], condition: BlockCondition)
    
}



public class Robot: RobotAPI, RobotFoundation {
  
    static let defaultDisplayStorageLevel: UInt8 = 1
    
    internal var portData: [UInt8: PortData]?
    private var latestReplies: [ReplyOperationReply]?
    
    public weak var proxy: PlaygroundRemoteLiveViewProxy?
    var _mockProxy: MockRemoteLiveViewProxy?
    
    private let _semaphore = DispatchSemaphore(value: 0)
    
    private var runLoopRunning = false {
        didSet {
            if runLoopRunning {
                CFRunLoopRun()
            }
            else {
                CFRunLoopStop(CFRunLoopGetMain())
            }
        }
    }
    
    public init(proxy: PlaygroundRemoteLiveViewProxy? = nil, mockProxy: MockRemoteLiveViewProxy? = nil) {
        self.proxy = proxy
        self._mockProxy = mockProxy
    }
    
    func conditionFulfilled() {
        #if SUPPORTINGCONTENT
            _semaphore.signal()
        #else
            runLoopRunning = false
        #endif
    }
    
    public func resetAll() {
        var operations: [Operation] = Robot.resetSensorOperations
        // Set motor type if applicable
        for p in OutputPort.all {
            if  let portData = portData?[p.inputValue],
                let operation = setMotorTypeOperation(for: portData) {
                operations.append(operation)
            }
        }
        
        run(operations)
    }
    
    private func setMotorTypeOperation(for portData: PortData) -> Operation? {
        guard
            let port = portData.port as? OutputPort,
            let portType = PortType(rawValue: Int32(portData.type)) else {
                return nil
        }
        switch portType {
            case .mediumMotor: return .opOutput_Set_Type(layer: 0, outputPort: port, type: .mediumMotor)
            case .largeMotor: return .opOutput_Set_Type(layer: 0, outputPort: port, type: .largeMotor)
            default: return nil
        }
    }
    
    func stopOutputsNoBrake(){
        run([Operation.opOutput_Stop(layer: 0, outputPorts: OutputPort.all, brake: false)])
    }

    // MARK: - Robot Implementation
    
    func run(_ operations: [Operation], condition: BlockCondition = BlockCondition.time(milliseconds: 0)) {
        let array: PlaygroundValue = .array(operations.map { $0.playgroundValue })
        send(.array([array, condition.playgroundValue]), forKey: .operationsAndCondition)
    }
    
    @discardableResult
    func run(_ operations: [ReplyOperation]) -> [ReplyOperationReply]? {
        let array: PlaygroundValue = .array(operations.map { $0.playgroundValue } )
        send(array, forKey: .replyOperations)
        // Send blocks until condition fulfilled
        let replies = latestReplies
        latestReplies = nil
        return replies
    }
    
    internal func send(_ value: PlaygroundValue, forKey key: Message.Key) {
        DispatchQueue.global(qos: .default).async {
            if let proxy = self.proxy {
                proxy.send(value, forKey: key)
            } else {
                self._mockProxy?.send(value, forKey: key, toUserProcess: false)
            }
        }
        
        #if SUPPORTINGCONTENT
            _semaphore.wait()
        #else
            runLoopRunning = true
        #endif
    }
    
    private func checkDeviceConfiguration(expect: PortType, atPort port: Port, caller: String) -> RobotError {
        if let portData = portData,
           let value = portData[port.inputValue]
        {
            if value.type == Int(expect.rawValue) {
                return .noError
            } else if let actualType = PortType(rawValue: Int32(value.type)) {
                return .portMismatchError(
                    port: port,
                    expectedType: expect,
                    actualType: actualType,
                    method: caller)
            }
        }
        return .noError
    }

    
    
    func readSensor(on port: Port, type: PortType, mode: PortMode, caller: String = #function) -> Float {
        
        let maybeError = checkDeviceConfiguration(expect: type, atPort: port, caller: caller)
        switch  maybeError {
        case .portMismatchError(_, expectedType: .mediumMotor, actualType: .largeMotor, _),
             .portMismatchError(_, expectedType: .largeMotor, actualType: .mediumMotor, _):
            break // allow measureDegrees on both motor types
        case .portMismatchError:
            send(maybeError.playgroundValue(), forKey: .robotError)
            return 0.0
        case .noError:
            log(message: "No-error : \(maybeError)")
            break
        }
        
        let modeValue = mode.EV3Value(for: type)
        if let portData = portData,
            let thisPortData = portData[port.inputValue],
            thisPortData.mode == Int(modeValue) {
            return Float(thisPortData.value)
        } else if let value = changeModeAndRead(from: port, type: type, mode: mode) {
            return value
        } else {
            return 0.0
        }
    }
    
    func changeModeAndRead(from port: Port, type: PortType, mode: PortMode) -> Float? {
        let modeValue = mode.EV3Value(for: type)
        let op: ReplyOperation = .opInput_Device_Get_Ready_SI(layer: 0, port: port.inputValue, type: type.rawValue, mode: modeValue)
        if let replies = run([op]),
            case let .portValue(value) = replies[0] {
            return value
        } else {
            return nil
        }
    }
    
    public func set(replies: [ReplyOperationReply]) {
        self.latestReplies = replies
    }
    
    public func set(portData: [PortData]) {
        guard portData.count == 8 else { return }
        
        var map = [UInt8: PortData]()
        map[InputPort.one.inputValue]   = portData[0]
        map[InputPort.two.inputValue]   = portData[1]
        map[InputPort.three.inputValue] = portData[2]
        map[InputPort.four.inputValue]  = portData[3]
        map[OutputPort.a.inputValue]    = portData[4]
        map[OutputPort.b.inputValue]    = portData[5]
        map[OutputPort.c.inputValue]    = portData[6]
        map[OutputPort.d.inputValue]    = portData[7]
        self.portData = map
    }
    
    public static let resetSensorOperations: [Operation] = [
        // Output clear
        .opOutput_Reset(layer: 0, outputPorts: OutputPort.all),
        // Input clear
        .opInput_Device_Clr_All
    ]
    
    public static let cleanUpOperations: [Operation] = [
        // Stop and unbrake all output ports
        .opOutput_Stop(layer: 0, outputPorts: OutputPort.all, brake: false),
        // Stop sound playback
        .opSound(command: .break),
        // Enable the topbar in the display
        .opDraw(command: .enableTopLine(flag: true)),
        // Restore saved state of screen
        .opDraw(command: .restoreScreen(level: Robot.defaultDisplayStorageLevel)),
        // Update display
        .opDraw(command: .update),
        // Set brick light to constant green
        .opWrite(command: .brickLight(pattern: 0x01))
    ]
}

