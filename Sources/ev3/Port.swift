import Foundation
import PlaygroundSupport

public class PortUtils {
    public static func fromPlaygroundValue(playgroundValue: PlaygroundValue) -> Port? {
        
        guard case let .integer(i) = playgroundValue else {
            return nil
        }
        
        if i < 4 {
            return InputPort(rawValue: UInt8(i))
        } else {
            return OutputPort.valueToInput[i]
        }
        
    }
}

public protocol Port {
    var inputValue: UInt8 { get }
    var localizedName: String { get }
    var accessibleDescription: String { get }
    var batchReadIndex: Int { get }
    var index: Int { get }
    

    
}

extension Port {
    var playgroundValue: PlaygroundValue {
        get {
            return .integer(Int(self.inputValue))
        }
    }
}
