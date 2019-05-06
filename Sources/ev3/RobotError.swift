import Foundation
import PlaygroundSupport

public enum RobotError {
    
    public static let playgroundValueKey = "RobotError"

    case portMismatchError(
        port: Port,
        expectedType: PortType,
        actualType: PortType,
        method: String )
    
    case noError
    
    init?(playgroundValue: PlaygroundValue) {
        switch playgroundValue {
        case let .array(values) where values.isEmpty: self = .noError
        case let .array(values):
            
            guard let port = PortUtils.fromPlaygroundValue(playgroundValue: values[0]),
                  case let .integer(expected) = values[1],
                  case let .integer(actual) = values[2],
                  case let .string(method) = values[3],
                  let expectedType = PortType(rawValue: Int32(expected)),
                  let actualType = PortType(rawValue: Int32(actual)) else {
                    return nil
            }
            
            self = .portMismatchError(
                port: port,
                expectedType: expectedType,
                actualType: actualType,
                method: method)
        default: return nil
        }
    }
    
    public func toString() -> String {
        switch self {
        case .noError: return "No error"
        case let .portMismatchError(port, expectedType, actualType, method):
            return String(format: NSLocalizedString("Expected %@ on Port %@ in call %@, actual: %@", comment: "String representation of the robot error in regards to the port mismatch"), String(describing: expectedType), String(describing: port), method, String(describing: actualType))
        }
    }
    
    public func playgroundValue() -> PlaygroundValue {
        switch self {
            case let .portMismatchError(port, expectedType, actualType, method):
                return .array([
                                port.playgroundValue,
                                .integer(Int(expectedType.rawValue)),
                                .integer(Int(actualType.rawValue)),
                                .string(method)
                            ])
            case .noError:
                return .array([])
        }

    }
    
}

extension RobotError: Equatable {
    
    static public func ==(lhs: RobotError, rhs: RobotError) -> Bool {
        switch (lhs, rhs) {
        case let (.portMismatchError(port: lport, expectedType: lexpectedType, actualType: lactualType, method: lmethod),
                  .portMismatchError(port: rport, expectedType: rexpectedType, actualType: ractualType, method: rmethod)):
            return lport.isEqual(to: rport) &&
                lexpectedType.rawValue == rexpectedType.rawValue &&
                lactualType.rawValue == ractualType.rawValue &&
                lmethod == rmethod
        case (.noError, .noError):
            return true
        default:
            return false
        }
    }
    
}
