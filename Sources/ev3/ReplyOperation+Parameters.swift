import Foundation

extension ReplyOperation {
    
    func parameters(withGlobalVarIndex index: Int32) -> [BytecodeEncodable] {
        var messageParameters: [BytecodeEncodable]
        
        switch self {
        case let .opInput_Device_Get_TypeMode(layer, port):
            messageParameters =  [
                .byte(0x05),
                .int(layer),
                .int(Int32(port)),
                .globalVar(index),
                .globalVar(Int32(index + 1))
            ]
        case let .opInput_Device_Get_Ready_SI(layer, port, type, mode):
            messageParameters = [
                .byte(0x1D),
                .int(layer),
                .int(Int32(port)),
                .int(type),
                .int(mode),
                .int(Int32(1)),
                .globalVar(index)
            ]
        case .opOutput_Test(let port):
            let layer = BytecodeEncodable.byte(0x00)
            let portNum = BytecodeEncodable.byte(port)
            return [.byte(0xA9), layer, portNum, .globalVar(index)]
        case .playgroundsGetPortData:
            return Array(subOperations.map { $0.parameters(withGlobalVarIndex: index) } .joined())
        case .opSound_Test:
            return [.byte(0x95), .globalVar(index)]
        case let .opCom_Get_GET_BRICKNAME(maxLength):
            return [.byte(0xD3), .byte(0x0D), .int(maxLength), .globalVar(index)]
        case let .opInput_Device_GET_CONNECTION(layer, port):
            return [.byte(0x99), .byte(0x0C), .int(layer), .int(Int32(port)), .globalVar(index)]
        }
        messageParameters.insert(.byte(0x99), at: 0)
        return messageParameters
    }
    
    var subOperations: [ReplyOperation] {
        switch self {
        case .playgroundsGetPortData:
            var replyOperations: [ReplyOperation] = []
            let ports: [Port] = (InputPort.all as [Port]) + OutputPort.all
            for port in ports {
                let operations: [ReplyOperation] = [
                    .opInput_Device_Get_Ready_SI(layer: 0, port: port.inputValue, type: 0, mode: -1),
                    .opInput_Device_Get_TypeMode(layer: 0, port: port.inputValue)
                ]
                replyOperations += operations
            }
            return replyOperations
        default:
            return []
        }
    }
}
