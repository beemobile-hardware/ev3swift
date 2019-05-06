import UIKit

@objc(PortDataGraph)
class PortDataGraph: UIView {
    let pointsPerSecond: CGFloat = 10.0
    let maximumTime: TimeInterval = 60 * 60
    let contentInset = UIEdgeInsets(top: 14.0, left: 40, bottom: 14.0, right: 40.0)
    
    let markerSize: CGFloat = 4
    let markerStep: TimeInterval = 5
    var markerFont: UIFont?
    
    private(set) var connectionData: ConnectionData?
    
    private var scale: Float? {
        didSet {
            // If the scale has changed from what was previously used to draw the
            // graph, mark the whole view as needing to be redrawn.
            guard let oldScale = oldValue, let newScale = scale else { return }
            if !newScale.isEqual(to: oldScale) {
                setNeedsDisplay()
            }
        }
    }
    
    override class var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: (CGFloat(maximumTime) * pointsPerSecond) + contentInset.left + contentInset.right, height: bounds.size.height)
    }
    
    var plotWidth: CGFloat {
        guard let connectionData = connectionData, let last = connectionData.last else { return 0.0 }
        return (CGFloat(last.time) * pointsPerSecond)
    }
    
    func reset() {
        self.connectionData = nil
        setNeedsDisplay()
    }
    
    func update(with connectionData: ConnectionData) {
        let lastPlotWidth = plotWidth
        self.connectionData = connectionData

        // Calculate the vertical scale factor to use when plotting values.
        let maxDeltaFromMidY = max(abs(connectionData.maxValue), abs(connectionData.minValue))
        let availableHeight = Float((bounds.size.height / 2.0) - contentInset.top - contentInset.bottom)
        scale = maxDeltaFromMidY.isEqual(to: 0.0) || availableHeight.isEqual(to: 0.0) ? 1.0 : maxDeltaFromMidY / availableHeight

        // Mark area convered by new values as needing to be drawn.
        if plotWidth > lastPlotWidth {
            let invalidRect = CGRect(x: contentInset.left + lastPlotWidth,
                                     y: 0,
                                     width: contentInset.left + plotWidth,
                                     height: bounds.size.height)
            
            setNeedsDisplay(invalidRect.insetBy(dx: -max(contentInset.left, contentInset.right), dy: 0))
        }
    }

    override func draw(_ rect: CGRect) {
        // If there aren't 2 points to plot a line between, a context, a font or a scale. clear the whole view.
        guard
            let context = UIGraphicsGetCurrentContext(),
            let font = markerFont,
            let scale = scale,
            let connectionData = connectionData, connectionData.count > 1
        else {
            guard let backgroundColor = backgroundColor else { return }
            backgroundColor.setFill()
            UIRectFill(CGRect(origin: .zero, size: bounds.size))
            return
        }
        
        context.setStrokeColor(UIColor.legoGraphPlot.cgColor)
        context.setFillColor(UIColor.legoGraphPlot.cgColor)
        
        let fromX = max(rect.origin.x - contentInset.left, 0)
        let toX = max(min(rect.origin.x + rect.size.width, plotWidth), 0)
        
        let fromTime = TimeInterval(fromX / pointsPerSecond)
        let toTime = TimeInterval(toX / pointsPerSecond)
        
        let minIndex = max(connectionData.index(for: fromTime) - 1, 0)
        let maxIndex = min(connectionData.index(for: toTime) + 1, connectionData.count - 1)
        guard maxIndex > minIndex else { return }
        
        // Create a local function to get the scaled position of a value for a given index.
        func point(for index: Int) -> CGPoint {
            let x = CGFloat(connectionData[index].time) * pointsPerSecond
            let y = CGFloat(connectionData[index].value / -scale)
            return CGPoint(x: x, y: y)
        }
        
        // Translate the context to center the y axis and offset the x by the content inset.
        context.saveGState()
        context.translateBy(x: contentInset.left, y: (bounds.size.height / 2.0))
        
        // Plot lines between the visible values.
        context.move(to: point(for: minIndex))
        for index in (minIndex + 1)...maxIndex {
            context.addLine(to: point(for: index))
        }
        context.strokePath()
        
        // Plot time markers that fall within the time range.
        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: UIColor.legoGraphPlot
        ]
        var time = max(0, floor(fromTime / markerStep) * markerStep)
        
        while time < toTime {
            let x = CGFloat(time) * pointsPerSecond
            let y = CGFloat(connectionData.value(for: time) / -scale)
            
            let markerRect = CGRect(x: x - (markerSize / 2.0), y: y - (markerSize / 2.0), width: markerSize, height: markerSize)
            context.fillEllipse(in: markerRect)

            let text = NSString(format: "%.0f", time)
            let textSize = text.size(withAttributes: textAttributes)
            text.draw(at: CGPoint(x: x - floor(textSize.width / 2.0), y: 2), withAttributes: textAttributes)

            time += markerStep
        }
        
        context.restoreGState()
    }
}
