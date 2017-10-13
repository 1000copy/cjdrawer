import UIKit
// code imple
open class DrawerController: UIViewController {
    fileprivate var _centerViewController: UIViewController?
    fileprivate var _leftDrawerViewController: UIViewController?
    fileprivate var _leftDrawerWidth = DrawerDefaultWidth
    open var centerViewController: UIViewController? {
        get {
            return self._centerViewController
        }
    }
    open var leftDrawerViewController: UIViewController? {
        get {
            return self._leftDrawerViewController
        }
    }
    open var leftDrawerWidth: CGFloat {
        get {
            return self._leftDrawerWidth
        }
    }
    open var shadowRadius = DrawerDefaultShadowRadius
    open var shadowOpacity = DrawerDefaultShadowOpacity
    fileprivate lazy var childControllerContainerView: UIView = {
        let a = UIView(frame: self.view.bounds)
        self.view.addSubview(a)
        return a
    }()
    fileprivate lazy var centerContainerView: DrawerCenterContainerView = {
        let centerFrame = self.childControllerContainerView.bounds
        let centerContainerView = DrawerCenterContainerView(frame: centerFrame)
        centerContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        centerContainerView.backgroundColor = UIColor.clear
        self.childControllerContainerView.addSubview(centerContainerView)
        return centerContainerView
    }()
    open fileprivate(set) var openSide: DrawerSide = .center {
        didSet {
            if self.openSide == .center {
                self.leftDrawerViewController?.view.isHidden = true
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
    public init(centerViewController: UIViewController, leftDrawerViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        self.setCenter(centerViewController)
        self.setDrawer(leftDrawerViewController,for:.left)
    }
    fileprivate func childViewController(for drawerSide: DrawerSide) -> UIViewController? {
        var childViewController: UIViewController?
        switch drawerSide {
        case .left:
            childViewController = self.leftDrawerViewController
        case .center:
            childViewController = self.centerViewController
        }
        return childViewController
    }
    fileprivate func sideDrawerViewController(for drawerSide: DrawerSide) -> UIViewController? {
        var sideDrawerViewController: UIViewController?
        if drawerSide != .center {
            sideDrawerViewController = self.childViewController(for: drawerSide)
        }
        return sideDrawerViewController
    }
    fileprivate func updateShadowForCenterView() {
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
    }
    open func toggleLeftDrawerSide(animated: Bool, completion: ((Bool) -> Void)?) {
        self.toggleDrawerSide(.left, animated: animated, completion: completion)
    }
    open func toggleDrawerSide(_ drawerSide: DrawerSide, animated: Bool, completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .center
        }(), "drawerSide cannot be .None")
        if self.openSide == DrawerSide.center {
            self.openDrawerSide(drawerSide,completion: completion)
        } else {
            if (drawerSide == DrawerSide.left && self.openSide == DrawerSide.left) {
                self.closeDrawer(animated: animated, completion: completion)
            } else if completion != nil {
                completion!(false)
            }
        }
    }
    fileprivate func openDrawerSide(_ drawerSide: DrawerSide,completion: ((Bool) -> Void)?) {
        assert({ () -> Bool in
            return drawerSide != .center
        }(), "drawerSide cannot be .None")
        if let vc = self.leftDrawerViewController{
            vc.view.isHidden = false
            var newFrame: CGRect
            newFrame = view.frame
            newFrame.size.width = _leftDrawerWidth
            vc.view.frame = newFrame
            //            vc.view.frame = vc.evo_visibleDrawerFrame
        }
        func panRight(_ view : UIView,_ value : CGFloat){
            var newFrame: CGRect
            newFrame = view.frame
            newFrame.origin.x = value
            view.frame = newFrame
        }
        panRight(centerContainerView, _leftDrawerWidth)
        self.openSide = drawerSide
    }
    fileprivate func setDrawer(_ vc: UIViewController?, for drawerSide: DrawerSide) {
        assert({ () -> Bool in
            return drawerSide != .center
        }(), "drawerSide cannot be .None")
        let currentSideViewController = self.sideDrawerViewController(for: drawerSide)
        if currentSideViewController == vc {
            return
        }
        self._leftDrawerViewController = vc
        if vc != nil {
            self.addChildViewController(vc!)
            vc!.didMove(toParentViewController: self)
            self.childControllerContainerView.addSubview(vc!.view)
            self.childControllerContainerView.sendSubview(toBack: vc!.view)
            vc!.view.isHidden = true
        }
    }
    fileprivate func setCenter(_ vc: UIViewController?) {
        self._centerViewController = vc
        if vc != nil {
            self.addChildViewController(vc!)
            vc!.didMove(toParentViewController: self)
            self.centerContainerView.addSubview(vc!.view)
            self._centerViewController!.view.frame = self.centerContainerView.bounds
            self.updateShadowForCenterView()
        }
    }
    open func closeDrawer(animated: Bool, completion: ((Bool) -> Void)?) {
        let newFrame = self.childControllerContainerView.bounds
        self.setNeedsStatusBarAppearanceUpdate()
        self.centerContainerView.frame = newFrame
        self.openSide = .center
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
    }
    static let DrawerDefaultWidth: CGFloat = 210.0 //280.0
    static let DrawerDefaultShadowRadius: CGFloat = 10.0
    static let DrawerDefaultShadowOpacity: Float = 0.8
    typealias  DrawerCenterContainerView =  UIView
    public enum DrawerSide: Int {
        case center
        case left
    }
}

