//
//import UIKit
//import Foundation
//
//open class DrawerBarButtonItem: UIBarButtonItem {
//    
//    var menuButton: AnimatedMenuButton
//    
//    // MARK: - Initializers
//    
//    public override init() {
//        self.menuButton = AnimatedMenuButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
//        super.init()
//        self.customView = self.menuButton
//    }
//    
//    public convenience init(target: AnyObject?, action: Selector) {
//        self.init(target: target, action: action, menuIconColor: UIColor.gray)
//    }
//    
//    public convenience init(target: AnyObject?, action: Selector, menuIconColor: UIColor) {
//        self.init(target: target, action: action, menuIconColor: menuIconColor, animatable: true)
//    }
//    
//    public convenience init(target: AnyObject?, action: Selector, menuIconColor: UIColor, animatable: Bool) {
//        let menuButton = AnimatedMenuButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26), strokeColor: menuIconColor)
//        menuButton.animatable = animatable
//        menuButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
//        self.init(customView: menuButton)
//        
//        self.menuButton = menuButton
//    }
//    
//    public required init?(coder aDecoder: NSCoder) {
//        self.menuButton = AnimatedMenuButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
//        super.init(coder: aDecoder)
//        self.customView = self.menuButton
//    }
//    
//    // MARK: - Animations
//    
//    open func animate(withPercentVisible percentVisible: CGFloat, drawerSide: DrawerSide) {
//        if let btn = self.customView as? AnimatedMenuButton {
//            btn.animate(withPercentVisible: percentVisible, drawerSide: drawerSide)
//        }
//    }
//}

