import UIKit

class DebugUIHardwareViewCell: UICollectionViewCell {
    
    var port: DebugUIPort? {
        didSet {
            portView.port = port
        }
    }
    
    let portView: DebugUIPortView!
    
    override init(frame: CGRect) {
        portView = DebugUIPortView(frame: frame)
        super.init(frame: frame)
        
        portView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(portView)
        
        portView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        portView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        portView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        portView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
