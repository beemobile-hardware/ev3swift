import UIKit

/// Defines a `Port` and `PortType` that a `Plate` represents.
struct PlateConnection {
    var port: Port
    var type: PortType
}

extension PlateConnection {
    init?(portData: PortData) {
        guard let portType = PortType(rawValue: Int32(portData.type)) else { return nil }
        
        self.port = portData.port
        self.type = portType
    }
}

extension PlateConnection: Equatable {
    public static func ==(lhs: PlateConnection, rhs: PlateConnection) -> Bool {
        return lhs.port.isEqual(to: rhs.port) && lhs.type == rhs.type
    }
}

extension PlateConnection: Hashable {
    var hashValue: Int {
        let portHash: Int
        if let input = port as? InputPort {
            portHash = Int(input.inputValue)
        }
        else if let output = port as? OutputPort {
            portHash = Int(output.inputValue) * -1
        }
        else {
            fatalError("Unexpected port type - \(port)")
        }
        
        return type.hashValue ^ portHash
    }
}

extension Port {
    func isEqual(to port: Port) -> Bool {
        if let lhsPort = self as? InputPort, let rhsPort = port as? InputPort {
            return lhsPort == rhsPort
        }
        else if let lhsPort = self as? OutputPort, let rhsPort = port as? OutputPort {
            return lhsPort == rhsPort
        }
        else {
            return false
        }
    }
}

/// Extends `PlateConnection` to return the `UIColor` that should be used when
/// drawing.
extension PlateConnection {
    var color: UIColor {
        switch type {
        case .largeMotor:
            return UIColor.legoRed
            
        case .mediumMotor:
            return UIColor.legoDarkRed
            
        case .gyro:
            return UIColor.legoGreen
            
        case .infrared:
            return UIColor.legoDarkBlue
            
        case .ultrasonic:
            return UIColor.legoBlue
            
        case .touch:
            return UIColor.legoYellow
            
        case .light:
            return UIColor.legoLightBlue
            
        case .missing:
            return UIColor.black
        }
    }
}

/// Extends `PlateConnection` to provide a description that can be used for Voice Over.
extension PlateConnection {
    var accessibleDescription: String {
        return String(format: NSLocalizedString("%@ connected to %@", comment: "Voice Over description of a plate connection e.g. large motor connected to port A"),
                      type.accessibleDescription, port.accessibleDescription)
    }
}

/// Define `HasPort` and use it to extend an `Array` of `PlateConnection`s to
/// provide a count of the input and output ports.
protocol HasPort {
    var port: Port { get }
}

extension PlateConnection: HasPort {}

extension Array where Element: HasPort {
    var portCounts: (input: Int, output: Int) {
        return reduce((input: 0, output: 0)) { counts, connection in
            var result = counts
            if connection.port is InputPort {
                result.input += 1
            }
            else {
                result.output += 1
            }
            
            return result
        }
    }
}
