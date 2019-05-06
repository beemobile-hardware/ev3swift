import Foundation
import UIKit

protocol DebugUIPortDelegate {
    func partUpdated()
    func partRemoved()
    func partAdded()
}

class DebugUIPort {
    
    private(set) var part: DebugUIPart? {
        didSet {
            if oldValue == nil && part != nil {
                delegate?.partAdded()
            } else if let _ = part {
                delegate?.partUpdated()
            } else {
                delegate?.partRemoved()
            }
        }
    }
    
    var delegate: DebugUIPortDelegate?
    
    init() { }
    
    func setPart(data: PortData?) {
        guard let data = data else {
            removePart()
            return
        }
        part = PartMapper.part(type: data.type, mode: data.mode, value: Double(data.value))
    }
    
    func removePart() {
        part = nil
    }
}

fileprivate class PartMapper {
    class func part(type: Int, mode: Int, value: Double) -> DebugUIPart? {
        switch type {
        case 7:
            return LargeMotor(mode: mode, value: value)
        case 8:
            return MediumMotor(mode: mode, value: value)
        case 29:
            return LightSensor(mode: mode, value: value)
        case 30:
            return UltrasonicSensor(mode: mode, value: value)
        case 32:
            return GyroSensor(mode: mode, value: value)
        case 33:
            return IRSensor(mode: mode, value: value)
        case 16:
            return TouchSensor(mode: mode, value: value)
        default:
            return nil
        }
    }
}
