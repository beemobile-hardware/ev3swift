import UIKit

extension UIViewController {
    
    public static func instantiateFromStoryboard<T>(named storyboardName: String) -> T {
        let bundle = Bundle(for: T.self as! AnyClass)
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let identifier = String(describing: self)
        
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    public static func instantiateFromMainStoryboard<T>() -> T {
        return instantiateFromStoryboard(named: "Main")
    }
}
