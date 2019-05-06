import Foundation
import PlaygroundSupport

extension WriteCommand {
    
    private enum WriteCommandType: String {
        case brickLight
    }
    
    private var type: WriteCommandType {
        switch self {
        case .brickLight:
            return .brickLight
        }
    }
    
    var playgroundValue: PlaygroundValue {
        return .dictionary([type.rawValue: .array(parameters.map { $0.playgroundValue } )])
    }
    
    public init?(playgroundValue: PlaygroundValue){
        log(message: "got \(playgroundValue) trying to make a WriteCommand")
        
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        guard let firstEntry = dictionary.first, let key = WriteCommandType(rawValue: firstEntry.key) else {
            log(message: "firstEntry nil")
            return nil
        }
        
        guard case let .array(array) = firstEntry.value else {
            log(message: "array nil")
            return nil
        }
        
        let bytecodeEncodables = array.flatMap({ BytecodeEncodable(playgroundValue: $0) })
        
        guard bytecodeEncodables.count == array.count else {
            log(message: "bytecodeEncodables.count wat not equal to array.count")
            return nil
        }
        
        switch key {
        case .brickLight:
            guard bytecodeEncodables.count == 2,
                let pattern = bytecodeEncodables[1].rawValue as? UInt8
                else {
                    log(message: "unable to make a led WriteCommand")
                    return nil
            }
            self = .brickLight(pattern: pattern)
        }
    }
}

