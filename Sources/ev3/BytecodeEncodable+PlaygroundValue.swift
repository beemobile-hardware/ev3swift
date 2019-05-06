import Foundation
import PlaygroundSupport

extension BytecodeEncodable {
    
    private enum BytecodeEncodableKey: String {
        case byte
        case float
        case localVar
        case globalVar
        case int
        case string
        case bool
        case output
        case outputs
        case input
        case inputs
        case soundCommand
        case drawCommand
        case writeCommand
    }
    
    //encoding
    var playgroundValue: PlaygroundValue {
        let keyValue: (BytecodeEncodableKey, PlaygroundValue)
        switch self {
        case let .byte(value): keyValue = (.byte, .data(Data(bytes: [value])))
        case let .float(value):
            return .dictionary([BytecodeEncodableKey.float.rawValue: .floatingPoint(Double(value))])
        case let .localVar(value):
            return .dictionary([BytecodeEncodableKey.localVar.rawValue: .integer(Int(value))])
        case let .globalVar(value):
            return .dictionary([BytecodeEncodableKey.globalVar.rawValue: .integer(Int(value))])
        case let .int(value):
            return .dictionary([BytecodeEncodableKey.int.rawValue: .integer(Int(value))])
        case let .string(value):
            return .dictionary([BytecodeEncodableKey.string.rawValue: .string(value)])
        case let .bool(value):
            return .dictionary([BytecodeEncodableKey.bool.rawValue: .boolean(value)])
        case let .output(output):
            return .dictionary([BytecodeEncodableKey.output.rawValue: output.playgroundValue])
        case let .outputs(outputs):
            let values = outputs.map { $0.playgroundValue }
            return .dictionary([BytecodeEncodableKey.outputs.rawValue: .array(values)])
        case let .input(input):
            return .dictionary([BytecodeEncodableKey.input.rawValue: input.playgroundValue])
        case let .inputs(inputs):
            let values = inputs.map { $0.playgroundValue }
            return .dictionary([BytecodeEncodableKey.inputs.rawValue: .array(values)])
        case let .soundCommand(value):
            return .dictionary([BytecodeEncodableKey.soundCommand.rawValue: value.playgroundValue])
        case let .drawCommand(value):
            return .dictionary([BytecodeEncodableKey.drawCommand.rawValue: value.playgroundValue])
        case let .writeCommand(value):
            return .dictionary([BytecodeEncodableKey.writeCommand.rawValue: value.playgroundValue])
        }
        
        return .dictionary([keyValue.0.rawValue: keyValue.1])
    }
    
    // Add error handling for release
    public init?(playgroundValue: PlaygroundValue) {
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }
        
        guard let firstEntry = dictionary.first, let key = BytecodeEncodableKey(rawValue: firstEntry.key) else {
            log(message: "dictionary nil")
            return nil
        }
        
        switch key {
        case .byte:
            if case let .data(value) = firstEntry.value, let byte = value.first {
                self = .byte(byte)
            } else {
                return nil
            }
        case .float:
            if case let .floatingPoint(value) = firstEntry.value {
                self = .float(Float32(value))
            } else {
                return nil
            }
        case .localVar:
            if case let .integer(value) = firstEntry.value {
                self = .localVar(Int32(value))
            } else {
                return nil
            }
        case .globalVar:
            if case let .integer(value) = firstEntry.value {
                self = .globalVar(Int32(value))
            } else {
                return nil
            }
        case .int:
            if case let .integer(value) = firstEntry.value {
                self = .int(Int32(value))
            } else {
                return nil
            }
        case .string:
            if case let .string(value) = firstEntry.value {
                self = .string(value)
            } else {
                return nil
            }
        case .bool:
            if case let .boolean(value) = firstEntry.value {
                self = .bool(value)
            } else {
                return nil
            }
        case .output:
            if let output = OutputPort(playgroundValue: firstEntry.value) {
                self = .output(output)
            } else {
                return nil
            }
        case .outputs:
            if case let .array(value) = firstEntry.value {
                let mapped = value.flatMap { OutputPort(playgroundValue: $0) }
                self = .outputs(mapped)
            } else {
                return nil
            }
        case .input:
            if let input = InputPort(playgroundValue: firstEntry.value) {
                self = .input(input)
            } else {
                return nil
            }
        case .inputs:
            if case let .array(value) = firstEntry.value {
                let mapped = value.flatMap { InputPort(playgroundValue: $0) }
                self = .inputs(mapped)
            } else {
                return nil
            }
        case .soundCommand:
            if let command = SoundCommand(playgroundValue: firstEntry.value) {
                self = .soundCommand(command)
            } else {
                return nil
            }
        case .drawCommand:
            log(message: "Turning a playgroundValue \(firstEntry.value) into a DrawCommand")
            if let command = DrawCommand(playgroundValue: firstEntry.value) {
                self = .drawCommand(command)
            } else {
                return nil
            }
        case .writeCommand:
            log(message: "Turning a playgroundValue \(firstEntry.value) into a WriteCommand")
            if let command = WriteCommand(playgroundValue: firstEntry.value){
                self = .writeCommand(command)
            } else {
                return nil
            }
        }
    }
}
