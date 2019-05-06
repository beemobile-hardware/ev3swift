import UIKit

// MARK: Basic geometry type definitions.

/// Defines a brick coordinate.
struct BrickPoint {
    var x, y: Int
    
    static let zero = BrickPoint(x: 0, y: 0)
}

/// Defines a brick size.
struct BrickSize {
    var width, height: Int
    
    var aspectRatio: Double {
        return Double(width) / Double(height)
    }
    
    var isPortrait: Bool {
        return height > width
    }
    
    var isLandscape: Bool {
        return width > height
    }
    
    static let zero = BrickSize(width: 0, height: 0)
}

/// Defines a brick rectangle.
struct BrickRect {
    var origin: BrickPoint
    var size: BrickSize
    
    static let zero = BrickRect(origin: .zero, size: .zero)
}

/// Defines the total size of a stuf and the insets to draw the disc.
struct StudDimensions {
    var totalSize: CGFloat
    var inset: CGFloat
    
    static let invalid = StudDimensions(totalSize: 0, inset: 0)
}

extension StudDimensions: Equatable {
    public static func ==(lhs: StudDimensions, rhs: StudDimensions) -> Bool {
        return lhs.totalSize.isEqual(to: rhs.totalSize) && lhs.inset.isEqual(to: rhs.totalSize)
    }
}

// MARK: `BrickPoint` extensions.

/// Extends `BrickPoint` to add `CGPoint` conversion methods.
extension BrickPoint {
    init(_ point: CGPoint, with studDimensions: StudDimensions) {
        x = Int(floor(point.x / studDimensions.totalSize))
        y = Int(floor(point.y / studDimensions.totalSize))
    }

    func cgPoint(with studDimensions: StudDimensions) -> CGPoint {
        return CGPoint(x: CGFloat(x) * studDimensions.totalSize, y: CGFloat(y) * studDimensions.totalSize )
    }
}

/// Extends `BrickPoint` to add convenience methods.
extension BrickPoint {
    /// Returns a flipped version of the point.
    func flipped() -> BrickPoint {
        return BrickPoint(x: y, y: x)
    }
}

extension BrickPoint: Equatable {
    public static func ==(lhs: BrickPoint, rhs: BrickPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// MARK: `BrickSize` extensions.

/// Extends `BrickSize` to add `CGSize` conversion methods.
extension BrickSize {
    init(_ size: CGSize, with studDimensions: StudDimensions) {
        width = Int(floor(size.width / studDimensions.totalSize))
        height = Int(floor(size.height / studDimensions.totalSize))
    }
    
    func cgSize(with studDimensions: StudDimensions) -> CGSize {
        return CGSize(width: CGFloat(width) * studDimensions.totalSize, height: CGFloat(height) * studDimensions.totalSize)
    }
}

/// Extends `BrickSize` to add convenience methods.
extension BrickSize {
    /// Returns a flipped version of the size.
    func flipped() -> BrickSize {
        return BrickSize(width: height, height: width)
    }
}

extension BrickSize: Equatable {
    public static func ==(lhs: BrickSize, rhs: BrickSize) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
}

// MARK: `BrickRect` extensions.

/// Extends `BrickRect` to add `CGSize` conversion methods.
extension BrickRect {
    func cgRect(with studDimensions: StudDimensions) -> CGRect {
        return CGRect(origin: origin.cgPoint(with: studDimensions), size: size.cgSize(with: studDimensions))
    }
}

/// Extends `BrickRect` to add convenience methods.
extension BrickRect {
    init(x: Int, y: Int, width: Int, height: Int) {
        origin = BrickPoint(x: x, y: y)
        size = BrickSize(width: width, height: height)
    }
    
    func flipped() -> BrickRect {
        var newRect = self
        newRect.origin = newRect.origin.flipped()
        newRect.size = newRect.size.flipped()
        
        return newRect
    }

    func contains(_ point: BrickPoint) -> Bool {
        return point.x >= origin.x && point.y >= origin.y && point.x < origin.x + size.width && point.y < origin.y + size.height
    }
    
    func insetBy(dx: Int, dy: Int) -> BrickRect {
        var insetRect = self
        insetRect.origin.x += dx
        insetRect.origin.y += dy
        insetRect.size.width -= dx * 2
        insetRect.size.height -= dx * 2
        
        return insetRect
    }
}

extension BrickRect: Equatable {
    public static func ==(lhs: BrickRect, rhs: BrickRect) -> Bool {
        return lhs.size == rhs.size && lhs.origin == rhs.origin
    }
}

extension Int {
    var isEven: Bool {
        return (self % 2 == 0)
    }
}
