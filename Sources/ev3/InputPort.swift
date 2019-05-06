import Foundation
import PlaygroundSupport

/**
  Enum `.one`, `.two`, `.three`, or `.four`.
  */
public enum InputPort: UInt8, Port {
    case one = 0x00
    case two = 0x01
    case three = 0x02
    case four = 0x03
    
   
    public var inputValue: UInt8 {
        return self.rawValue
    }
    
    public static var all: [InputPort] {
        return [.one, .two, .three, .four]
    }
    
    public var localizedName: String {
        switch self {
        case .one:
            return "1"
            
        case .two:
            return "2"
            
        case .three:
            return "3"
            
        case .four:
            return "4"
        }
    }
    
    public var accessibleDescription: String {
        switch self {
        case .one:
            return NSLocalizedString("Port 1", comment: "Voice Over description of port 1")
            
        case .two:
            return NSLocalizedString("Port 2", comment: "Voice Over description of port 2")
            
        case .three:
            return NSLocalizedString("Port 3", comment: "Voice Over description of port 3")
            
        case .four:
            return NSLocalizedString("Port 4", comment: "Voice Over description of port 4")
        }
    }
    
    public var index: Int {
        return InputPort.all.index(of: self)!
    }
    
    public var batchReadIndex: Int {
        get {
            return Int(inputValue)
        }
    }
}

extension InputPort {
    // Add error handling for release
    public init?(playgroundValue: PlaygroundValue) {
        guard case let .integer(int) = playgroundValue, let port = InputPort(rawValue: UInt8(int)) else {
            log(message: "dictionary nil")
            return nil
        }
        self = port
    }

    public var playgroundValue: PlaygroundValue {
        return .integer(Int(self.rawValue))
    }
}
