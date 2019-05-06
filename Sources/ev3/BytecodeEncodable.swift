import Foundation

public enum BytecodeEncodable {
    case byte(UInt8)
    case float(Float32)
    case int(Int32)
    case string(String)
    case bool(Bool)
    case localVar(Int32)
    case globalVar(Int32)
    case output(OutputPort)
    case outputs([OutputPort])
    case input(InputPort)
    case inputs([InputPort])
    case soundCommand(SoundCommand)
    case drawCommand(DrawCommand)
    case writeCommand(WriteCommand)
    
    var encoded: Data {
        switch self {
        case let .byte(value):
            return Data(bytes: [value])
            
        case .float(_):
            fatalError("not implemented")
            
        case .localVar(_):
            fatalError("not implemented")
            
        case let .globalVar(value):
            var data = Data()
            // TODO: M: Function w/ descriptive name
            if value > -31 && value < 31 { // LC0(value)
                let isNegative = value < 0 ? UInt8(0x20) : UInt8(0x00)
                var byte = UInt8(value & 0x1F) | UInt8(0x60) | isNegative
                data.append(&byte, count: 1)
            } else {
                data.append(encodeLong(value: Int32(value), headerModifier: UInt8(0x60) | UInt8(0x20)))
            }
            return data
            
        case let .int(value):
            return VariableWidthData(value: value).encode()
            
        case let .string(string):
            var data = Data()
            var nullTerminatedStringByte = UInt8(0x84)
            data.append(&nullTerminatedStringByte, count:1)
            for c in string.utf8 {
                var char = UInt8(c)
                data.append(&char, count: 1)
            }
            var zeroTerm = UInt8(0)
            data.append(&zeroTerm, count: 1)
            return data
            
        case let .bool(value):
            return Data(bytes: [value ? UInt8(1) : UInt8(0)])
            
        case let .output(output):
            return Data(bytes: [output.rawValue])
        
        case let .outputs(outputs):
            var byte: UInt8 = 0
            outputs.forEach({ byte = byte | $0.rawValue })
            return Data(bytes: [byte])
            
        case let .input(input):
            return Data(bytes: [input.rawValue])
            
        case let .inputs(inputs):
            var byte: UInt8 = 0
            inputs.forEach({ byte = byte | $0.rawValue })
            return Data(bytes: [byte])
        
        case let .soundCommand(value):
            return value.encoded
        case let .drawCommand(value):
            return value.encoded
        case let .writeCommand(value):
            return value.encoded
        }
    }
    
    // Hasn't been checked for accuracy
    private func encodeLong(value:Int32, headerModifier:UInt8) -> Data {
        var data = Data()
        if value > -127 && value < 127 { // LC1(value)
            var lc1 = UInt8(0x81) | headerModifier
            data.append(&lc1, count: 1)
            var byte = UInt8(value & 0xFF)
            data.append(&byte, count: 1)
        } else if value > -32767 && value < 32767 { // LC2(value)
            // -144 2's complement 0x70FF - 0x0111 0000 1111 1111
            var lc2 = UInt8(0x82) | headerModifier
            data.append(&lc2, count: 1)
            var byte1 = UInt8(value & 0xFF)
            data.append(&byte1, count: 1)
            var byte2 = UInt8((value >> 8) & 0xFF)
            data.append(&byte2, count: 1)
        } else { // LC4(value)
            var lc4 = UInt8(0x83) | headerModifier
            data.append(&lc4, count: 1)
            var byte1 = UInt8(value & 0xFF)
            data.append(&byte1, count: 1)
            var byte2 = UInt8((value >> 8) & 0xFF)
            data.append(&byte2, count: 1)
            var byte3 = UInt8((value >> 16) & 0xFF)
            data.append(&byte3, count: 1)
            var byte4 = UInt8((value >> 24) & 0xFF)
            data.append(&byte4, count: 1)
        }
        return data
    }

    var rawValue: Any {
        switch self {
        case let .byte(v): return v
        case let .float(v): return v
        case let .localVar(v): return v
        case let .globalVar(v): return v
        case let .int(v): return v
        case let .string(v): return v
        case let .bool(v): return v
        case let .output(v): return v
        case let .outputs(v): return v
        case let .input(v): return v
        case let .inputs(v): return v
        case let .soundCommand(v): return v
        case let .drawCommand(v): return v
        case let .writeCommand(v): return v
        }
    }
}
