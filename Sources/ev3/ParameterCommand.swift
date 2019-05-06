import Foundation
import PlaygroundSupport

protocol ParameterCommand {
    var encoded: Data { get }
    var parameters: [BytecodeEncodable] { get }
    var playgroundValue: PlaygroundValue { get }
    
    init?(playgroundValue: PlaygroundValue)
}
