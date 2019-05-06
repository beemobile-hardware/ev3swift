import Foundation

public enum WriteCommand: ParameterCommand {
    // 0x1B led lights on brick
    /*
     LED Patterns:
     0x00 : Led off
     0x01 : Led green
     0x02 : Led red
     0x03 : Led orange
     0x04 : Led green flashing
     0x05 : Led red flashing
     0x06 : Led orange flashing
     0x07 :Ledgreenpulse
     0x08 : Led red pulse
     0x09 : Led orange pulse
    */
    case brickLight(pattern: UInt8)
    
    var parameters: [BytecodeEncodable] {
        switch self {
        case let .brickLight(pattern):
            return [.byte(0x1B), .byte(pattern)]
        }
    }
    
    var encoded: Data {
        var data = Data()
        parameters.forEach({ data.append($0.encoded) })
        return data
    }
    
}
