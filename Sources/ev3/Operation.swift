import Foundation
import PlaygroundSupport

public enum Operation {
    
    //Actual max length allowed is 13 characters
    case opCom_Set_SET_BRICKNAME(name: String)
    
    case opOutput_Set_Type(layer: Int32, outputPort: OutputPort, type: MotorType)
    case opOutput_Start(layer: Int32, outputPorts: [OutputPort])
    case opOutput_Stop(layer: Int32, outputPorts: [OutputPort], brake: Bool)
    case opOutput_Speed(layer: Int32, outputPorts: [OutputPort], power: Int32)
    
    case opOutput_Reset(layer: Int32, outputPorts: [OutputPort])
    
    case opOutput_Time_Speed(layer: Int32, outputPorts: [OutputPort], power: Int32, rampUpDuration: Int32, continueDuration: Int32, rampDownDuration: Int32, brake: Bool)
    case opOutput_Step_Speed(layer: Int32, outputPorts: [OutputPort], power: Int32, rampUpDuration: Int32, continueDuration: Int32, rampDownDuration: Int32, brake: Bool)
    
    case opOutput_Step_Sync(layer: Int32, outputPorts: [OutputPort], power: Int32, turn: Int32, tachoCount: Int32, brake: Bool)
    case opOutput_Time_Sync(layer: Int32, outputPorts: [OutputPort], power: Int32, turn: Int32, duration: Int32, brake: Bool)
    
    case opOutput_Clr_Count(layer: Int32, outputPorts: [OutputPort])
    
    case opSound(command: SoundCommand)

    case opDraw(command: DrawCommand)
    
    case opWrite(command: WriteCommand)
    
    case opInput_Device_Clr_All
    case opInput_Device_Clr_Changes(layer: Int32, inputPort: InputPort)
    
    func encoded() -> Data {
        var message = Data()
        parameters.forEach({ message.append($0.encoded) })
        return message
    }
}
