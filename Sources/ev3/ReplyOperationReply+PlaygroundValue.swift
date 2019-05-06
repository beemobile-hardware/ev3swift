import Foundation

import PlaygroundSupport

extension ReplyOperationReply {
    
    private enum ReplyOperationReplyKey: String {
        case portTypeMode
        case portValue
        case portData
        case soundBusy
        case opOutput_Busy
        case brickName
        case connectionType
    }
    
    var playgroundValue: PlaygroundValue {
        switch self {
        case .portTypeMode(let type, let mode):
            return .dictionary([ReplyOperationReplyKey.portTypeMode.rawValue: .array([.integer(type), .integer(mode)])])
        case .portValue(let value):
            return .dictionary([ReplyOperationReplyKey.portValue.rawValue: .floatingPoint(Double(value))])
        case .portData(let value):
            return .dictionary([ReplyOperationReplyKey.portData.rawValue: .array(value.map { $0.playgroundValue } )])
        case .soundBusy(let b):
            return .dictionary([ReplyOperationReplyKey.soundBusy.rawValue: .boolean(b)])
        case .outputPortBusy(let b):
            return .dictionary([ReplyOperationReplyKey.opOutput_Busy.rawValue : .boolean(b)])
        case .brickName(let s):
            return .dictionary([ReplyOperationReplyKey.brickName.rawValue: .string(s)])
        case let .connectionType(port, type):
            return
                .dictionary([
                    ReplyOperationReplyKey.connectionType.rawValue:
                        .array(
                            [
                                .integer(Int(port)),
                                .integer(Int(type.rawValue))
                            ])
                    ])
        }
    }
    
    // Add error handling for release
    public init?(playgroundValue: PlaygroundValue) {
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        guard let firstEntry = dictionary.first, let key = ReplyOperationReplyKey(rawValue: firstEntry.key) else {
            log(message: "dictionary nil")
            return nil
        }
        
        switch key {
        case .portTypeMode:
            if case let .array(value) = firstEntry.value, value.count == 2, case let .integer(type) = value[0], case let .integer(mode) = value[1] {
                self = .portTypeMode(type, mode)
            } else {
                return nil
            }
        case .portValue:
            if case let .floatingPoint(value) = firstEntry.value {
                self = .portValue(Float32(value))
            } else {
                return nil
            }
        case .portData:
            if case let .array(value) = firstEntry.value {
                let mapped = value.flatMap({ PortData(playgroundValue: $0) })
                self = .portData(mapped)
            } else {
                return nil
            }
        case .soundBusy:
            if case let .boolean(value) = firstEntry.value {
                self = .soundBusy(value)
            } else {
                return nil
            }
        case .opOutput_Busy:
            if case let .boolean(value) = firstEntry.value {
                self = .outputPortBusy(value)
            } else {
                return nil
            }
        case .brickName:
            if case let .string(s) = firstEntry.value {
                self = .brickName(s)
            } else {
                return nil
            }
        case .connectionType:
            if case let .array(value) = firstEntry.value,
            value.count == 2,
                case let .integer(port) = value[0],
                case let .integer(type) = value[1],
                let connectionType = ConnectionTypeByteCode(rawValue: UInt8(type)){
                self = .connectionType(port: UInt8(port), type: connectionType)
            } else {
                fatalError("Unable to deserialize connectionType from \(playgroundValue)")
            }
        }
    }
}

