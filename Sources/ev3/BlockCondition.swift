import Foundation
import PlaygroundSupport

public enum Relation: Int {
    case lessThanOrEqual
    case equal
    case notEqual
    case greaterThanOrEqual
    case greaterThan
    case lessThan
}

public enum BlockCondition {
    case time(milliseconds: Int)
    case rateChange(delta: Float, port: Port)
    case anyChange(delta: Float, port: Port)
    case absoluteValue(value: Float, relation: Relation, port: Port)
    case reply
    case outputBusy(ports: [OutputPort])
    case soundNotBusy // I don't like Not in this name, but the condition we want to wait on is Not busy, we should have a Not condition that covers soundBusy...

    var absoluteValue: (value: Float, relation: Relation, port: Port)? {
        switch self {
        case let .absoluteValue(value, relation, port):
            return (value, relation, port)
        default:
            return nil
        }
    }
}
