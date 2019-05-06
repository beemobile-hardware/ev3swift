import Foundation

extension ReplyOperation {
    var bytesToRead: Int {
        switch self {
        case .opInput_Device_Get_TypeMode(_, _): return 8
        case .opInput_Device_Get_Ready_SI(_, _, _, _): return 4
        case .opSound_Test: return 1
        case .playgroundsGetPortData: return subOperations.map { $0.bytesToRead } .reduce(0, +)
        case .opOutput_Test(_): return 1
        case .opCom_Get_GET_BRICKNAME(let maxLength): return Int(maxLength)
        case .opInput_Device_GET_CONNECTION(_, _): return 1
        }
    }
    
    @discardableResult func parse(_ data: Data) -> ReplyOperationReply {
        switch self {
        case .opOutput_Test(_):
            return .outputPortBusy(data[0] == 0x01)
        case .opInput_Device_Get_TypeMode(_, _):
            let type = Int(data[0])
            let mode = Int(data[1])
            return .portTypeMode(type, mode)
        case .opInput_Device_Get_Ready_SI(_, _, _, _):
            let dataRange:Range<Int> = (0) ..< (4)
            let dataBytes = [UInt8](data.subdata(in: dataRange))
            var value = Float32(0)
            memcpy(&value, dataBytes, 4)
            if value.isNaN || value.isInfinite {
                value = 0.0
            }
            return .portValue(value)
        case .opSound_Test:
            return .soundBusy(data[0] == 0x01)
        case .opCom_Get_GET_BRICKNAME:
            //Read until null terminator
            var nameData = Data()
            for c in data {
                if c == UInt8(0x00){
                    break
                }
                nameData.append(c)
            }
            if let brickName = String(data: nameData, encoding: String.Encoding.utf8) {
                return .brickName(brickName)
            } else {
                return .brickName("")
            }
        case let .opInput_Device_GET_CONNECTION(_, port):
            if let connectionType = ConnectionTypeByteCode(rawValue: data[0]) {
                return .connectionType(port: port, type: connectionType)
            }
            fatalError("Unknown connection type in response for \(self): \(data[0]) ")
        case .playgroundsGetPortData:
            
            func portIndexMap(for inputValue: UInt8) -> Int {
                switch inputValue {
                case 0, 1, 2, 3:
                    return Int(inputValue)
                case 16, 17, 18, 19:
                    return Int(inputValue - 12)
                default:
                    fatalError()
                }
            }
            
            var data = data
            var allPortData = [PortData]()
            var lastPortValue: Float32?
            
            for operation in subOperations {
                let replyType = operation.parse(data)
                if let portInputValue = operation.portInputValue {
                    if let portValue = lastPortValue, case let .portTypeMode(type, mode) = replyType {
                        let portData = PortData(portIndex: portIndexMap(for: portInputValue), type: type, mode: mode, value: portValue)
                        allPortData.append(portData)
                    } else if case let .portValue(value) = replyType {
                        lastPortValue = value
                    }
                }
                let bytesRead = operation.bytesToRead
                data = data.subdata(in: bytesRead..<data.count)
            }
            return .portData(allPortData)
        }
    }
}

