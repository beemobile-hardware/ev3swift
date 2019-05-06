import UIKit
import PlaygroundSupport

// Note: To use view controllers in a story board with Swift Playgrounds,
// it currently requires the @objc declaration AND playgrounds requires the
// compiled storyboard, which this project automatically inserts into the 
// playground book's resource directory.
@objc(LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    // MARK: - Supporting App Mock
    
    var loadedFromPlayground = true
    var mockRobot: Robot?
    var mockRemoteLiveViewProxy: MockRemoteLiveViewProxy?
    var mockRobotThread: Thread?
    
    // MARK: - Debug UI
    
    var allPortData = [[PortData]]()
    
    var dates = [Date]()
    var startDate: Date?
    
    var currentIndex = 0
    
    let slider = UISlider()
    let label = UILabel()
    
    let firstShapeLayer = CAShapeLayer()
    let secondShapeLayer = CAShapeLayer()
    
    let hardwareCollectionView = DebugUIHardwareCollectionView()
   
    // MARK: - Communication
    
    var communicationLayer: EV3CommunicationLayer?
    
    // MARK: - View Controller LifeCycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        communicationLayer = EV3CommunicationLayer(commandManager: DefaultCommandManager(), delegate: self)
        communicationLayer?.setup()
        
        createUI()
        
        #if SUPPORTINGCONTENT
            setupSupportingContent()
        #endif
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
}
