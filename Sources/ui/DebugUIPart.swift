import Foundation
import UIKit

protocol DebugUIPart {
    var name: String { get }
    var image: UIImage { get }
    var modeImage: UIImage { get }
    
    var mode: Int { get }
    var displayString: String { get }
    var value: Double { get }
    
    init(mode: Int, value: Double)
}

struct LargeMotor: DebugUIPart {
    var name: String = "Large Motor"
    var image: UIImage = #imageLiteral(resourceName: "PolyGroup_Motor_Diagram_2x")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_Motor_Mode_MeasureDegrees_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        return Int(value).description
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}

struct MediumMotor: DebugUIPart {
    var name: String = "Medium Motor"
    var image: UIImage =  #imageLiteral(resourceName: "PolyGroup_MediumMotor_Diagram_2x")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_Motor_Mode_MeasureDegrees_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        return Int(value).description
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}

struct LightSensor: DebugUIPart {
    var name: String = "Light Sensor"
    var image: UIImage = #imageLiteral(resourceName: "Sensor_Palette_LightSensor_128x128")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_ColorSensor_Mode_MeasureColor_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        return Int(value).description
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}

struct UltrasonicSensor: DebugUIPart {
    var name: String = "Ultrasonic Sensor"
    var image: UIImage = #imageLiteral(resourceName: "Sensor_Palette_Us_128x128")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_UltrasonicSensor_Mode_MeasureCentimeters_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        return Int(value).description
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}

struct GyroSensor: DebugUIPart {
    var name: String = "Gyro Sensor"
    var image: UIImage = #imageLiteral(resourceName: "Sensor_Palette_Gyro_128x128")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_Gyro_Mode_MeasureAngle_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        return Int(value).description
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}

struct IRSensor: DebugUIPart {
    var name: String = "IR Sensor"
    var image: UIImage = #imageLiteral(resourceName: "Sensor_Palette_Ir_128x128")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_InfraredSensor_Mode_MeasureProximity_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        return Int(value).description
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}

struct TouchSensor: DebugUIPart {
    var name: String = "Touch Sensor"
    var image: UIImage = #imageLiteral(resourceName: "Sensor_Palette_Touch_128x128")
    var modeImage: UIImage {
        switch mode {
        case 0:
            return #imageLiteral(resourceName: "PolyGroup_TouchSensor_Mode_Measure_Diagram_2x")
        default:
            return UIImage()
        }
    }
    
    var mode: Int = -1
    var displayString: String {
        if Int(value) == 1 {
            return "True"
        } else {
            return "False"
        }
    }
    var value: Double = 0.0
    
    init(mode: Int, value: Double) {
        self.mode = mode
        self.value = value
    }
}
