import PlaygroundSupport
import Foundation

public class PlaygroundPageSupport {
    
    public static func createRobot() -> RobotAPI {
        let proxy = PlaygroundPage.current.liveView as! PlaygroundRemoteLiveViewProxy
        let robot = Robot()
        
        robot.proxy = proxy
        //PIOTR proxy.delegate = robot
        
        robot.storeDisplay()
        robot.resetAll()
        
        return robot
    }
    
}
