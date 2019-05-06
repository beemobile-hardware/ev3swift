import UIKit

@objc(PortView)
class PortView: UIView {
    @IBOutlet weak var label: UILabel!
    
    var studDimensions: StudDimensions = .invalid {
        didSet {
            layer.cornerRadius = studDimensions.totalSize / 2.0
            layer.masksToBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .legoDisconnectedPort
    }
    
    func configure(with connection: PlateConnection?) {
        guard let connection = connection else {
            backgroundColor = .legoDisconnectedPort
            label.accessibilityValue = NSLocalizedString("No connection", comment: "Voice Over description a port view that has no connection")
            return
        }
        
        backgroundColor = connection.color
        label.accessibilityValue = String(format: NSLocalizedString("Connected to %@", comment: "Voice Over description a connected port view"),
                                          connection.type.accessibleDescription)
    }
}
