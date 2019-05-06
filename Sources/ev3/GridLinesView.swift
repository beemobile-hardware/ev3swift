import UIKit

@objc(GridLinesView)
class GridLinesView: UIView {
    private var studDimensions = StudDimensions.invalid
    private var offset = CGSize.zero
    private var lineViews: [PlateConnection: GridLineView] = [:]
    
    func configure(with lines: [GridLine], studDimensions: StudDimensions, offset: CGSize) {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        var viewsToAdd: [GridLineView] = []
        var viewsToRemove = lineViews
        
        for line in lines {
            let lineRequiresNewView: Bool
            
            if let existingLineView = lineViews[line.connection] {
                if line == existingLineView.line {
                    viewsToRemove[line.connection] = nil
                    lineRequiresNewView = false
                }
                else {
                    lineRequiresNewView = true
                }
            }
            else {
                lineRequiresNewView = true
            }
            
            if lineRequiresNewView {
                let childFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
                viewsToAdd.append(GridLineView(frame: childFrame, line: line, studDimensions: studDimensions, offset: offset))
            }
        }
        
        for view in viewsToRemove.values {
            lineViews[view.line.connection] = nil
            view.removeFromSuperview()
        }
        
        for view in viewsToAdd {
            view.alpha = 0.0
            lineViews[view.line.connection] = view
            addSubview(view)
        }
        
        assert(subviews.count == lines.count, "Expected the same number of lines as GridLineViews.")
        
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            for view in viewsToAdd {
                view.alpha = 1.0
            }
        }, completion: nil)
    }
}
