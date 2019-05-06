import Foundation
import PlaygroundSupport

extension Operation {
    
    private enum OperationType: String {
        case opCom_Set_SET_BRICKNAME
        
        case opOutput_Set_Type
        case opOutput_Start
        case opOutput_Stop
        case opOutput_Speed
        
        case opOutput_Reset
        case opOutput_Step_Speed
        case opOutput_Time_Speed
        case opOutput_Step_Sync
        
        case opOutput_Time_Sync
        case opOutput_Clr_Count
        case opSound
        case opDraw
        case opWrite
        
        case opInput_Device_Clr_All
        case opInput_Device_Clr_Changes
    }
    
    private var type: OperationType {
        switch self {
            case .opOutput_Set_Type: return .opOutput_Set_Type
            case .opOutput_Reset: return .opOutput_Reset
            case .opOutput_Stop: return .opOutput_Stop
            case .opOutput_Speed: return .opOutput_Speed
            case .opOutput_Start: return .opOutput_Start
            case .opOutput_Step_Speed: return .opOutput_Step_Speed
            case .opOutput_Time_Speed: return .opOutput_Time_Speed
            case .opOutput_Step_Sync: return .opOutput_Step_Sync
            case .opOutput_Time_Sync: return .opOutput_Time_Sync
            case .opOutput_Clr_Count: return .opOutput_Clr_Count
            case .opSound: return .opSound
            case .opDraw: return .opDraw
            case .opWrite: return .opWrite
            case .opCom_Set_SET_BRICKNAME: return .opCom_Set_SET_BRICKNAME
            case .opInput_Device_Clr_All: return .opInput_Device_Clr_All
            case .opInput_Device_Clr_Changes: return .opInput_Device_Clr_Changes
        }
    }
    
    public var playgroundValue: PlaygroundValue {
        let mappedParameters = parameters.map { $0.playgroundValue } 
        return .dictionary([type.rawValue: .array(mappedParameters)])
    }
    
    init?(playgroundValue: PlaygroundValue) {
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        guard let firstEntry = dictionary.first, let key = OperationType(rawValue: firstEntry.key) else {
            log(message: "firstEntry nil")
            return nil
        }
        
        guard case let .array(array) = firstEntry.value else {
            log(message: "array nil")
            return nil
        }
        
        let bytecodeEncodables = array.flatMap { BytecodeEncodable(playgroundValue: $0) }
        
        guard bytecodeEncodables.count == array.count else {
            log(message: "One or more values in \(playgroundValue) was not bytecodeencodable")
            return nil
        }
        
        switch key {
        case .opOutput_Set_Type:
            guard bytecodeEncodables.count == 4,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPort = bytecodeEncodables[2].rawValue as? OutputPort,
                let typeNumber = bytecodeEncodables[3].rawValue as? UInt8,
                let type = MotorType(rawValue: typeNumber) else {
                fatalError()
            }
            self = .opOutput_Set_Type(layer: layer, outputPort: outputPort, type: type)
        
        case .opOutput_Stop:
            guard bytecodeEncodables.count == 4,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort],
                let brake = bytecodeEncodables[3].rawValue as? Bool else {
                fatalError()
            }
            self = .opOutput_Stop(layer: layer, outputPorts: outputPorts, brake: brake)
            
        case .opOutput_Speed:
            guard bytecodeEncodables.count == 4,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort],
                let power = bytecodeEncodables[3].rawValue as? Int32 else {
                fatalError()
            }
            self = .opOutput_Speed(layer: layer, outputPorts: outputPorts, power: power)
            
        case .opOutput_Start:
            guard bytecodeEncodables.count == 3,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort] else {
                 fatalError()
            }
            self = .opOutput_Start(layer: layer, outputPorts: outputPorts)
            
        case .opOutput_Reset:
            guard bytecodeEncodables.count == 3,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort] else {
                fatalError()
            }
            self = .opOutput_Reset(layer: layer, outputPorts: outputPorts)
            
        case .opOutput_Step_Speed:
            guard bytecodeEncodables.count == 8,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort],
                let power = bytecodeEncodables[3].rawValue as? Int32,
                let rampUpDuration = bytecodeEncodables[4].rawValue as? Int32,
                let continueDuration = bytecodeEncodables[5].rawValue as? Int32,
                let rampDownDuration = bytecodeEncodables[6].rawValue as? Int32,
                let brake = bytecodeEncodables[7].rawValue as? Bool else {
                fatalError()
            }
            self = .opOutput_Step_Speed(
                layer: layer,
                outputPorts: outputPorts,
                power: power,
                rampUpDuration: rampUpDuration,
                continueDuration: continueDuration,
                rampDownDuration: rampDownDuration,
                brake: brake)
            
        case .opOutput_Time_Speed:
            guard bytecodeEncodables.count == 8,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort],
                let power = bytecodeEncodables[3].rawValue as? Int32,
                let rampUpDuration = bytecodeEncodables[4].rawValue as? Int32,
                let continueDuration = bytecodeEncodables[5].rawValue as? Int32,
                let rampDownDuration = bytecodeEncodables[6].rawValue as? Int32,
                let brake = bytecodeEncodables[7].rawValue as? Bool else {
                fatalError()
            }
            self = .opOutput_Time_Speed(
                layer: layer,
                outputPorts: outputPorts,
                power: power,
                rampUpDuration: rampUpDuration,
                continueDuration: continueDuration,
                rampDownDuration: rampDownDuration,
                brake: brake)

        case .opOutput_Step_Sync:
            guard bytecodeEncodables.count == 7,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort],
                let power = bytecodeEncodables[3].rawValue as? Int32,
                let turn = bytecodeEncodables[4].rawValue as? Int32,
                let tachoCount = bytecodeEncodables[5].rawValue as? Int32,
                let brake = bytecodeEncodables[6].rawValue as? Bool else {
                fatalError()
            }
            self = .opOutput_Step_Sync(
                layer: layer,
                outputPorts: outputPorts,
                power: power,
                turn: turn,
                tachoCount: tachoCount,
                brake: brake)
            
        case .opOutput_Time_Sync:
            guard bytecodeEncodables.count == 7,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort],
                let power = bytecodeEncodables[3].rawValue as? Int32,
                let turn = bytecodeEncodables[4].rawValue as? Int32,
                let duration = bytecodeEncodables[5].rawValue as? Int32,
                let brake = bytecodeEncodables[6].rawValue as? Bool else {
                fatalError()
            }
            self = .opOutput_Time_Sync(
                layer: layer,
                outputPorts: outputPorts,
                power: power,
                turn: turn,
                duration: duration,
                brake: brake)
            
        case .opOutput_Clr_Count:
            guard bytecodeEncodables.count == 3,
                let layer = bytecodeEncodables[1].rawValue as? Int32,
                let outputPorts = bytecodeEncodables[2].rawValue as? [OutputPort] else {
                fatalError()
            }
            self = .opOutput_Clr_Count(layer: layer, outputPorts: outputPorts)
            
        case .opInput_Device_Clr_All:
            guard bytecodeEncodables.count == 3 else {
                    fatalError()
            }
            self = .opInput_Device_Clr_All
            
        case .opInput_Device_Clr_Changes:
            guard bytecodeEncodables.count == 4,
                let layer = bytecodeEncodables[2].rawValue as? Int32,
                let inputPort = bytecodeEncodables[3].rawValue as? InputPort else {
                    fatalError()
            }
            self = .opInput_Device_Clr_Changes(layer: layer, inputPort: inputPort)
            
        case .opSound:
            guard bytecodeEncodables.count == 2,
                let soundCommand = bytecodeEncodables[1].rawValue as? SoundCommand else {
                fatalError()
            }
            self = .opSound(command: soundCommand)
        case .opDraw:
            guard bytecodeEncodables.count == 2,
                let drawCommand = bytecodeEncodables[1].rawValue as? DrawCommand else {
                fatalError()
            }
            self = .opDraw(command: drawCommand)
            
        case .opWrite:
            guard bytecodeEncodables.count == 2,
                let writeCommand = bytecodeEncodables[1].rawValue as? WriteCommand else {
                log(message: "Was unable to decode opWrite from PlaygroundValue: \(bytecodeEncodables), with size \(bytecodeEncodables.count)")
                fatalError()
            }
            self = .opWrite(command: writeCommand)
            
        case .opCom_Set_SET_BRICKNAME:
            guard bytecodeEncodables.count == 3,
                let newName = bytecodeEncodables[2].rawValue as? String else {
                log(message: "Was unable to decode opCom_Set_SET_BRICKNAME from PlaygroundValue: \(bytecodeEncodables), with size \(bytecodeEncodables.count)")
                fatalError()
                }
            self = .opCom_Set_SET_BRICKNAME(name: newName)
        }
    }
}
