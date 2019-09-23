import Foundation
import PlaygroundSupport

extension BlockCondition {
    
    var playgroundValue: PlaygroundValue {
        switch self {
        case .time(let milliseconds):
            return .dictionary(["milliseconds": .integer(milliseconds)])
        case let .rateChange(delta, port):
            return .dictionary(["rate": .floatingPoint(Double(delta)), "port": port.playgroundValue])
        case let .anyChange(delta, port):
            return .dictionary(["anyChange": .floatingPoint(Double(delta)), "port": port.playgroundValue])
        case let .absoluteValue(value, relation, port):
            return .dictionary([
                "value": .floatingPoint(Double(value)),
                "relation": .integer(relation.rawValue),
                "port": port.playgroundValue
                ]
            )
        case let .outputBusy(ports):
            let values = ports.map { $0.playgroundValue }
            return .dictionary(["ports" : .array(values)])
        case .reply:
            return .dictionary(["reply": .boolean(true)])
        case .soundNotBusy:
            return .dictionary(["soundNotBusy": .boolean(true)])
        }
    }
    
    // Add error handling for release
    public init?(playgroundValue: PlaygroundValue?) {
        
        func portFromPlaygroundValue(_ portValue: PlaygroundValue) -> Port? {
            if case let .integer(portIndex) = portValue {
                if portIndex <= 3, let p = InputPort(playgroundValue: portValue){
                    return p
                } else if let p = OutputPort(playgroundValue: portValue) {
                    return p
                }
            }
            return nil
        }
        
        guard let playgroundValue = playgroundValue else {
            log(message: "playgroundValue nil")
            return nil
        }
        guard case let .dictionary(dict) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        if case let .integer(milliseconds)? = dict["milliseconds"] {
            self = .time(milliseconds: milliseconds)
        } else if case let .floatingPoint(value)? = dict["value"],
            case let .integer(relationRawValue)? = dict["relation"],
            let relation = Relation(rawValue: relationRawValue),
            let portValue = dict["port"],
            let port = portFromPlaygroundValue(portValue) {
      
            self = .absoluteValue(value: Float(value), relation: relation, port: port)
            
        } else if let _ = dict["reply"] {
            self = .reply
        } else if case let .floatingPoint(delta)? = dict["rate"],
            let portValue = dict["port"],
            let port = portFromPlaygroundValue(portValue){
            self = .rateChange(delta: Float(delta), port: port)
        } else if case let .floatingPoint(delta)? = dict["anyChange"],
            let portValue = dict["port"],
            let port = portFromPlaygroundValue(portValue){
            self = .anyChange(delta: Float(delta), port: port)
        } else if let _ = dict["soundNotBusy"] {
            self = .soundNotBusy
        } else if case let .array(ports)? = dict["ports"], dict.count == 1 {
            let mapped = ports.flatMap({ OutputPort(playgroundValue: $0) })
            self = .outputBusy(ports: mapped)
        } else {
            return nil
        }
    }
}
