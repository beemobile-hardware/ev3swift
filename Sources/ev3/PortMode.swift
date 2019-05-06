import Foundation

enum PortMode {
    case angle, rotations, power
    case rate
    case centimeters, inches
    case touch, bumps
    case reflect, ambient, color
    case proximity, seek, remote
}

extension PortMode {
    /// Custom initializer to instantiate a `PortMode` for a given `PortType`
    /// and mode value from a `PortData` instance.
    init?(portType: PortType, mode: Int) {
        switch (portType, mode) {
        case (.largeMotor, 0), (.mediumMotor, 0):
            self = .angle

        case (.largeMotor, 1), (.mediumMotor, 1):
            self = .rotations

        case (.largeMotor, 2), (.mediumMotor, 2):
            self = .power

        case (.gyro, 0):
            self = .angle

        case (.gyro, 1):
            self = .rate

        case (.ultrasonic, 0):
            self = .centimeters

        case (.ultrasonic, 1):
            self = .inches

        case (.touch, 0):
            self = .touch

        case (.touch, 1):
            self = .bumps

        case (.light, 0):
            self = .reflect

        case (.light, 1):
            self = .ambient

        case (.light, 2):
            self = .color

        case (.infrared, 0):
            self = .proximity

        case (.infrared, 1):
            self = .seek

        case (.infrared, 2):
            self = .remote

        default:
            return nil
        }
    }

    func EV3Value(for portType: PortType) -> Int32 {
        switch (portType, self) {
        case (.largeMotor, .angle), (.mediumMotor, .angle):
            return 0

        case (.largeMotor, .rotations), (.mediumMotor, .rotations):
            return 1

        case (.largeMotor, .power), (.mediumMotor, .power):
            return 2

        case (.gyro, .angle):
            return 0

        case (.gyro, .rate):
            return 1

        case (.ultrasonic, .centimeters):
            return 0

        case (.ultrasonic, .inches):
            return 1

        case (.touch, .touch):
            return 0

        case (.touch, .bumps):
            return 1

        case (.light, .reflect):
            return 0

        case (.light, .ambient):
            return 1

        case (.light, .color):
            return 2

        case (.infrared, .proximity):
            return 0

        case (.infrared, .seek):
            return 1

        case (.infrared, .remote):
            return 2

        default:
            return 0
        }

    }

    /// The localized name for the mode.
    var localizedName: String {
        switch self {
        case .angle:
            return NSLocalizedString("Degrees", comment: "The Port Mode display for a measurement of a plane angle, defined so that a full rotation is 360 degrees.")
        case .rotations:
            return NSLocalizedString("Rotations", comment: "The Port Mode display for a circular movement of an object around a center (or point) of rotation")
        case .power:
            return NSLocalizedString("Power", comment: "The Port Mode display for a unit of measurement for a mechanical engine's power output")
        case .rate:
            return NSLocalizedString("Rate", comment: "The Port Mode display for a specific kind of ratio, in which two measurements are related to each other (often with respect to time)")
        case .centimeters:
            return NSLocalizedString("cm", comment: "The Port Mode display for the unit of centimetres")
        case .inches:
            return NSLocalizedString("Inches", comment: "The Port Mode display for the unit of Inches")
        case .touch:
            return NSLocalizedString("Touched", comment: "The Port Mode display for whether the touch sensor is being actioned")
        case .bumps:
            return NSLocalizedString("Bumps", comment: "The Port Mode display for whether the touch sensor is quickly being pressed and released")
        case .reflect:
            return NSLocalizedString("Reflect", comment: "The Port Mode display for The colour sensor shines an LED and measures the amount of light reflected by nearby surfaces")
        case .ambient:
            return NSLocalizedString("Ambient", comment: "The Port Mode display for The colour sensor measures the amount of ambient light in its surroundings")
        case .color:
            return NSLocalizedString("Color", comment: "The Port Mode display for The colour sensor evaluates the color of an object")
        case .proximity:
            return NSLocalizedString("Proximity", comment: "The Port Mode display for The mode in which the Infrared Sensor detects proximity to an object and measures the distance to an object in front of the sensor")
        case .seek:
            return NSLocalizedString("Seek", comment: "The Port Mode display for The mode in which the Infrared Sensor can locate up to four beacons by seeking for them")
        case .remote:
            return NSLocalizedString("Remote", comment: "The Port Mode display for The mode in which the Infrared Sensor is paired with a remote and listens to the buttons pressed on the remote")
        }
    }

    /// Formats the value received in a `PortData` instance inta a string appropriate
    /// to the mode.
    func formattedValue(_ value: Float) -> String {
        switch self {
        case .color:
            if let colorValue = ColorValue(rawValue: value) {
                return colorValue.localizedName
            }
            else {
                return ColorValue.unavailable.localizedName
            }

        case .rotations:
            return String(format: "%.2f", value)

        case .centimeters, .inches:
            return String(format: "%.1f", value)

        default:
            return "\(Int(value))"
        }
    }

    /// Formats the value received in a `PortData` instance into a string appropriate
    /// to the mode.
    func accessibleValue(_ value: Float) -> String {
        // TODO: Localize when a stringsdict file has been setup
        switch self {
        case .angle:
            return "\(Int(value)) degrees"

        case .rotations:
            return String(format: "%.2f rotations", value)

        case .power:
            return "Power \(Int(value))"

        case .rate:
            return "Rate \(Int(value))"

        case .centimeters:
            return String(format: "%.1f centimeters", value)

        case .inches:
            return String(format: "%.1f inches", value)

        case .touch:
            if Int(value) == 0 {
                return "Not touched"
            }
            else {
                return "Touched"
            }

        case .bumps:
            return "\(Int(value)) bumps"

        case .reflect:
            return "Reflection value \(Int(value))"

        case .ambient:
            return "Ambient value \(Int(value))"

        case .color:
            let color = ColorValue(rawValue: value) ?? ColorValue.unavailable
            return "Color value \(color.accessibleDescription)"

        case .proximity:
            return "Proximity value \(Int(value))"

        case .seek:
            return "Seek value \(Int(value))"

        case .remote:
            return "Remote value \(Int(value))"
        }
    }

    /// Returns an array of `PortMode`s that are suitable for a given `PortType`.
    static func availableModes(for portType: PortType) -> [PortMode] {
        switch portType {
        case .largeMotor, .mediumMotor:
            return [.angle, .rotations, .power]

        case .gyro:
            return [.angle, .rate]

        case .ultrasonic:
            return [.centimeters, .inches]

        case .touch:
            return [.touch, .bumps]

        case .light:
            return [.reflect, .ambient, .color]

        case .infrared:
            return [.proximity, .seek, .remote]

        case .missing:
            return []
        }
    }
}
