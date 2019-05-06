import Foundation
import PlaygroundSupport


/**
 Enum of output ports. Valid values are:
    - `.a`
    - `.b`
    - `.c`
    - `.d`
  */
public enum OutputPort: UInt8, Port {
    case a = 0x01
    case b = 0x02
    case c = 0x04
    case d = 0x08

    public var inputValue: UInt8 {
        switch self {
            case .a: return 16 // 0x10
            case .b: return 17 // 0x11
            case .c: return 18 // 0x12
            case .d: return 19 // 0x13
        }
    }
    
    public static let valueToInput: [Int: OutputPort] =
        [16:  .a,
         17:  .b,
         18:  .c,
         19:  .d]
    
    public var batchReadIndex: Int {
        get {
            switch self {
                case .a: return 4
                case .b: return 5
                case .c: return 6
                case .d: return 7
            }
        }
    }
    
    public static var all: [OutputPort] {
        return [.a, .b, .c, .d]
    }

    public var localizedName: String {
        switch self {
        case .a:
            return "A"
            
        case .b:
            return "B"
            
        case .c:
            return "C"
            
        case .d:
            return "D"
        }
    }
    
    public var accessibleDescription: String {
        switch self {
        case .a:
            return NSLocalizedString("Port A", comment: "Voice Over description of port A")
            
        case .b:
            return NSLocalizedString("Port B", comment: "Voice Over description of port B")
            
        case .c:
            return NSLocalizedString("Port C", comment: "Voice Over description of port C")
            
        case .d:
            return NSLocalizedString("Port D", comment: "Voice Over description of port D")
        }
    }
    
    public var index: Int {
        return OutputPort.all.index(of: self)!
    }
    
}

extension OutputPort {
    // Add error handling for release
    public init?(playgroundValue: PlaygroundValue) {
        guard case let .integer(int) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        if let port = OutputPort(rawValue: UInt8(int)) {
            self = port
        } else if let port = OutputPort.valueToInput[int] {
            self = port
        } else {
            return nil
        }
        
    }
    
    public var playgroundValue: PlaygroundValue {
        return .integer(Int(self.rawValue))
    }
}
