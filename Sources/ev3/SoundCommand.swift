import Foundation

public enum SoundCommand: ParameterCommand {
    case `break`
    case tone(volume: Int32, frequency: Int32, duration: Int32)
    case play(volume: Int32, name: String)
    case `repeat`(volume: Int32, name: String)
    case test //busy = 1, ready = 0
    
    var parameters: [BytecodeEncodable] {
        let messageParameters: [BytecodeEncodable]
        switch self {
        case .break:
            messageParameters = [.byte(0x00)]
        case .tone(let volume, let frequency, let duration):
            messageParameters = [.byte(0x01), .int(volume.clamped(to: 0...100)), .int(frequency.clamped(to: 250...10000)), .int(duration)]
        case .play(let volume, let name):
            messageParameters = [.byte(0x02), .int(volume.clamped(to: 0...100)), .string(name)]
        case .repeat(let volume, let name):
            messageParameters = [.byte(0x03), .int(volume.clamped(to: 0...100)), .string(name)]
        case .test:
            messageParameters = []
        }
        return messageParameters
    }
    
    var encoded: Data {
        var data = Data()
        parameters.forEach({ data.append($0.encoded) })
        return data
    }
}

