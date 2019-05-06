//
//  PortType.swift
//  PlaygroundContent
//

import UIKit

public enum PortType: Int32 {
    case largeMotor = 7
    case mediumMotor = 8
    case touch = 16
    case light = 29
    case ultrasonic = 30
    case gyro = 32
    case infrared = 33
    case missing = 126
}

extension PortType {
    var localizedName: String {
        switch self {
        case .largeMotor:
            return NSLocalizedString("Large Motor", comment: "The Port Type text for The Large Servo Motor")

        case .mediumMotor:
            return NSLocalizedString("Medium Motor", comment: "The Port Type text for The Medium Servo Motor")

        case .gyro:
            return NSLocalizedString("Gyroscope", comment: "The Port Type text for The Gyroscopic Sensor")

        case .infrared:
            return NSLocalizedString("Infrared", comment: "The Port Type short text for The Infrared Sensor")

        case .ultrasonic:
            return NSLocalizedString("Ultrasonic", comment: "The Port Type short text for the Ultrasonic Sensor")

        case .touch:
            return NSLocalizedString("Touch", comment: "The Port Type short text for the Touch Sensor")

        case .light:
            return NSLocalizedString("Light", comment: "The Port Type short text for the Light Sensor")

        case .missing:
            return NSLocalizedString("missing", comment: "The Port Type short text for an unknown input or output")
        }
    }

    var accessibleDescription: String {
        switch self {
        case .largeMotor:
            return NSLocalizedString("Large Motor", comment: "The Port Type text for The Large Servo Motor")

        case .mediumMotor:
            return NSLocalizedString("Medium Motor", comment: "The Port Type text for The Medium Servo Motor")

        case .gyro:
            return NSLocalizedString("Gyroscope", comment: "The Port Type text for The Gyroscopic Sensor")

        case .infrared:
            return NSLocalizedString("Infrared Sensor", comment: "The Port Type long text for the Infrared Sensor")

        case .ultrasonic:
            return NSLocalizedString("Ultrasonic Sensor", comment: "The Port Type long text for the Ultrasonic Sensor")

        case .touch:
            return NSLocalizedString("Touch Sensor", comment: "The Port Type long text for the Touch Sensor")

        case .light:
            return NSLocalizedString("Light Sensor", comment: "The Port Type long text for the Light Sensor")

        case .missing:
            return NSLocalizedString("Missing Sensor", comment: "The Port Type long text for the Missing Sensor")
        }
    }

    func image(for style: GridPlateStyle) -> UIImage {
        let imageSuffix = style == .large ? "_large" : "_small"
        let imageName: String

        switch self {
        case .gyro:
            imageName = "GyroSensor" + imageSuffix

        case .infrared:
            imageName = "InfraredSensor" + imageSuffix

        case .largeMotor:
            imageName = "LargeMotor" + imageSuffix

        case .light:
            imageName = "ColorSensor" + imageSuffix

        case .mediumMotor:
            imageName = "MediumMotor" + imageSuffix

        case .touch:
            imageName = "TouchSensor" + imageSuffix

        case .ultrasonic:
            imageName = "UltrasonicSensor" + imageSuffix

        case .missing:
            imageName = ""
        }

        return UIImage(named: imageName)!
    }


}
