import UIKit
import ExternalAccessory

@objc(ConnectionInstructionsViewController)
class ConnectionInstructionsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step1InstructionsLabel: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var step2InstructionsLabel: UILabel!
    @IBOutlet weak var step3Label: UILabel!
    @IBOutlet weak var step3InstructionsLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    weak var delegate: ConnectionInstructionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .legoLightGray
        
        titleLabel.text = NSLocalizedString("How to connect your EV3",
                                            comment: "The title for instructions on how to connect an EV3 brick")
        step1InstructionsLabel.text = NSLocalizedString("On your EV3 Brick, go to Settings and open Bluetooth.",
                                                        comment: "Step 1 on how to connect an EV3 brick")
        step2InstructionsLabel.text = NSLocalizedString("Enable both Bluetooth and iPhone/iPad/iPod.",
                                                        comment: "Step 2 on how to connect an EV3 brick")
        step3InstructionsLabel.text = NSLocalizedString("Connect your EV3 Brick to this iPad.",
                                                        comment: "Step 3 on how to connect an EV3 brick")

        step1Label.text = NSLocalizedString("1.", comment: "Bullet marker for step 1 on how to connect an EV3 brick")
        step2Label.text = NSLocalizedString("2.", comment: "Bullet marker for step 2 on how to connect an EV3 brick")
        step3Label.text = NSLocalizedString("3.", comment: "Bullet marker for step 3 on how to connect an EV3 brick")
        
        connectButton.setTitle(NSLocalizedString("Connect EV3 Brick", comment: "Button that displays the system panel and list of available EV3 bricks"), for: .normal)
    }
    
    @IBAction func showConnectDialog(_ sender: UIButton) {
        delegate?.instructionsControllerDidTapConnect(self)
    }
}

protocol ConnectionInstructionsViewControllerDelegate: class {
    func instructionsControllerDidTapConnect(_ controller: ConnectionInstructionsViewController)
}
