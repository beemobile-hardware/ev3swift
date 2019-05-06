//
//  InputDeviceCommand.swift
//  PlaygroundContent
//
//

import Foundation


public enum InputDeviceCommand: ParameterCommand {
    // CMD: CLR_ALL = 0x0A
    case clear

    var parameters: [BytecodeEncodable] {
        var messageParameters: [BytecodeEncodable]
        switch self {
        case .clear:
            messageParameters = [.byte(0x0A), .int(Int32(-1))]
        }
        return messageParameters
    }
    
    var encoded: Data {
        var data = Data()
        parameters.forEach { data.append($0.encoded) }
        return data
    }
}

