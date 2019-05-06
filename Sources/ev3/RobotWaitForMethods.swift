import Foundation


class WaitForDeltas {
    public static let ultraSonic: Float     = 3.0
    public static let gyro: Float           = 5.0
    public static let light: Float          = 5.0
    public static let infrared: Float       = 5.0
    public static let motorDegrees: Float   = 5.0
    public static let motorRotations: Float = 360.0 / motorDegrees
}

// WaitFor-methods
extension RobotFoundation {

    // MARK: - Wait for Ultrasonic
    
    public func waitForUltrasonicCentimeters(on port: InputPort, lessThanOrEqualTo centimeters: Float) {
        waitForUltrasonicCentimeters(on: port, relatedBy: .lessThanOrEqual, centimeters: centimeters)
    }
    
    public func waitForUltrasonicCentimeters(on port: InputPort, greaterThanOrEqualTo centimeters: Float) {
        waitForUltrasonicCentimeters(on: port, relatedBy: .greaterThanOrEqual, centimeters: centimeters)
    }
    
    public func waitForUltrasonicIncrease(on port: InputPort) {
        _ = readSensor(on: port, type: .ultrasonic, mode: .centimeters)
        run([], condition: BlockCondition.rateChange(delta: WaitForDeltas.ultraSonic, port: port))
    }
    
    public func waitForUltrasonicDecrease(on port: InputPort) {
        _ = readSensor(on: port, type: .ultrasonic, mode: .centimeters)
        run([], condition: BlockCondition.rateChange(delta: -WaitForDeltas.ultraSonic, port: port))
    }
    
    public func waitForUltrasonicChange(on port: InputPort) {
        _ = measureUltrasonicCentimeters(on: port) // set centimeter mode
        run([], condition: .anyChange(delta: WaitForDeltas.ultraSonic, port: port))
    }
    
    private func waitForUltrasonicCentimeters(on port: InputPort, relatedBy relation: Relation = .equal, centimeters: Float) {
        waitForReading(
            readAndSetMode: { measureUltrasonicCentimeters(on: $0) },
            on: port,
            relatedBy: relation,
            constant: centimeters)
    }
    
    public func waitForUltrasonicInches(on port: InputPort, lessThanOrEqualTo inches: Float) {
        waitForUltrasonicInches(on: port, relatedBy: .lessThanOrEqual, inches: inches)
    }
    
    public func waitForUltrasonicInches(on port: InputPort, greaterThanOrEqualTo inches: Float) {
        waitForUltrasonicInches(on: port, relatedBy: .greaterThanOrEqual, inches: inches)
    }
    
    private func waitForUltrasonicInches(on port: InputPort, relatedBy relation: Relation, inches: Float) {
        waitForReading(
            readAndSetMode: { measureUltrasonicInches(on: $0) },
            on: port,
            relatedBy: relation,
            constant: inches)
    }
    
    // MARK: - Wait for IR
    
    public func waitForIRProximity(on port: InputPort, lessThanOrEqualTo distance: Float) {
        waitForIRProximity(on: port, relatedBy: .lessThanOrEqual, distance: distance)
    }

    public func waitForIRProximity(on port: InputPort, greaterThanOrEqualTo distance: Float) {
        waitForIRProximity(on: port, relatedBy: .greaterThanOrEqual, distance: distance)
    }
    
    public func waitForIRProximityChange(on port: InputPort) {
        _ = measureIRProximity(on: port) // set proximity mode
        run([], condition: .anyChange(delta: WaitForDeltas.infrared, port: port))
    }
    
    private func waitForIRProximity(on port: InputPort, relatedBy relation: Relation = .equal, distance: Float) {
        waitForReading(
            readAndSetMode: { measureIRProximity(on: $0) },
            on: port,
            relatedBy: relation,
            constant: distance
        )
    }
    
    public func waitForIRSeek(on port: InputPort, lessThanOrEqualTo direction: Float) {
        waitForIRSeek(on: port, relatedBy: .lessThanOrEqual, direction: direction)
    }

    public func waitForIRSeek(on port: InputPort, greaterThanOrEqualTo direction: Float) {
        waitForIRSeek(on: port, relatedBy: .greaterThanOrEqual, direction: direction)
    }

    public func waitForIRSeekChange(on port: InputPort) {
        _ = measureIRSeek(on: port)
        run([], condition: .anyChange(delta: WaitForDeltas.infrared, port: port))
    }
    
    private func waitForIRSeek(on port: InputPort, relatedBy relation: Relation = .equal, direction: Float) {
        waitForReading(
            readAndSetMode: { measureIRSeek(on: $0) },
            on: port,
            relatedBy: relation,
            constant: direction
        )
    }
    
    // MARK: Wait for Gyro
    
    public func waitForGyroAngle(on port: InputPort, lessThanOrEqualTo angle: Float) {
        waitForGyroAngle(on: port, relatedBy: .lessThanOrEqual, angle: angle)
    }
    
    public func waitForGyroAngle(on port: InputPort, greaterThanOrEqualTo angle: Float) {
        waitForGyroAngle(on: port, relatedBy: .greaterThanOrEqual, angle: angle)
    }

    public func waitForGyroAngleChange(on port: InputPort) {
        _ = measureGyroAngle(on: port) // set angle mode
        run([], condition: .anyChange(delta: WaitForDeltas.gyro, port: port))
    }
    
    private func waitForGyroAngle(on port: InputPort, relatedBy relation: Relation, angle: Float) {
        waitForReading(
            readAndSetMode: { measureGyroAngle(on: $0) },
            on: port,
            relatedBy: relation,
            constant: angle
        )
    }
    
    public func waitForGyroRate(on port: InputPort, lessThanOrEqualTo rate: Float) {
        waitForGyroRate(on: port, relatedBy: .lessThanOrEqual, rate: rate)
    }
    
    public func waitForGyroRate(on port: InputPort, greaterThanOrEqualTo rate: Float) {
        waitForGyroRate(on: port, relatedBy: .greaterThanOrEqual, rate: rate)
    }
    
    public func waitForGyroRateChange(on port: InputPort) {
        _ = measureGyroRate(on: port) // set rate mode
        run([], condition: .anyChange(delta: WaitForDeltas.gyro, port: port))
    }
    
    public func waitForGyroRate(on port: InputPort, relatedBy relation: Relation, rate: Float) {
        waitForReading(
            readAndSetMode: { measureGyroRate(on: $0) },
            on: port,
            relatedBy: relation,
            constant: rate
        )
    }
    
    // MARK: Wait for Light
    public func waitForLightColor(on port: InputPort, color: ColorValue) {
        waitForReading(
            readAndSetMode: { measureLightColor(on: $0).rawValue },
            on: port,
            relatedBy: .equal,
            constant: color.rawValue
        )
    }
    
    public func waitForLightColorChange(on port: InputPort){
        let initial = measureLightColor(on: port)
        waitForReading(
            readAndSetMode: { measureLightColor(on: $0).rawValue },
            on: port,
            relatedBy: .notEqual,
            constant: initial.rawValue
        )
    }
    
    public func waitForLightReflection(on port: InputPort, lessThanOrEqualTo reflection: Float) {
        waitForLightReflection(on: port, relatedBy: .lessThanOrEqual, reflection: reflection)
    }
    
    public func waitForLightReflection(on port: InputPort, greaterThanOrEqualTo reflection: Float) {
        waitForLightReflection(on: port, relatedBy: .greaterThanOrEqual, reflection: reflection)
    }
    
    public func waitForLightReflectionChange(on port: InputPort) {
        _ = measureLightReflection(on: port)
        run([], condition: .anyChange(delta: WaitForDeltas.light, port: port))
    }
    
    private func waitForLightReflection(on port: InputPort, relatedBy relation: Relation, reflection: Float) {
        waitForReading(
            readAndSetMode: { measureLightReflection(on: $0) },
            on: port,
            relatedBy: relation,
            constant: reflection
        )
    }
    
    public func waitForLightAmbient(on port: InputPort, lessThanOrEqualTo ambience: Float) {
        waitForLightAmbient(onPort: port, relatedBy: .lessThanOrEqual, ambience: ambience)
    }
    
    public func waitForLightAmbient(on port: InputPort, greaterThanOrEqualTo ambience: Float) {
        waitForLightAmbient(onPort: port, relatedBy: .greaterThanOrEqual, ambience: ambience)
    }
    
    public func waitForLightAmbientChange(on port: InputPort) {
        _ = measureLightAmbient(on: port)
        run([], condition: .anyChange(delta: WaitForDeltas.light, port: port))
    }
    
    private func waitForLightAmbient(onPort port: InputPort, relatedBy relation: Relation, ambience: Float) {
        waitForReading(
            readAndSetMode: { measureLightAmbient(on: $0) },
            on: port,
            relatedBy: relation,
            constant: ambience
        )
    }
    
    // MARK: Wait for Touch
    
    public func waitForTouch(on port: InputPort) {
        waitForReading(
            readAndSetMode: { measureTouch(on: $0) ? 1 : 0 },
            on: port,
            relatedBy: .equal,
            constant: 1
        )
    }
    
    public func waitForTouchReleased(on port: InputPort) {
        waitForReading(
            readAndSetMode: { measureTouch(on: $0) ? 1 : 0 },
            on: port,
            relatedBy: .equal,
            constant: 0
        )
    }
    
    public func waitForTouchCount(on port: InputPort, greaterThanOrEqualTo count: Float) {
        waitForReading(
            readAndSetMode: { measureTouchCount(on: $0) },
            on: port,
            relatedBy: .greaterThanOrEqual,
            constant: count
        )
    }
    
    // MARK: Wait for Motor
    
    public func waitForMotorDegrees(on port: OutputPort, lessThanOrEqualTo degrees: Float) {
        waitForMotorDegrees(on: port, relatedBy: .lessThanOrEqual, degrees: degrees)
    }
    
    public func waitForMotorDegrees(on port: OutputPort, greaterThanOrEqualTo degrees: Float) {
        waitForMotorDegrees(on: port, relatedBy: .greaterThanOrEqual, degrees: degrees)
    }
    
    public func waitForMotorDegreesChange(on port: OutputPort) {
        _ = measureMotorDegrees(on: port)
        run([], condition: .anyChange(delta: WaitForDeltas.motorDegrees, port: port))
    }
    
    private func waitForMotorDegrees(on port: OutputPort, relatedBy: Relation, degrees: Float) {
        waitForReading(
            readAndSetMode: { measureMotorDegrees(on: $0) },
            on: port,
            relatedBy: relatedBy,
            constant: degrees)
    }
    
    public func waitForMotorRotations(on port: OutputPort, lessThanOrEqualTo rotations: Float) {
        waitForMotorRotations(onPort: port, relatedBy: .lessThanOrEqual, rotations: rotations)
    }
    
    public func waitForMotorRotations(on port: OutputPort, greaterThanOrEqualTo rotations: Float) {
        waitForMotorRotations(onPort: port, relatedBy: .greaterThanOrEqual, rotations: rotations)
    }
    
    public func waitForMotorRotationsChange(on port: OutputPort) {
        _ = measureMotorRotations(on: port) // set mode
        run([], condition: .anyChange(delta: WaitForDeltas.motorRotations, port: port))
    }
    
    
    private func waitForMotorRotations(onPort port: OutputPort, relatedBy: Relation, rotations: Float) {
        waitForReading(
            readAndSetMode: { measureMotorRotations(on: $0) },
            on: port,
            relatedBy: relatedBy,
            constant: rotations)
    }
    
    public func waitForMotorPower(on port: OutputPort, lessThanOrEqualTo power: Float) {
        waitForMotorPower(onPort: port, relatedBy: .lessThanOrEqual, power: power)
    }
    
    public func waitForMotorPower(on port: OutputPort, greaterThanOrEqualTo power: Float) {
        waitForMotorPower(onPort: port, relatedBy: .greaterThanOrEqual, power: power)
    }
    
    private func waitForMotorPower(onPort port: OutputPort, relatedBy: Relation, power: Float) {
        waitForReading(
            readAndSetMode: { measureMotorPower(on: $0)},
            on: port,
            relatedBy: relatedBy,
            constant: power)
    }
    
    // MARK: Wait for Time
    
    public func waitFor(seconds: Float) {
        run([], condition: BlockCondition.time(milliseconds: Int(seconds * 1000.0)))
    }
    
    private func waitForReading<T: Port>(
        readAndSetMode: (T) -> Float,
        on port: T,
        relatedBy relation: Relation = .equal,
        constant: Float)
    {
        var satisified = false
        let reading = readAndSetMode(port)
        switch relation {
        case .equal:
            satisified = constant == reading
        default:
            break
        }
        if !satisified {
            let condition = BlockCondition.absoluteValue(value: constant, relation: relation, port: port)
            run([], condition: condition)
        }
    }

}
