import UIKit
import ExternalAccessory

@objc(ConnectionOverviewViewController)
class ConnectionOverviewViewController: UIViewController {
    
    @IBOutlet weak var howToConnectButton: UIButton!
    
    @IBOutlet weak var connectButton: UIButton!
    
    weak var delegate: ConnectionOverviewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .legoLightGray
        
        howToConnectButton.setTitle(NSLocalizedString("How do I connect?", comment: "Button that displays instructions on how to connect the EV3 brick via bluetooth"), for: .normal)
        connectButton.setTitle(NSLocalizedString("Connect EV3 Brick", comment: "Button that displays the system panel and list of available EV3 bricks"), for: .normal)
    }
    
    @IBAction func showConnectDialog(_ sender: UIButton) {
        delegate?.overviewControllerDidTapConnect(self)
    }

    @IBAction func showInstructions(_ sender: UIButton) {
        delegate?.overviewControllerDidTapShowInstructions(self)
    }
}

protocol ConnectionOverviewViewControllerDelegate: class {
    func overviewControllerDidTapConnect(_ controller: ConnectionOverviewViewController)
    func overviewControllerDidTapShowInstructions(_ controller: ConnectionOverviewViewController)
}
