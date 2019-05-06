//
//  PixelLocation.swift
//  PlaygroundContent
//

public struct PixelLocation {
    public var x: UInt16 // clipped to 0 to 177
    public var y: UInt16 // clipped to 0 to 127
    
    public init(x: Int, y: Int) {
        // clip to 0 to 177
        self.x = UInt16(x.clamped(to: 0 ... 177))
        // clip to 0 to 127
        self.y = UInt16(y.clamped(to: 0 ... 127))
    }
}
