import Foundation

public enum CommandType {
    case system(reply: Bool)
    case direct(reply: Bool)
    
    public func encoded() -> Data {
        switch self {
        case .system (let reply):
            if reply {
                return Data(bytes: [0x01])
            } else {
                return Data(bytes: [0x81])
            }
        case .direct (let reply):
            if reply {
                return Data(bytes: [0x00])
            } else {
                return Data(bytes: [0x80])
            }
        }
    }
}
