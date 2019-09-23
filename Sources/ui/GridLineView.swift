import UIKit

class GridLineView: UIView {
    private(set) var line: GridLine!
    private var studDimensions = StudDimensions.invalid
    private var offset = CGSize.zero
    
    init(frame: CGRect, line: GridLine, studDimensions: StudDimensions, offset: CGSize) {
        self.line = line
        self.studDimensions = studDimensions
        self.offset = offset
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let line = line, let lastPoint = line.path.last, let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(line.connection.color.cgColor)
        
        for point in line.path {
            drawStud(at: point, with: context)
        }
        
        context.setFillColor(UIColor.white.cgColor)
        drawStud(at: lastPoint, with: context)
    }
    
    private func drawStud(at point: BrickPoint, with context: CGContext) {
        let frame = CGRect(x: (CGFloat(point.x) * studDimensions.totalSize) + offset.width,
                           y: (CGFloat(point.y) * studDimensions.totalSize) + offset.height,
                           width: studDimensions.totalSize, height: studDimensions.totalSize)
        
        context.fillEllipse(in: frame.insetBy(dx: studDimensions.inset, dy: studDimensions.inset))
    }
}
