import Foundation

// Robot display-methods
extension RobotFoundation {
    // MARK: - Display Methods
    
    
    public func display(text: String) {
        display(text: text, atX: 0, atY:0, withColor: .black, withFont: .normal, clearScreen: true)
    }
    
    public func display(text: String, atX: Int, atY: Int, withColor color: DisplayColor, withFont font: DisplayFont, clearScreen: Bool) {
        var operations = [Operation]()
        if clearScreen {
            operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
            operations.append(.opDraw(command: .clear))
        }
        let fontCommand = DrawCommand.selectFont(font: font)
        operations.append(Operation.opDraw(command: fontCommand))
        let drawCommand = DrawCommand.text(color: color, location: PixelLocation(x: atX, y: atY), string: text)
        operations.append(Operation.opDraw(command: drawCommand))
        operations.append(Operation.opDraw(command: DrawCommand.update))
        run(operations)
    }
    
    public func displayLine(fromX: Int, fromY: Int, toX: Int, toY: Int, withColor color: DisplayColor, clearScreen: Bool) {
        var operations = [Operation]()
        if clearScreen {
            operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
            operations.append(.opDraw(command: .clear))
        }
        let lineCommand = DrawCommand.line(color: .black, start: PixelLocation(x: fromX,y: fromY), stop: PixelLocation(x: toX,y: toY))
        operations.append(Operation.opDraw(command: lineCommand))
        operations.append(Operation.opDraw(command: DrawCommand.update))
        run(operations)
    }
    
    public func displayCircle(centerX: Int, centerY: Int, withRadius radius: Float, withFill fill: Bool, withColor color: DisplayColor, clearScreen: Bool) {
        var operations = [Operation]()
        if clearScreen {
            operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
            operations.append(.opDraw(command: .clear))
        }
        var circleCommand:DrawCommand
        if fill {
            circleCommand = .fillCircle(color: color, center: PixelLocation(x: centerX, y: centerY), radius: UInt16(radius))
        } else {
            circleCommand = .circle(color: color, center: PixelLocation(x: centerX, y: centerY), radius: UInt16(radius))
        }
        
        operations.append(Operation.opDraw(command: circleCommand))
        operations.append(Operation.opDraw(command: DrawCommand.update))
        run(operations)
    }
    
    public func displayRectangle(atX: Int, atY: Int, length: Int, height: Int, withFill fill: Bool, withColor color: DisplayColor, clearScreen: Bool) {
        var operations = [Operation]()
        if clearScreen {
            operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
            operations.append(.opDraw(command: .clear))
        }
        var rectCommand: DrawCommand
        if fill {
            rectCommand = .fillRect(color: color, location: PixelLocation(x: atX, y: atY), size: PixelSize(width: length, height: height))
        } else {
            rectCommand = .rect(color: color, location: PixelLocation(x: atX, y: atY), size: PixelSize(width: length, height: height))
        }
        operations.append(Operation.opDraw(command: rectCommand))
        operations.append(Operation.opDraw(command: DrawCommand.update))
        run(operations)
    }
    
    public func displayPoint(atX: Int, atY: Int, withColor color: DisplayColor, clearScreen: Bool) {
        var operations = [Operation]()
        if clearScreen {
            operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
            operations.append(.opDraw(command: .clear))
        }
        let pointCommand = DrawCommand.pixel(color: color, location: PixelLocation(x: atX,y: atY))
        operations.append(Operation.opDraw(command: pointCommand))
        operations.append(Operation.opDraw(command: DrawCommand.update))
        run(operations)
    }
    
    
    public func displayImage(named: ImageName) {
        displayImage(named: named, atX: 0, atY: 0, clearScreen: true)
    }
    
    public func displayImage(named: ImageName, atX: Int, atY: Int, clearScreen: Bool) {
        var operations = [Operation]()
        operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
        if clearScreen {
            operations.append(.opDraw(command: DrawCommand.enableTopLine(flag: false)))
            operations.append(.opDraw(command: .clear))
        }
        let drawImageCommand = DrawCommand.bmpFile(color: .black, location: PixelLocation(x: atX, y: atY), name: named.rawValue)
        operations.append(.opDraw(command: drawImageCommand))
        operations.append(.opDraw(command: .update))
        run(operations)
    }
    
    public func restoreDisplay() {
        let operations = [
            Operation.opDraw(command: .restoreScreen(level: Robot.defaultDisplayStorageLevel)),
            Operation.opDraw(command: .update)
        ]
        run(operations)
    }
    
    // MARK: Display methods not in RobotAPI
    
    public func hideTopBar() {
        let operations = [
            Operation.opDraw(command: DrawCommand.enableTopLine(flag: false)),
            Operation.opDraw(command: DrawCommand.update)
        ]
        run(operations)
    }
    
    public func showTopBar() {
        let operations = [
            Operation.opDraw(command: DrawCommand.enableTopLine(flag: true)),
            Operation.opDraw(command: DrawCommand.update)
        ]
        run(operations)
    }
    
    // Has to be sent in isolated message
    public func storeDisplay() {
        run([.opDraw(command: .storeScreen(level: Robot.defaultDisplayStorageLevel))])
    }
}
