import Foundation

//Input Methods
extension RobotFoundation {
    // MARK: - Ultrasonic Sensor
    
    public func measureUltrasonicCentimeters(on port: InputPort) -> Float {
        return readSensor(on: port, type: .ultrasonic, mode: .centimeters)
    }
    
    public func measureUltrasonicInches(on port: InputPort) -> Float {
        return readSensor(on: port, type: .ultrasonic, mode: .inches)
    }
    
    // MARK: - Gyro Sensor
    
    public func measureGyroAngle(on port: InputPort) -> Float {
        return readSensor(on: port, type: .gyro, mode: .angle)
    }
    
    public func measureGyroRate(on port: InputPort) -> Float {
        return readSensor(on: port, type: .gyro, mode: .rate)
    }

    public func resetGyro(on port: InputPort){
        let resetOps: [ReplyOperation] = [
            .opInput_Device_Get_Ready_SI(
                layer: 0,
                port: port.inputValue,
                type: PortType.gyro.rawValue,
                mode: PortMode.rate.EV3Value(for: .gyro)),
            .opInput_Device_Get_Ready_SI(
                layer: 0,
                port: port.inputValue,
                type: PortType.gyro.rawValue,
                mode: PortMode.angle.EV3Value(for: .gyro))
        ]
        run(resetOps)
    }
    
    // MARK: - Touch Sensor
    
    public func measureTouch(on port: InputPort) -> Bool {
        let touchstate = readSensor(on: port, type: .touch, mode: .touch)
        return touchstate != 0.0
    }
    
    public func measureTouchCount(on port: InputPort) -> Float {
        return readSensor(on: port, type: .touch, mode: .bumps)
    }
    
    public func resetTouchCount(on port: InputPort) {
        run([Operation.opInput_Device_Clr_Changes(layer: 0, inputPort: port)])
    }
    
    // MARK: - Light Sensor
    
    public func measureLightColor(on port: InputPort) -> ColorValue {
        let rawValue = readSensor(on: port, type: .light, mode: .color)
        if let color = ColorValue(rawValue: rawValue) {
            return color
        } else {
            log(message:"Error, got a non-color value when trying to read port \(port) as color")
            return .unavailable
        }
    }
    
    public func measureLightReflection(on port: InputPort) -> Float {
        return readSensor(on: port, type: .light, mode: .reflect)
    }
    
    public func measureLightAmbient(on port: InputPort) -> Float {
        return readSensor(on: port, type: .light, mode: .ambient)
    }
    
    // MARK: - IR Sensor

    public func measureIRProximity(on port: InputPort) -> Float {
        return readSensor(on: port, type: .infrared, mode: .proximity)
    }
    public func measureIRSeek(on port: InputPort) -> Float {
        return readSensor(on: port, type: .infrared, mode: .seek)
    }
    
    // MARK: - Motor Sensor
    public func measureMotorDegrees(on port: OutputPort) -> Float {
        // Motor size doesn't matter here
        return readSensor(on: port, type: .mediumMotor, mode: .angle)
    }
    
    public func measureMotorRotations(on port: OutputPort) -> Float {
        // Motor size doesn't matter here
        return readSensor(on: port, type: .mediumMotor, mode: .rotations)
    }
    
    public func measureMotorPower(on port: OutputPort) -> Float {
        // Motor size doesn't matter here
        return readSensor(on: port, type: .mediumMotor, mode: .power)
    }
    
    public func resetMotor(on port: OutputPort) {
        run([Operation.opOutput_Clr_Count(layer: 0, outputPorts: [port])])
    }
}
