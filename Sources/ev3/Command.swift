import Foundation
import PlaygroundSupport

struct Command {
    let bytes: [UInt8]
    let messageNumber: Int
    let condition: BlockCondition
    let requiresReply: Bool
    let isUserInitiated: Bool
    let isEmpty: Bool
}
