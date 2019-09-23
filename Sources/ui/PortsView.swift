import UIKit

@objc(PortsView)
class PortsView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: PortsView.self)
    static let nibName = String(describing: PortsView.self)
    
    @IBOutlet var unsortedPortViews: [PortView]! {
        didSet {
            portViews = unsortedPortViews.sorted { $0.center.x < $1.center.x }
        }
    }
    
    private(set) var portViews: [PortView] = []
    
    var ports: [Port] = [] {
        didSet {
            assert(ports.count == portViews.count, "There should be as many port names set as there are port views")
            
            for (index, port) in ports.enumerated() {
                portViews[index].label.text = port.localizedName
                portViews[index].label.accessibilityLabel = port.accessibleDescription
            }
        }
    }
    
    var studDimensions: StudDimensions = .invalid {
        didSet {
            for view in portViews {
                view.studDimensions = studDimensions
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (index, view) in portViews.enumerated() {
            view.frame = frameForPort(at: index).cgRect(with: studDimensions)
        }
    }
    
    func frameForPort(at index: Int) -> BrickRect {
        var frame: BrickRect
        var stepDelta: BrickSize
        
        if bounds.size.width > bounds.size.height {
            frame = BrickRect(x: 0, y: 0, width: 5, height: 2)
            stepDelta = BrickSize(width: 6, height: 0)
        }
        else {
            frame = BrickRect(x: 0, y: 0, width: 2, height: 5)
            stepDelta = BrickSize(width: 0, height: 6)
        }
        
        frame.origin.x += stepDelta.width * index
        frame.origin.y += stepDelta.height * index
        
        return frame
    }
}
