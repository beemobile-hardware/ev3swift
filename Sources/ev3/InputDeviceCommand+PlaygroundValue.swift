//
//  DrawCommand+PlaygroundValue.swift
//  PlaygroundContent
//
//

import Foundation
import PlaygroundSupport

extension InputDeviceCommand {
    
    private enum InputDeviceCommandType: String {
        case clear
    }
    
    private var type: InputDeviceCommandType {
        switch self {
        case .clear:
            return .clear
        }
    }
    
    var playgroundValue: PlaygroundValue {
        return .dictionary([type.rawValue: .array(parameters.map { $0.playgroundValue } )])
    }
    
    public init?(playgroundValue: PlaygroundValue) {
        log(message: "got \(playgroundValue) trying to make a InputDeviceCommand")
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }

        guard let firstEntry = dictionary.first, let key = InputDeviceCommandType(rawValue: firstEntry.key) else {
            log(message: "firstEntry nil")
            return nil
        }

        guard case let .array(array) = firstEntry.value else {
            log(message: "array nil")
            return nil
        }

        let bytecodeEncodables = array.flatMap({ BytecodeEncodable(playgroundValue: $0) })

        guard bytecodeEncodables.count == array.count else {
            log(message: "One or more values in \(playgroundValue) was not bytecodeencodable")
            return nil
        }
        log(message: "encodables \(bytecodeEncodables) proceding")

        switch key {
        case .clear where bytecodeEncodables.count == 2:
            self = .clear
        default:
            log(message: "String as key for InputDeviceCommandType is unknown")
            return nil
        }
    }
}
