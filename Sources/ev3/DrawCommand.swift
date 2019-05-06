//
//  DrawCommand.swift
//  PlaygroundContent
//
//

import Foundation

public enum DrawCommand: ParameterCommand {
    // CMD: UPDATE = 0x00
    case update
    // CMD: UPDATE = 0x01
    case clear
    // CMD: PIXEL = 0x02
    case pixel(color: DisplayColor, location: PixelLocation) // paint color at the pixel at location
    // CMD: LINE = 0x03
    case line(color: DisplayColor, start: PixelLocation, stop: PixelLocation) // draw color from start to stop
    // CMD: CIRCLE = 0x04
    case circle(color: DisplayColor, center: PixelLocation, radius: UInt16)
    // CMD: TEXT = 0x05
    case text(color: DisplayColor, location: PixelLocation, string: String)
    // CMD: ICON = 0x06
    case icon(color: DisplayColor, location: PixelLocation, type: IconType, number: Icon)
    // CMD: FILLRECT = 0x09
    case fillRect(color: DisplayColor, location: PixelLocation, size: PixelSize)
    // CMD: RECT = 0x0A
    case rect(color: DisplayColor, location: PixelLocation, size: PixelSize)

    // CMD: VERTBAR = 0x0F
    case verticalBar(color: DisplayColor, start: PixelLocation, stop: PixelLocation, minValue: UInt16, maxValue: UInt16, value: UInt16)
    // CMD: INVERSERECT = 0x10
    case inverseRect(location: PixelLocation, size: PixelSize)
    // CMD: SELECT_FRONT = 0x11
    // mispelled in the docs as FRONT instead of FONT
    case selectFont(font: DisplayFont)
    
    // CMD: TOPLINE = 0x12
    case enableTopLine(flag: Bool)
    // CMD: FILLWINDOW = 0x13
    // y and height must be clipped to 127
    case fillWindow(color: DisplayColor, y: UInt16, height: UInt16)
    // CMD: FILLCIRCLE = 0x18
    case fillCircle(color: DisplayColor, center: PixelLocation, radius: UInt16)
    // CMD: STORE = 0x19
    // store a screenshot into level, docs unclear if there are truly 255 levels to store in
    case storeScreen(level: UInt8)
    // CMD: RESTORE = 0x1A
    case restoreScreen(level: UInt8) // '0 is the last screen shot stored' I infer from that description that level is in a fifo queue but the store description says nothing to imply that so that must not be what's happening.
    // CMD: BMPFILE = 0x1C Arguments
    case bmpFile(color: DisplayColor, location: PixelLocation, name: String)

    var parameters: [BytecodeEncodable] {
        var messageParameters: [BytecodeEncodable]
        switch self {
        case .update:
            messageParameters = [.byte(0x00)]
        case .clear:
            messageParameters = [.byte(0x01)]
        case .pixel(let color, let location):
            messageParameters = [.byte(0x02), .int(Int32(color.rawValue)), .int(Int32(location.x)), .int(Int32(location.y))]
        case .line(let color, let start, let stop):
            messageParameters = [.byte(0x03), .int(Int32(color.rawValue)), .int(Int32(start.x)), .int(Int32(start.y)), .int(Int32(stop.x)), .int(Int32(stop.y))]
        case .circle(let color, let center, let radius):
            messageParameters = [.byte(0x04), .int(Int32(color.rawValue)), .int(Int32(center.x)), .int(Int32(center.y)), .int(Int32(radius))]
        case .text(let color, let location, let string):
            messageParameters = [.byte(0x05), .int(Int32(color.rawValue)), .int(Int32(location.x)), .int(Int32(location.y)), .string(string)]
        case .icon(let color, let location, let type, let number):
            messageParameters = [.byte(0x06), .int(Int32(color.rawValue)), .int(Int32(location.x)), .int(Int32(location.y)), .int(Int32(type.rawValue)), .int(Int32(number.rawValue))]
        case .fillRect(let color, let location, let size):
            messageParameters = [.byte(0x09), .int(Int32(color.rawValue)), .int(Int32(location.x)), .int(Int32(location.y)), .int(Int32(size.width)), .int(Int32(size.height))]
        case .rect(let color, let location, let size):
            messageParameters = [.byte(0x0A), .int(Int32(color.rawValue)), .int(Int32(location.x)), .int(Int32(location.y)), .int(Int32(size.width)), .int(Int32(size.height))]
        case .verticalBar(let color, let start, let stop, let minValue, let maxValue, let value):
            messageParameters = [.byte(0x0F), .int(Int32(color.rawValue)), .int(Int32(start.x)), .int(Int32(start.y)), .int(Int32(stop.x)), .int(Int32(stop.y)), .int(Int32(minValue)), .int(Int32(maxValue)), .int(Int32(value))]
        case .inverseRect(let location, let size):
            messageParameters = [.byte(0x10), .int(Int32(location.x)), .int(Int32(location.y)), .int(Int32(size.width)), .int(Int32(size.height))]
        case .selectFont(let font):
            messageParameters = [.byte(0x11), .int(Int32(font.rawValue))]
        case .enableTopLine(let flag):
            messageParameters = [.byte(0x12), .bool(flag)]
        case .fillWindow(let color, let y, let height):
            messageParameters = [.byte(0x13), .int(Int32(color.rawValue)), .int(Int32(y)), .int(Int32(height))]
        case .fillCircle(let color, let center, let radius):
            messageParameters = [.byte(0x18), .int(Int32(color.rawValue)), .int(Int32(center.x)), .int(Int32(center.y)), .int(Int32(radius))]
        case .storeScreen(let level):
            messageParameters = [.byte(0x19), .int(Int32(level))]
        case .restoreScreen(let level):
            messageParameters = [.byte(0x1A), .int(Int32(level))]
        case .bmpFile(let color, let location, let name):
            messageParameters = [.byte(0x1C), .int(Int32(color.rawValue)), .int(Int32(location.x)), .int(Int32(location.y)), .string(name)]
        }
        return messageParameters
    }
    
    var encoded: Data {
        var data = Data()
        parameters.forEach({ data.append($0.encoded) })
        return data
    }
}

