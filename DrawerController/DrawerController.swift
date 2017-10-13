import UIKit
open class DrawerController: UIViewController {
    fileprivate var _centerViewController: UIViewController?
    fileprivate var _leftDrawerViewController: UIViewController?
    fileprivate var _rightDrawerViewController: UIViewController?
    fileprivate var _maximumLeftDrawerWidth = DrawerDefaultWidth
    fileprivate var _maximumRightDrawerWidth = DrawerDefaultWidth
    open var centerViewController: UIViewController? {
        get {
            return self._centerViewController
        }
        set {
            self.setCenter(newValue, animated: false)
        }
    }
    open var leftDrawerViewController: UIViewController? {
        get {
            return self._leftDrawerViewController
        }
        set {
            self.setDrawer(newValue, for: .left)
        }
    }
    open var rightDrawerViewController: UIViewController? {
        get {
            return self._rightDrawerViewController
        }
        set {
            self.setDrawer(newValue, for: .right)
        }
    }
    open var maximumLeftDrawerWidth: CGFloat {
        get {
            if self.leftDrawerViewController != nil {
                return self._maximumLeftDrawerWidth
            } else {
                return 0.0
            }
        }
        set {
            self.setMaximumLeftDrawerWidth(newValue, animated: false, completion: nil)
        }
    }
    open var maximumRightDrawerWidth: CGFloat {
        get {
            if self.rightDrawerViewController != nil {
                return self._maximumRightDrawerWidth
            } else {
                return 0.0
            }
        }
        set {
            self.setMaximumRightDrawerWidth(newValue, animated: false, completion: nil)
        }
    }
    open var visibleLeftDrawerWidth: CGFloat {
        get {
            return max(0.0, self.centerContainerView.frame.minX)
        }
    }
    open var visibleRightDrawerWidth: CGFloat {
        get {
            if self.centerContainerView.frame.minX < 0 {
                return self.childControllerContainerView.bounds.width - self.centerContainerView.frame.maxX
            } else {
                return 0.0
            }
        }
    }
    open var shadowRadius = DrawerDefaultShadowRadius
    open var shadowOpacity = DrawerDefaultShadowOpacity
    open var showsShadows: Bool = true {
        didSet {
            self.updateShadowForCenterView()
        }
    }
    open var animationVelocity:CGFloat = 1.0
    open var minimumAnimationDuration :CGFloat = 1.0
    fileprivate var animatingDrawer: Bool = false {
        didSet {
            self.view.isUserInteractionEnabled = !self.animatingDrawer
        }
    }
    fileprivate lazy var childControllerContainerView: UIView = {
        let childContainerViewFrame = self.view.bounds
        let childControllerContainerView = UIView(frame: childContainerViewFrame)
        childControllerContainerView.backgroundColor = UIColor.clear
        childControllerContainerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(childControllerContainerView)
        return childControllerContainerView
    }()
    fileprivate lazy var centerContainerView: DrawerCenterContainerView = {
        let centerFrame = self.childControllerContainerView.bounds
        let centerContainerView = DrawerCenterContainerView(frame: centerFrame)
        centerContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        centerContainerView.backgroundColor = UIColor.clear
        self.childControllerContainerView.addSubview(centerContainerView)
        return centerContainerView
    }()
    open fileprivate(set) var openSide: DrawerSide = .none {
        didSet {
            if self.openSide == .none {
                self.leftDrawerViewController?.view.isHidden = true
                self.rightDrawerViewController?.view.isHidden = true
            }
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public init(centerViewController: UIViewController, leftDrawerViewController: UIViewController?, rightDrawerViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        self.centerViewController = centerViewController
        self.leftDrawerViewController = leftDrawerViewController
        self.rightDrawerViewController = rightDrawerViewController
    }
    public convenience init(centerViewController: UIViewController, leftDrawerViewController: UIViewController?) {
        self.init(centerViewController: centerViewController, leftDrawerViewController: leftDrawerViewController, rightDrawerViewController: nil)
    }
    public convenience init(centerViewController: UIViewController, rightDrawerViewController: UIViewController?) {
        self.init(centerViewController: centerViewController, leftDrawerViewController: nil, rightDrawerViewController: rightDrawerViewController)
    }
    override open var childViewControllerForStatusBarHidden : UIViewController? {
        return self.childViewController(for: self.openSide)
    }
    override open var childViewControllerForStatusBarStyle : UIViewController? {
        return self.childViewController(for: self.openSide)
    }
    fileprivate func childViewController(for drawerSide: DrawerSide) -> UIViewController? {
        var childViewController: UIViewController?
        switch drawerSide {
        case .left:
            childViewController = self.leftDrawerViewController
        case .right:
            childViewController = self.rightDrawerViewController
        case .none:
            childViewController = self.centerViewController
        }
        return childViewController
    }
    fileprivate func sideDrawerViewController(for drawerSide: DrawerSide) -> UIViewController? {
        var sideDrawerViewController: UIViewController?
        if drawerSide != .none {
            sideDrawerViewController = self.childViewController(for: drawerSide)
        }
        return sideDrawerViewController
    }
    fileprivate func prepareToPresentDrawer(for drawer: DrawerSide, animated: Bool) {
        var drawerToHide: DrawerSide = .none
        if drawer == .left {
            drawerToHide = .right
        } else if drawer == .right {
            drawerToHide = .left
        }
        if let sideDrawerViewControllerToHide = self.sideDrawerViewController(for: drawerToHide) {
            self.childControllerContainerView.sendSubview(toBack: sideDrawerViewControllerToHide.view)
            sideDrawerViewControllerToHide.view.isHidden = true
        }
        if let sideDrawerViewControllerToPresent = self.sideDrawerViewController(for: drawer) {
            sideDrawerViewControllerToPresent.view.isHidden = false
            sideDrawerViewControllerToPresent.view.frame = sideDrawerViewControllerToPresent.evo_visibleDrawerFrame
            sideDrawerViewControllerToPresent.beginAppearanceTransition(true, animated: animated)
        }
    }
    fileprivate func updateShadowForCenterView() {
        if self.showsShadows {
            self.centerContainerView.layer.masksToBounds = false
            self.centerContainerView.layer.shadowRadius = shadowRadius
            self.centerContainerView.layer.shadowOpacity = shadowOpacity
            /** In the event this gets called a lot, we won't update the shadowPath
             unless it needs to be updated (like during rotation) */
            if let shadowPath = centerContainerView.layer.shadowPath {
                let currentPath = shadowPath.boundingBoxOfPath
                if currentPath.equalTo(centerContainerView.bounds) == false {
                    centerContainerView.layer.shadowPath = UIBezierPath(rect: centerContainerView.bounds).cgPath
                }
            } else {
                self.centerContainerView.layer.shadowPath = UIBezierPath(rect: self.centerContainerView.bounds).cgPath
            }
        } else if self.centerContainerView.layer.shadowPath != nil {
            self.centerContainerView.layer.shadowRadius = 0.0
            self.centerContainerView.layer.shadowOpacity = 0.0
            self.centerContainerView.layer.shadowPath = nil
            self.centerContainerView.layer.masksToBounds = true
        }
    }
    fileprivate func animationDuration(forAnimationDistance distance: CGFloat) -> TimeInterval {
        return TimeInterval(max(distance / self.animationVelocity, minimumAnimationDuration))
    }
    // MARK: - Size Methods
    /**
     Sets the maximum width of the left drawer view controller.
     If the drawer is open, and `animated` is YES, it will animate the drawer frame as well as adjust the center view controller. If the drawer is not open, this change will take place immediately.
     - parameter width: The new width of left drawer view controller. This must be greater than zero.
     - parameter animated: Determines whether the drawer should be adjusted with an animation.
     - parameter completion: The block called when the animation is finished.
     */
    open func setMaximumLeftDrawerWidth(_ width: CGFloat, animated: Bool, completion: ((Bool) -> Void)?) {
        self.setMaximumDrawerWidth(width, forSide: .left, animated: animated, completion: completion)
    }
    // MARK: - Setters
    fileprivate func setRightDrawer(_ rightDrawerViewController: UIViewController?) {
        self.setDrawer(rightDrawerViewController, for: .right)
    }
    fileprivate func setLeftDrawer(_ leftDrawerViewController: UIViewController?) {
        self.setDrawer(leftDrawerViewController, for: .left)
    }

    open func toggleLeftDrawerSide(animated: Bool, completion: ((Bool) -> Void)?) {
        self.toggleDrawerSide(.left, animated: animated, completion: completion)
    }
    open func toggleRightDrawerSide(animated: Bool, completion: ((Bool) -> Void)?) {
        self.toggleDrawerSide(.right, animated: animated, completion: completion)
    }
    open func toggleDrawerSide(_ drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .none
        }(), "drawerSide cannot be .None")
        if self.openSide == DrawerSide.none {
            self.openDrawerSide(drawerSide, animated: animated, completion: completion)
        } else {
            if (drawerSide == DrawerSide.left && self.openSide == DrawerSide.left) || (drawerSide == DrawerSide.right && self.openSide == DrawerSide.right) {
                self.closeDrawer(animated: animated, completion: completion)
            } else if completion != nil {
                completion!(false)
            }
        }
    }
    open func openDrawerSide(_ drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .none
        }(), "drawerSide cannot be .None")
        self.openDrawerSide(drawerSide, animated: animated, velocity: self.animationVelocity, animationOptions: [], completion: completion)
    }
    fileprivate func openDrawerSide(_ drawerSide: DrawerSide, animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .none
        }(), "drawerSide cannot be .None")
        let sideDrawerViewController = self.sideDrawerViewController(for: drawerSide)
        if self.openSide != drawerSide {
            self.prepareToPresentDrawer(for: drawerSide, animated: animated)
        }
        if sideDrawerViewController != nil {
            var newFrame: CGRect
            if drawerSide == .left {
                newFrame = self.centerContainerView.frame
                newFrame.origin.x = self._maximumLeftDrawerWidth
            } else {
                newFrame = self.centerContainerView.frame
                newFrame.origin.x = 0 - self._maximumRightDrawerWidth
            }
            self.setNeedsStatusBarAppearanceUpdate()
            self.centerContainerView.frame = newFrame
//            self.updateDrawerVisualState(for: drawerSide, percentVisible: 1.0)
            if drawerSide != self.openSide {
                sideDrawerViewController!.endAppearanceTransition()
            }
            self.openSide = drawerSide
        }
    }
    fileprivate func setDrawer(_ viewController: UIViewController?, for drawerSide: DrawerSide) {
        assert({ () -> Bool in
            return drawerSide != .none
        }(), "drawerSide cannot be .None")
        let currentSideViewController = self.sideDrawerViewController(for: drawerSide)
        if currentSideViewController == viewController {
            return
        }
        if currentSideViewController != nil {
            currentSideViewController!.beginAppearanceTransition(false, animated: false)
            currentSideViewController!.view.removeFromSuperview()
            currentSideViewController!.endAppearanceTransition()
            currentSideViewController!.willMove(toParentViewController: nil)
            currentSideViewController!.removeFromParentViewController()
        }
        var autoResizingMask = UIViewAutoresizing()
        if drawerSide == .left {
            self._leftDrawerViewController = viewController
            autoResizingMask = [.flexibleRightMargin, .flexibleHeight]
        } else if drawerSide == .right {
            self._rightDrawerViewController = viewController
            autoResizingMask = [.flexibleLeftMargin, .flexibleHeight]
        }
        if viewController != nil {
            self.addChildViewController(viewController!)
            if (self.openSide == drawerSide) && (self.childControllerContainerView.subviews as NSArray).contains(self.centerContainerView) {
                self.childControllerContainerView.insertSubview(viewController!.view, belowSubview: self.centerContainerView)
                viewController!.beginAppearanceTransition(true, animated: false)
                viewController!.endAppearanceTransition()
            } else {
                self.childControllerContainerView.addSubview(viewController!.view)
                self.childControllerContainerView.sendSubview(toBack: viewController!.view)
                //                self.childControllerContainerView.bringSubview(toFront: viewController!.view)
                viewController!.view.isHidden = true
            }
            viewController!.didMove(toParentViewController: self)
            viewController!.view.autoresizingMask = autoResizingMask
            viewController!.view.frame = viewController!.evo_visibleDrawerFrame
        }
    }
    // MARK: - Updating the Center View Controller
    fileprivate func setCenter(_ centerViewController: UIViewController?, animated: Bool) {
        if self._centerViewController == centerViewController {
            return
        }
        if let oldCenterViewController = self._centerViewController {
            oldCenterViewController.willMove(toParentViewController: nil)
            if animated == false {
                oldCenterViewController.beginAppearanceTransition(false, animated: false)
            }
            oldCenterViewController.removeFromParentViewController()
            oldCenterViewController.view.removeFromSuperview()
            if animated == false {
                oldCenterViewController.endAppearanceTransition()
            }
        }
        self._centerViewController = centerViewController
        if self._centerViewController != nil {
            self.addChildViewController(self._centerViewController!)
            self._centerViewController!.view.frame = self.childControllerContainerView.bounds
            self.centerContainerView.addSubview(self._centerViewController!.view)
            self.childControllerContainerView.bringSubview(toFront: self.centerContainerView)
            self._centerViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.updateShadowForCenterView()
            if animated == false {
                // If drawer is offscreen, then viewWillAppear: will take care of this
                if self.view.window != nil {
                    self._centerViewController!.beginAppearanceTransition(true, animated: false)
                    self._centerViewController!.endAppearanceTransition()
                }
                self._centerViewController!.didMove(toParentViewController: self)
            }
        }
    }
    open func closeDrawer(animated: Bool, completion: ((Bool) -> Void)?) {
        let newFrame = self.childControllerContainerView.bounds
        self.setNeedsStatusBarAppearanceUpdate()
        self.centerContainerView.frame = newFrame
        self.openSide = .none
    }
    // MARK: - UIViewController
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
//        self.setupGestureRecognizers()
    }
    /**
     Sets the maximum width of the right drawer view controller.
     If the drawer is open, and `animated` is YES, it will animate the drawer frame as well as adjust the center view controller. If the drawer is not open, this change will take place immediately.
     - parameter width: The new width of right drawer view controller. This must be greater than zero.
     - parameter animated: Determines whether the drawer should be adjusted with an animation.
     - parameter completion: The block called when the animation is finished.
     */
    open func setMaximumRightDrawerWidth(_ width: CGFloat, animated: Bool, completion: ((Bool) -> Void)?) {
        self.setMaximumDrawerWidth(width, forSide: .right, animated: animated, completion: completion)
    }
    fileprivate func setMaximumDrawerWidth(_ width: CGFloat, forSide drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return width > 0
        }(), "width must be greater than 0")
        assert({ () -> Bool in
            return drawerSide != .none
        }(), "drawerSide cannot be .None")
        if let sideDrawerViewController = self.sideDrawerViewController(for: drawerSide) {
            var drawerSideOriginCorrection: NSInteger = 1
            if drawerSide == .left {
                self._maximumLeftDrawerWidth = width
            } else if (drawerSide == .right) {
                self._maximumRightDrawerWidth = width
                drawerSideOriginCorrection = -1
            }
            if self.openSide == drawerSide {
                var newCenterRect = self.centerContainerView.frame
                newCenterRect.origin.x = CGFloat(drawerSideOriginCorrection) * width
                self.centerContainerView.frame = newCenterRect
                sideDrawerViewController.view.frame = sideDrawerViewController.evo_visibleDrawerFrame
            } else {
                sideDrawerViewController.view.frame = sideDrawerViewController.evo_visibleDrawerFrame
                completion?(true)
            }
        }
    }
}
public extension UIViewController {
    var evo_visibleDrawerFrame: CGRect {
        func evo_drawerController()-> DrawerController? {
            var parentViewController = self.parent
            while parentViewController != nil {
                if parentViewController!.isKind(of: DrawerController.self) {
                    return parentViewController as? DrawerController
                }
                parentViewController = parentViewController!.parent
            }
            return nil
        }
        if let drawerController = evo_drawerController() {
            if drawerController.leftDrawerViewController != nil {
                if self == drawerController.leftDrawerViewController || self.navigationController == drawerController.leftDrawerViewController {
                    var rect = drawerController.view.bounds
                    rect.size.width = drawerController.maximumLeftDrawerWidth
                    return rect
                }
            }
            if drawerController.rightDrawerViewController != nil {
                if self == drawerController.rightDrawerViewController || self.navigationController == drawerController.rightDrawerViewController {
                    var rect = drawerController.view.bounds
                    rect.size.width = drawerController.maximumRightDrawerWidth
                    rect.origin.x = drawerController.view.bounds.width - rect.size.width
                    return rect
                }
            }
        }
        return CGRect.null
    }
}
public enum DrawerSide: Int {
    case none
    case left
    case right
}
private let DrawerDefaultWidth: CGFloat = 280.0
private let DrawerDefaultShadowRadius: CGFloat = 10.0
private let DrawerDefaultShadowOpacity: Float = 0.8
typealias  DrawerCenterContainerView =  UIView
