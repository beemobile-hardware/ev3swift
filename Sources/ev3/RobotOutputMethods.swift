import Foundation

fileprivate enum BrickLightPattern: UInt8 {
    case off = 0x00
    case green = 0x01
    case red = 0x02
    case orange = 0x03
    case greenFlashing = 0x04
    case redFlashing = 0x05
    case orangeFlashing = 0x06
    case greenPulsating = 0x07
    case redPulsating = 0x08
    case orangePulsating = 0x09
}

// Output methods
extension RobotFoundation {
    
    private func isMotor(_ value: PortData) -> Bool {
        return value.type == Int(PortType.mediumMotor.rawValue) ||
            value.type == Int(PortType.largeMotor.rawValue)
    }
    
    private func isMediumMotor(_ value: PortData) -> Bool {
        return value.type == Int(PortType.mediumMotor.rawValue)
    }
    
    private func missingMotors(onPorts ports: [OutputPort], caller: String = #function) -> Bool {
        if let portData = portData
        {
            let portValues = ports.flatMap { portData[$0.inputValue] }
            
            let nonMotors = portValues.filter({ !isMotor($0) })

            let missingMotors = nonMotors.map {
                RobotError.portMismatchError(
                    port: $0.port,
                    expectedType: .largeMotor,
                    actualType: PortType(rawValue: Int32($0.type))!,
                    method: caller)
            }
            
            //Report to liveview
            for error in missingMotors {
                send(error.playgroundValue(), forKey: .robotError)
            }
            
            log(message: "Missing motors: Sent errors to live view, returning \(!missingMotors.isEmpty)")
            return !missingMotors.isEmpty
            
        }
        return false
    }
    
    private func assertOnlyLargeMotors(onPorts ports: [OutputPort], caller: String = #function) -> Bool {
        if let portData = portData {
            let mediumMotors = ports
                    .flatMap { portData[$0.inputValue] }
                    .filter(isMediumMotor)
            
            let errors = mediumMotors.map {
                RobotError.portMismatchError(
                    port: $0.port,
                    expectedType: .largeMotor,
                    actualType: .mediumMotor,
                    method: caller)
            }
            
            for error in errors {
                send(error.playgroundValue(), forKey: .robotError)
            }
            
            log(message: "Medium motors found in move method: \(errors)")
            return errors.isEmpty
        }
        return true
    }
    
    // MARK: - Status Light
    
    public func brickLightOn(withColor color: BrickLightColor, inMode mode: BrickLightMode) {
        let pattern: BrickLightPattern
        
        switch (color, mode) {
        // on modes
        case (.green, .on): pattern = .green
        case (.red, .on): pattern = .red
        case (.orange, .on): pattern = .orange
            
        // flashing modes
        case (.green, .flashing): pattern = .greenFlashing
        case (.red, .flashing): pattern = .redFlashing
        case (.orange, .flashing): pattern = .orangeFlashing
            
        // pulsating modes
        case (.green, .pulsating): pattern = .greenPulsating
        case (.red, .pulsating): pattern = .redPulsating
        case (.orange, .pulsating): pattern = .orangePulsating
        }
        
        let writeCmd = WriteCommand.brickLight(pattern: pattern.rawValue)
        run([.opWrite(command: writeCmd)])
    }
    
    public func brickLightOff() {
        let writeCmd = WriteCommand.brickLight(pattern: BrickLightPattern.off.rawValue)
        run([.opWrite(command: writeCmd)])
    }
    
    // MARK: - Move
    
    // Turn the motors on leftPort and rightPort off
    public func stopMove(leftPort: OutputPort, rightPort: OutputPort, withBrake: Bool) {
        if missingMotors(onPorts: [leftPort, rightPort]) { return }
        
        let operation = Operation.opOutput_Stop(layer: 0, outputPorts: [leftPort, rightPort], brake: withBrake)
        run([operation])
    }
    
    // Turn on motors on leftPort and rightPort at leftPower and rightPower forever
    public func move(leftPort: OutputPort, rightPort: OutputPort, leftPower: Float, rightPower: Float) {
        let isMissingAMotor = missingMotors(onPorts: [leftPort, rightPort])
        let onlyLargeMotors = assertOnlyLargeMotors(onPorts: [leftPort, rightPort])
        if isMissingAMotor || !onlyLargeMotors { return }
        
        let setLeftPower = Operation.opOutput_Speed(layer: 0, outputPorts: [leftPort], power: Int32(leftPower))
        let setRightPower = Operation.opOutput_Speed(layer: 0, outputPorts: [rightPort], power: Int32(rightPower))
        let startMotors = Operation.opOutput_Start(layer: 0, outputPorts: [leftPort, rightPort])
        run([setLeftPower, setRightPower, startMotors])
    }
    
    // MARK: Synchronized Motors API
    
    // Tank move for seconds
    public func move(forSeconds seconds: Float, leftPort: OutputPort, rightPort: OutputPort, leftPower: Float, rightPower: Float, brakeAtEnd: Bool) {
        let isMissingAMotor = missingMotors(onPorts: [leftPort, rightPort])
        let onlyLargeMotors = assertOnlyLargeMotors(onPorts: [leftPort, rightPort])
        if isMissingAMotor || !onlyLargeMotors { return }
        
        let tankPower = calcTankPower(leftPower: leftPower, rightPower: rightPower)
        let tankTurn = calcTankTurn(leftPower: leftPower, rightPower: rightPower, tankPower: tankPower)
        
        let operation = Operation.opOutput_Time_Sync(layer: 0, outputPorts: [leftPort, rightPort], power: tankPower, turn: tankTurn, duration: Int32(seconds * 1000), brake: brakeAtEnd)
        
        run([operation], condition: BlockCondition.outputBusy(ports: [leftPort, rightPort]))
    }
    
    // Tank move for degrees
    public func move(forDegrees degrees: Float, leftPort: OutputPort, rightPort: OutputPort, leftPower: Float, rightPower: Float, brakeAtEnd: Bool) {
        let isMissingAMotor = missingMotors(onPorts: [leftPort, rightPort])
        let onlyLargeMotors = assertOnlyLargeMotors(onPorts: [leftPort, rightPort])
        if isMissingAMotor || !onlyLargeMotors { return }
        
        let tankPower = calcTankPower(leftPower: leftPower, rightPower: rightPower)
        let tankTurn = calcTankTurn(leftPower: leftPower, rightPower: rightPower, tankPower: tankPower)
        
        let operation = Operation.opOutput_Step_Sync(layer: 0, outputPorts: [leftPort, rightPort], power: tankPower, turn: tankTurn, tachoCount: Int32(degrees), brake: brakeAtEnd)
        
        run([operation], condition: BlockCondition.outputBusy(ports: [leftPort, rightPort]))
    }
    
    // Tank move for rotations
    public func move(forRotations rotations: Float, leftPort: OutputPort, rightPort: OutputPort, leftPower: Float, rightPower: Float, brakeAtEnd: Bool) {
        let isMissingAMotor = missingMotors(onPorts: [leftPort, rightPort])
        let onlyLargeMotors = assertOnlyLargeMotors(onPorts: [leftPort, rightPort])
        if isMissingAMotor || !onlyLargeMotors { return }
        
        move(forDegrees: rotations * 360.0, leftPort: leftPort, rightPort: rightPort, leftPower: leftPower, rightPower: rightPower, brakeAtEnd: brakeAtEnd)
    }
    
    private func calcTankPower(leftPower: Float, rightPower: Float) -> Int32 {
        return abs(leftPower) >= abs(rightPower) ? Int32(leftPower) : Int32(rightPower)
    }
    
    private func calcTankTurn(leftPower: Float, rightPower: Float, tankPower: Int32) -> Int32 {
        let powerDiff = leftPower - rightPower
        // Avoid division by 0
        if tankPower == 0 {
            return 0
        } else {
            return Int32(100.0 * powerDiff / Float(tankPower))
        }
    }
    
    // MARK: - Single Motor
    
    public func motorOff(on port: OutputPort, brakeAtEnd: Bool) {
        if missingMotors(onPorts: [port]) { return }
        
        let operation = Operation.opOutput_Stop(layer: 0, outputPorts: [port], brake: brakeAtEnd)
        run([operation])
    }
    
    public func motorOn(on port: OutputPort, withPower power: Float) {
        if missingMotors(onPorts: [port]) { return }
        
        let setPower = Operation.opOutput_Speed(layer: 0, outputPorts: [port], power: Int32(power))
        let startMotor = Operation.opOutput_Start(layer: 0, outputPorts: [port])
        
        run([setPower, startMotor])
    }
    
    public func motorOn(forSeconds seconds: Float, on port: OutputPort, withPower power: Float, brakeAtEnd: Bool) {
        if missingMotors(onPorts: [port]) { return }
        
        let operation = Operation.opOutput_Time_Speed(layer: 0, outputPorts: [port], power: Int32(power), rampUpDuration: 0, continueDuration: Int32(seconds * 1000), rampDownDuration: 0, brake: brakeAtEnd)
        run([operation], condition: BlockCondition.outputBusy(ports: [port]))
    }
    
    public func motorOn(forDegrees degrees: Float, on port: OutputPort, withPower power: Float, brakeAtEnd: Bool) {
        if missingMotors(onPorts: [port]) { return }
        
        let directedPower = degrees < 0 ? -power : power
        
        let operation = Operation.opOutput_Step_Speed(layer: 0, outputPorts: [port], power: Int32(directedPower), rampUpDuration: 0, continueDuration: Int32(abs(degrees)), rampDownDuration: 0, brake: brakeAtEnd)
        
        run([operation], condition: BlockCondition.outputBusy(ports: [port]))
    }
    
    public func motorOn(forRotations rotations: Float, on port: OutputPort, withPower power: Float, brakeAtEnd: Bool) {
        if missingMotors(onPorts: [port]) { return }
        
        motorOn(forDegrees: rotations * 360.0, on: port, withPower: power, brakeAtEnd: brakeAtEnd)
    }
    
    // MARK: - Play Sound
    
    public func playSound(file: SoundFile, atVolume volume: Float, withStyle style: SoundStyle) {
        let command: Operation
        switch style {
        case .playOnce:
            command = .opSound(command: .play(volume: Int32(volume), name: file.rawValue))
        case .playRepeat:
            command = .opSound(command: .repeat(volume: Int32(volume), name: file.rawValue))
        case .waitForCompletion:
            command = .opSound(command: .play(volume: Int32(volume), name: file.rawValue))
            run([command], condition: .soundNotBusy)
            return
        }
        run([command])
    }
    

    public func playSound(frequency: Float, forSeconds seconds: Float, atVolume volume: Float, waitForCompletion: Bool) {
        let soundCommand = SoundCommand.tone(volume: Int32(volume), frequency: Int32(frequency), duration: Int32(seconds * 1000))
        let operation = Operation.opSound(command: soundCommand)
        
        if waitForCompletion {
            run([operation], condition: BlockCondition.time(milliseconds: Int(seconds * 1000)))
        } else {
            run([operation])
        }
    }

    public func playSound(note: Note, forSeconds seconds: Float, atVolume volume: Float, waitForCompletion wait: Bool) {
        playSound(frequency: note.rawValue, forSeconds: seconds, atVolume: volume, waitForCompletion: wait)
    }
    
    public func stopSound() {
        run([Operation.opSound(command: .break)])
    }
}
