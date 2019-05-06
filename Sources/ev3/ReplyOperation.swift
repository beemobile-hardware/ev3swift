import Foundation
import PlaygroundSupport

public enum ReplyOperation {
    
    //Actual max length allowed is 13
    case opCom_Get_GET_BRICKNAME(maxLength: Int32)
    case opInput_Device_Get_Ready_SI(layer: Int32, port: UInt8, type: Int32, mode: Int32)
    case opInput_Device_Get_TypeMode(layer: Int32, port: UInt8)
    case opInput_Device_GET_CONNECTION(layer: Int32, port: UInt8)
    case opSound_Test
    case opOutput_Test(port: UInt8)
    case playgroundsGetPortData
    
    func encoded(withGlobalVarIndex index: Int32) -> Data {
        var message = Data()
        switch self {
        case .playgroundsGetPortData:
            var index = index
            for operation in subOperations {
                operation.parameters(withGlobalVarIndex: index).forEach { message.append($0.encoded) }
                index += Int32(operation.bytesToRead)
            }
        default:
            parameters(withGlobalVarIndex: index).forEach { message.append($0.encoded) }
        }
        return message
    }
    
    var portInputValue: UInt8? {
        switch self {
        case .opInput_Device_Get_TypeMode(_, let port): return port
        case .opInput_Device_Get_Ready_SI(_, let port, _, _): return port
        default: return nil
        }
    }
}
