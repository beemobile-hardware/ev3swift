import UIKit

@objc(PlateTableViewCellGraphLinesView)
class PlateTableViewCellGraphLinesView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.legoGraphAxis.cgColor)
        context.setLineDash(phase: 2.0, lengths: [2.0])

        context.move(to: CGPoint(x: 0, y: bounds.size.height / 2.0))
        context.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height / 2.0))
        context.move(to: CGPoint(x: bounds.size.width, y: 0))
        context.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        context.strokePath()
    }
}
