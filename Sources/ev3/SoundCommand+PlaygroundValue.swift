import Foundation
import PlaygroundSupport

extension SoundCommand {
    
    private enum SoundCommandType: String {
        case `break`
        case tone
        case play
        case `repeat`
        case test
    }
    
    private var type: SoundCommandType {
        switch self {
        case .break: return .break
        case .tone(_, _, _): return .tone
        case .play(_, _): return .play
        case .repeat(_, _): return .repeat
        case .test: return .test
        }
    }
    
    var playgroundValue: PlaygroundValue {
        return .dictionary([type.rawValue: .array(parameters.map { $0.playgroundValue } )])
    }
    
    public init?(playgroundValue: PlaygroundValue) {
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        guard let firstEntry = dictionary.first, let key = SoundCommandType(rawValue: firstEntry.key) else {
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
        case .break where bytecodeEncodables.count == 1:
            self = .break
        case .tone:
            guard bytecodeEncodables.count == 4, let volume = bytecodeEncodables[1].rawValue as? Int32, let frequency = bytecodeEncodables[2].rawValue as? Int32, let duration = bytecodeEncodables[3].rawValue as? Int32 else {
                log(message: "integer nil")
                return nil
            }
            self = .tone(volume: volume, frequency: frequency, duration: duration)
        case .play:
            guard array.count == 3, let volume = bytecodeEncodables[1].rawValue as? Int32, let name = bytecodeEncodables[2].rawValue as? String else {
                log(message: "integer nil")
                return nil
            }
            self = .play(volume: volume, name: name)
        case .repeat:
            guard array.count == 3, let volume = bytecodeEncodables[1].rawValue as? Int32, let name = bytecodeEncodables[2].rawValue as? String else {
                log(message: "integer nil")
                return nil
            }
            self = .repeat(volume: volume, name: name)
        default:
            log(message: "Failed to deserialize SoundCommand from playground value: \(playgroundValue)")
            return nil
        }
    }
}
