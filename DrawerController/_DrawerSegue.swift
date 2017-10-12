//import UIKit
//
//public class DrawerSegue: UIStoryboardSegue {
//    override public func perform() {
//        assert(source is DrawerController, "DrawerSegue can only be used to define left/center/right controllers for a DrawerController")
//    }
//}
//
//fileprivate extension UIViewController {
//    
//    // check if a view controller can perform segue
//    func canPerformSegue(withIdentifier identifier: String) -> Bool {
//        let templates: NSArray = value(forKey: "storyboardSegueTemplates") as! NSArray
//        let predicate: NSPredicate = NSPredicate(format: "identifier=%@", identifier)
//        let filteredtemplates = templates.filtered(using: predicate)
//        return filteredtemplates.count > 0
//    }
//}
//
//extension DrawerController {
//
//    private enum Keys: String {
//        case center = "center"
//        case left = "left"
//        case right = "right"
//    }
//
//    open override func awakeFromNib() {
//        guard storyboard != nil else {
//            return
//        }
//        
//        // Required segue "center". Uncaught exception if undefined in storyboard.
//        performSegue(withIdentifier: Keys.center.rawValue, sender: self)
//        
//        // Optional segue "left".
//        if canPerformSegue(withIdentifier: Keys.left.rawValue) {
//            performSegue(withIdentifier: Keys.left.rawValue, sender: self)
//        }
//        
//        // Optional segue "right".
//        if canPerformSegue(withIdentifier: Keys.right.rawValue) {
//            performSegue(withIdentifier: Keys.right.rawValue, sender: self)
//        }
//    }
//    
//    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue is DrawerSegue {
//            switch segue.identifier {
//            case let x where x == Keys.center.rawValue:
//                centerViewController = segue.destination
//            case let x where x == Keys.left.rawValue:
//                leftDrawerViewController = segue.destination
//            case let x where x == Keys.right.rawValue:
//                rightDrawerViewController = segue.destination
//            default:
//                break
//            }
//            
//            return
//        }
//
//        super.prepare(for: segue, sender: sender)
//    }
//    
//}

