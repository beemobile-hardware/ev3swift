import Foundation
import PlaygroundSupport

public struct PortData {
    public let portIndex: Int
    public let type: Int
    public let mode: Int
    public let value: Float
    
    var port: Port {
        let orderedPorts: [Port] = (InputPort.all as [Port]) + (OutputPort.all as [Port])
        return orderedPorts[portIndex]
    }
}

extension PortData {
    var playgroundValue: PlaygroundValue {
        let dictionary = [
            "portIndex": PlaygroundValue.integer(portIndex),
            "type": PlaygroundValue.integer(type),
            "mode": PlaygroundValue.integer(mode),
            "value": PlaygroundValue.floatingPoint(Double(value))
        ]
        return .dictionary(dictionary)
    }
    
    // TODO: Add error handling for release
    public init?(playgroundValue: PlaygroundValue) {
        guard case let .dictionary(dict) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        guard case let .integer(portIndex)? = dict["portIndex"] else {
            log(message: "port nil")
            return nil
        }
        guard case let .integer(type)? = dict["type"] else {
            log(message: "type nil")
            return nil
        }
        guard case let .integer(mode)? = dict["mode"] else {
            log(message: "mode nil")
            return nil
        }
        guard case let .floatingPoint(value)? = dict["value"] else {
            log(message: "value nil")
            return nil
        }
        
        self.portIndex = portIndex
        self.type = type
        self.mode = mode
        self.value = Float(value)
    }
}
