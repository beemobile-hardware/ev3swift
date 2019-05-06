import Foundation
import PlaygroundSupport

extension ReplyOperation {
   
    private enum ReplyOperationType: String {
        case opInput_Device_Get_TypeMode
        case opInput_Device_Get_Ready_SI
        case opSound_Test
        case playgroundsGetPortData
        case opOutput_Busy
        case opCom_Get_GET_BRICKNAME
        case opInput_Device_GET_CONNECTION
    }
    
    private var type: ReplyOperationType {
        switch self {
        case .opInput_Device_Get_TypeMode(_, _): return .opInput_Device_Get_TypeMode
        case .opInput_Device_Get_Ready_SI(_, _, _, _): return .opInput_Device_Get_Ready_SI
        case .opSound_Test: return .opSound_Test
        case .playgroundsGetPortData: return .playgroundsGetPortData
        case .opOutput_Test(_): return .opOutput_Busy
        case .opCom_Get_GET_BRICKNAME(_): return .opCom_Get_GET_BRICKNAME
        case .opInput_Device_GET_CONNECTION(_, _): return .opInput_Device_GET_CONNECTION
        }
    }
    
    public var playgroundValue: PlaygroundValue {
        let mappedParameters = parameters(withGlobalVarIndex: 0).map { $0.playgroundValue } 
        return .dictionary([type.rawValue: .array(mappedParameters)])
    }
    
    init?(playgroundValue: PlaygroundValue) {
        
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        guard let firstEntry = dictionary.first, let key = ReplyOperationType(rawValue: firstEntry.key) else {
            log(message: "firstEntry nil")
            return nil
        }
        
        guard case let .array(array) = firstEntry.value else {
            log(message: "array nil")
            return nil
        }
        
        let bytecodeEncodables = array.flatMap({ BytecodeEncodable(playgroundValue: $0) })
        
        guard bytecodeEncodables.count == array.count else {
            log(message: "One or more values in \(playgroundValue) was not bytecodeencodable")
            return nil
        }
        
        switch key {
        case .opInput_Device_Get_TypeMode:
            guard bytecodeEncodables.count == 4,
                let layer = bytecodeEncodables[2].rawValue as? Int32,
                let port = bytecodeEncodables[3].rawValue as? Int32 else {
                fatalError()
            }
            self = .opInput_Device_Get_TypeMode(layer: layer, port: UInt8(port))
            
        case .opInput_Device_Get_Ready_SI:
            guard bytecodeEncodables.count == 8,
                let layer = bytecodeEncodables[2].rawValue as? Int32,
                let port = bytecodeEncodables[3].rawValue as? Int32,
                let type = bytecodeEncodables[4].rawValue as? Int32,
                let mode = bytecodeEncodables[5].rawValue as? Int32 else {
                fatalError()
            }
            self = .opInput_Device_Get_Ready_SI(layer: layer, port: UInt8(port), type: type, mode: mode)
        case .opSound_Test:
            self = .opSound_Test
        case .playgroundsGetPortData:
            self = .playgroundsGetPortData
        case .opCom_Get_GET_BRICKNAME:
            if let maxLength = bytecodeEncodables[2].rawValue as? Int32 {
                self = .opCom_Get_GET_BRICKNAME(maxLength: maxLength)
            } else {
                fatalError("Unable to deserialize opCom_Get_GET_BRICKNAME from playground value \(playgroundValue)")
            }
        case .opOutput_Busy:
            guard bytecodeEncodables.count == 2, let port = bytecodeEncodables[1].rawValue as? UInt8 else {
                fatalError("Error when trying to read opOutput_Busy: \(bytecodeEncodables.count), \(bytecodeEncodables[1].rawValue)")
            }
            self = .opOutput_Test(port: port)
        case .opInput_Device_GET_CONNECTION:
            guard bytecodeEncodables.count == 5,
                let layer = bytecodeEncodables[2].rawValue as? Int32,
                let port = bytecodeEncodables[3].rawValue as? UInt8 else {
                    fatalError("Unable to read opInput_Device_GET_CONNECTION: \(playgroundValue) ")
            }
            self = .opInput_Device_GET_CONNECTION(layer: layer, port: port)
        }
    }
}
