//
//  PixelSize.swift
//  PlaygroundContent
//

public struct PixelSize {
    public var width: UInt16 // clipped to 0 to 177
    public var height: UInt16 // clipped to 0 to 127
    
    public init(width: Int, height: Int) {
        // clip to 0 to 177
        self.width = UInt16(width.clamped(to: 0 ... 177))
        // clip to 0 to 127
        self.height = UInt16(height.clamped(to: 0 ... 127))
    }
}
