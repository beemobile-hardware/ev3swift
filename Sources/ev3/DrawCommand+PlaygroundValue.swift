//
//  DrawCommand+PlaygroundValue.swift
//  PlaygroundContent
//
//

import Foundation
import PlaygroundSupport

extension DrawCommand {
    
    private enum DrawCommandType: String {
        case update
        case clear
        case pixel
        case line
        case circle
        case text
        case icon
        case fillRect
        case rect
        case verticalBar
        case inverseRect
        case selectFont
        case enableTopLine
        case fillWindow
        case fillCircle
        case storeScreen
        case restoreScreen
        case bmpFile
    }
    
    private var type: DrawCommandType {
        switch self {
        case .update:
            return .update
        case .clear:
            return .clear
        case .pixel(_, _):
            return .pixel
        case .line(_, _, _):
            return .line
        case .circle(_, _, _):
            return .circle
        case .text(_, _, _):
            return .text
        case .icon(_, _, _, _):
            return .icon
        case .fillRect(_, _, _):
            return .fillRect
        case .rect(_, _, _):
            return .rect
        case .verticalBar(_, _, _, _, _, _):
            return .verticalBar
        case .inverseRect(_, _):
            return .inverseRect
        case .selectFont(_):
            return .selectFont
        case .enableTopLine(_):
            return .enableTopLine
        case .fillWindow(_, _, _):
            return .fillWindow
        case .fillCircle(_, _, _):
            return .fillCircle
        case .storeScreen(_):
            return .storeScreen
        case .restoreScreen(_):
            return .restoreScreen
        case .bmpFile(_, _, _):
            return .bmpFile
        }
    }
    
    var playgroundValue: PlaygroundValue {
        return .dictionary([type.rawValue: .array(parameters.map { $0.playgroundValue } )])
    }
    
    public init?(playgroundValue: PlaygroundValue) {
        log(message: "got \(playgroundValue) trying to make a DrawCommand")
        guard case let .dictionary(dictionary) = playgroundValue else {
            log(message: "dictionary nil")
            return nil
        }

        guard let firstEntry = dictionary.first, let key = DrawCommandType(rawValue: firstEntry.key) else {
            log(message: "firstEntry nil")
            return nil
        }

        guard case let .array(array) = firstEntry.value else {
            log(message: "array nil")
            return nil
        }

        let bytecodeEncodables = array.flatMap({ BytecodeEncodable(playgroundValue: $0) })

        guard bytecodeEncodables.count == array.count else {
            log(message: "One or more values in \(playgroundValue) was not BytecodeEncodable")
            return nil
        }

        switch key {
        case .update where bytecodeEncodables.count == 1:
            self = .update
        case .clear where bytecodeEncodables.count == 1:
            self = .clear
        case .pixel:
            guard bytecodeEncodables.count == 4, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32 else {
                log(message: "pixel nil")
                return nil
            }
            self = .pixel(color: color, location: PixelLocation(x: Int(x), y: Int(y)))
        case .line:
            guard bytecodeEncodables.count == 6, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x1 = bytecodeEncodables[2].rawValue as? Int32, let y1 = bytecodeEncodables[3].rawValue as? Int32, let x2 = bytecodeEncodables[4].rawValue as? Int32, let y2 = bytecodeEncodables[5].rawValue as? Int32 else {
                log(message: "line nil")
                return nil
            }
            self = .line(color: color, start: PixelLocation(x: Int(x1), y: Int(y1)), stop: PixelLocation(x: Int(x2), y: Int(y2)))
        case .circle:
            guard bytecodeEncodables.count == 5, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let radius = bytecodeEncodables[4].rawValue as? Int32 else {
                log(message: "circle nil")
                return nil
            }
            self = .circle(color: color, center: PixelLocation(x: Int(x), y: Int(y)), radius: UInt16(radius))
        case .text:
            guard bytecodeEncodables.count == 5, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let string = bytecodeEncodables[4].rawValue as? String else {
                log(message: "text nil")
                return nil
            }
            self = .text(color: color, location: PixelLocation(x: Int(x), y: Int(y)), string: string)
        case .icon:
            guard bytecodeEncodables.count == 6, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let iconTypeValue = bytecodeEncodables[4].rawValue as? Int32, let iconType = IconType(rawValue: UInt8(iconTypeValue)), let iconValue = bytecodeEncodables[5].rawValue as? Int32, let icon = Icon(rawValue: UInt8(iconValue)) else {
                log(message: "text nil")
                return nil
            }
            self = .icon(color: color, location: PixelLocation(x: Int(x), y: Int(y)), type: iconType, number: icon)
        case .fillRect:
            guard bytecodeEncodables.count == 6, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let width = bytecodeEncodables[4].rawValue as? Int32, let height = bytecodeEncodables[5].rawValue as? Int32 else {
                log(message: "fillRect nil")
                return nil
            }
            self = .fillRect(color: color, location: PixelLocation(x: Int(x), y: Int(y)), size: PixelSize(width: Int(width), height: Int(height)))
        case .rect:
            guard bytecodeEncodables.count == 6, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let width = bytecodeEncodables[4].rawValue as? Int32, let height = bytecodeEncodables[5].rawValue as? Int32 else {
                log(message: "rect nil")
                return nil
            }
            self = .rect(color: color, location: PixelLocation(x: Int(x), y: Int(y)), size: PixelSize(width: Int(width), height: Int(height)))
        case .verticalBar:
            guard bytecodeEncodables.count == 9, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x1 = bytecodeEncodables[2].rawValue as? Int32, let y1 = bytecodeEncodables[3].rawValue as? Int32, let x2 = bytecodeEncodables[4].rawValue as? Int32, let y2 = bytecodeEncodables[5].rawValue as? Int32, let minValue = bytecodeEncodables[6].rawValue as? Int32, let maxValue = bytecodeEncodables[7].rawValue as? Int32, let value = bytecodeEncodables[8].rawValue as? Int32 else {
                log(message: "verticalBar nil")
                return nil
            }
            self = .verticalBar(color: color, start: PixelLocation(x: Int(x1), y: Int(y1)), stop: PixelLocation(x: Int(x2), y: Int(y2)), minValue: UInt16(minValue), maxValue: UInt16(maxValue), value: UInt16(value))
        case .inverseRect:
            guard bytecodeEncodables.count == 5, let x = bytecodeEncodables[1].rawValue as? Int32, let y = bytecodeEncodables[2].rawValue as? Int32, let width = bytecodeEncodables[3].rawValue as? Int32, let height = bytecodeEncodables[4].rawValue as? Int32 else {
                log(message: "inverseRect nil")
                return nil
            }
            self = .inverseRect(location: PixelLocation(x: Int(x), y: Int(y)), size: PixelSize(width: Int(width), height: Int(height)))
        case .selectFont:
            guard bytecodeEncodables.count == 2, let fontValue = bytecodeEncodables[1].rawValue as? Int32, let font = DisplayFont(rawValue: UInt8(fontValue)) else {
                log(message: "unable to make font change command \(bytecodeEncodables[1].rawValue as? Int32)")
                return nil
            }
            self = .selectFont(font: font)
        case .enableTopLine:
            guard bytecodeEncodables.count == 2, let flag = bytecodeEncodables[1].rawValue as? Bool else {
                log(message: "unable to make enable top line command \(bytecodeEncodables[1].rawValue as? Bool)")
                return nil
            }
            self = .enableTopLine(flag: flag)
        case .fillWindow:
            guard bytecodeEncodables.count == 4, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let y = bytecodeEncodables[2].rawValue as? Int32, let height = bytecodeEncodables[3].rawValue as? Int32 else {
                log(message: "fillWindow nil")
                return nil
            }
            self = .fillWindow(color: color, y: UInt16(y), height: UInt16(height))
        case .fillCircle:
            guard bytecodeEncodables.count == 5, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let radius = bytecodeEncodables[4].rawValue as? Int32 else {
                log(message: "fillCircle nil")
                return nil
            }
            self = .fillCircle(color: color, center: PixelLocation(x: Int(x), y: Int(y)), radius: UInt16(radius))
        case .storeScreen:
            guard bytecodeEncodables.count == 2, let level = bytecodeEncodables[1].rawValue as? Int32 else {
                log(message: "storeScreen nil")
                return nil
            }
            self = .storeScreen(level: UInt8(level))
        case .restoreScreen:
            guard bytecodeEncodables.count == 2, let level = bytecodeEncodables[1].rawValue as? Int32 else {
                log(message: "restoreScreen nil")
                return nil
            }
            self = .restoreScreen(level: UInt8(level))
        case .bmpFile:
            guard bytecodeEncodables.count == 5, let colorValue = bytecodeEncodables[1].rawValue as? Int32, let color = DisplayColor(rawValue: UInt8(colorValue)), let x = bytecodeEncodables[2].rawValue as? Int32, let y = bytecodeEncodables[3].rawValue as? Int32, let name = bytecodeEncodables[4].rawValue as? String else {
                log(message: "bmpFile nil")
                return nil
            }
            self = .bmpFile(color: color, location: PixelLocation(x: Int(x), y: Int(y)), name: name)
        default:
            log(message: "String as key for DrawCommandType is unknown")
            return nil
        }
    }
}
