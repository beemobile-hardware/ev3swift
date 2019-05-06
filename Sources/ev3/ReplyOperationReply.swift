import Foundation

public enum ReplyOperationReply {
    
    case portTypeMode(Int, Int)
    case soundBusy(Bool)
    case portValue(Float32)
    case portData([PortData])
    case outputPortBusy(Bool)
    case brickName(String)
    case connectionType(port: UInt8, type: ConnectionTypeByteCode)
    
    var rawValue: Any? {
        switch self {
        case .portTypeMode(let type, let mode): return (type, mode)
        case .soundBusy(let bool): return bool
        case .portValue(let value): return value
        case .portData(let value): return value
        case .outputPortBusy(let bool): return bool
        case .brickName(let string): return string
        case let .connectionType(port, type): return (port, type)
        }
    }
}
