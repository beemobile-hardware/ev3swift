import Foundation

extension Operation {
    
    var parameters: [BytecodeEncodable] {
        
        var messageParameters: [BytecodeEncodable]
        
        switch self {
        case let .opOutput_Set_Type(layer, outputPort, type):
            messageParameters = [
                .byte(0xA1),
                .int(layer),
                .output(outputPort),
                .byte(type.rawValue)
            ]
        case let .opOutput_Reset(layer, outputPorts):
            messageParameters = [
                .byte(0xA2),
                .int(layer),
                .outputs(outputPorts)
            ]
        case let .opOutput_Stop(layer, outputPorts, shouldBrake):
            messageParameters = [
                .byte(0xA3),
                .int(layer),
                .outputs(outputPorts),
                .bool(shouldBrake)
            ]
        case let .opOutput_Speed(layer, outputPorts, power):
            messageParameters = [
                .byte(0xA5),
                .int(layer),
                .outputs(outputPorts),
                .int(power.clamped(to: -100...100))
            ]
        case let .opOutput_Start(layer, outputPorts):
            messageParameters =  [
                .byte(0xA6),
                .int(layer),
                .outputs(outputPorts)
            ]
        case let .opOutput_Step_Speed(layer, outputPorts, power, rampUpDuration, continueDuration, rampDownDuration, shouldBrake):
            messageParameters = [
                .byte(0xAE),
                .int(layer),
                .outputs(outputPorts),
                .int(power.clamped(to: -100...100)),
                .int(rampUpDuration),
                .int(continueDuration),
                .int(rampDownDuration),
                .bool(shouldBrake)
            ]
        case let .opOutput_Time_Speed(layer, outputPorts, power, rampUpDuration, continueDuration, rampDownDuration, shouldBrake):
            messageParameters = [
                .byte(0xAF),
                .int(layer),
                .outputs(outputPorts),
                .int(power.clamped(to: -100...100)),
                .int(rampUpDuration),
                .int(continueDuration),
                .int(rampDownDuration),
                .bool(shouldBrake)
            ]
        case let .opOutput_Step_Sync( layer, outputPorts, power, turn, tachoCount, shouldBrake):
            messageParameters = [
                .byte(0xB0),
                .int(layer),
                .outputs(outputPorts),
                .int(power.clamped(to: -100...100)),
                .int(turn.clamped(to: -200...200)),
                .int(tachoCount),
                .bool(shouldBrake)
            ]
        case let .opOutput_Time_Sync(layer, outputPorts, power, turn, duration, shouldBrake):
            messageParameters = [
                .byte(0xB1),
                .int(layer),
                .outputs(outputPorts),
                .int(power.clamped(to: -100...100)),
                .int(turn.clamped(to: -200...200)),
                .int(duration),
                .bool(shouldBrake)
            ]
        case let .opOutput_Clr_Count(layer, outputPorts):
            messageParameters = [
                .byte(0xB2),
                .int(layer),
                .outputs(outputPorts)
            ]
        case let .opSound(command):
            messageParameters = [
                .byte(0x94),
                .soundCommand(command)
            ]
        case let .opDraw(command):
            messageParameters = [
                .byte(0x84),
                .drawCommand(command)
            ]
        case let .opWrite( command):
            messageParameters = [
                .byte(0x82),
                .writeCommand(command)
            ]
        case let .opCom_Set_SET_BRICKNAME(name):
            let truncIndex: String.Index
            
            let unsafeChars =
                CharacterSet
                    .alphanumerics
                    .inverted
            
            let filteredName = name.components(separatedBy: unsafeChars).joined(separator: "")
            
            if filteredName.characters.count <= 13 {
                truncIndex = filteredName.endIndex
            } else {
                truncIndex = filteredName.index(after: filteredName.index(filteredName.startIndex, offsetBy: 13))
            }
                
            let truncatedName = String(filteredName[..<truncIndex])
            messageParameters = [
                .byte(0xD4),
                .byte(0x08),
                .string(truncatedName)
            ]
        case .opInput_Device_Clr_All:
            messageParameters = [
                .byte(0x99),
                .byte(0x0A),
                .int(Int32(-1))
            ]
        case let .opInput_Device_Clr_Changes(layer, port):
            messageParameters = [
                .byte(0x99),
                .byte(0x1A),
                .int(layer),
                .input(port)
            ]
        }
        
        return messageParameters
    }
}
