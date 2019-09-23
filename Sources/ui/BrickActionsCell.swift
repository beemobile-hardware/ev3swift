import UIKit

@objc(BrickActionsCell)
class BrickActionsCell: UITableViewCell {
    static let reuseIdentifier = "BrickActionsCell"
    
    @IBOutlet weak var actionLabel: UILabel!
}
