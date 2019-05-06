//
//  ColorValue.swift
//  PlaygroundContent
//

import Foundation

/**
 Enum of color values. Valid values are:
    - `.unavailable`
    - `.black`
    - `.blue`
    - `.green`
    - `.yellow`
    - `.red`
    - `.white`
    - `.brown`
 */
public enum ColorValue: Float {
    case unavailable = 0
    case black = 1
    case blue = 2
    case green = 3
    case yellow = 4
    case red = 5
    case white = 6
    case brown = 7

    public var accessibleDescription: String {
        return self.localizedName
    }
}

extension ColorValue {
    var localizedName: String {
        switch self {
        case .black:
            return NSLocalizedString("Black", comment: "The Color Black")
        case .blue:
            return NSLocalizedString("Blue", comment: "The Color Blue")
        case .green:
            return NSLocalizedString("Green", comment: "The Color Green")
        case .yellow:
            return NSLocalizedString("Yellow", comment: "The Color Yellow")
        case .red:
            return NSLocalizedString("Red", comment: "The Color Red")
        case .white:
            return NSLocalizedString("White", comment: "The Color White")
        case .brown:
            return NSLocalizedString("Brown", comment: "The Color Brown")
        case .unavailable:
            return NSLocalizedString("None", comment: "The Color Description when the Color Sensor cannot find a color")
        }
    }
}
