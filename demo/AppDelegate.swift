 import UIKit
 import DrawerController
 
 var drawerController : DrawerPage?
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
    var window : UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        drawerController = DrawerPage()
        window!.rootViewController = drawerController
        window!.rootViewController!.view.backgroundColor = .blue
        window!.makeKeyAndVisible()
        return true
    }
 }
 class DrawerPage : DrawerBase{
    init(){
        super.init(CenterPage(),LeftPage(),RightPage())
    }
    // 哄编译器开心的代码
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 }
 class DrawerBase : DrawerController{
    init(_ center : UIViewController,_ left : UIViewController,_ right : UIViewController){
        super.init(centerViewController: center, leftDrawerViewController: left, rightDrawerViewController: right)
        openDrawerGestureModeMask=OpenDrawerGestureMode.panningCenterView
        closeDrawerGestureModeMask=CloseDrawerGestureMode.all;
    }
    // 从入门到入门：
    // 1. What exactly is init coder aDecoder?
    // 2. What does the question mark means in public init?(coder aDecoder: NSCoder)?
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 }
 class LeftPage: UIViewController {
    var count = 0
    var label : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        label   = UILabel()
        label.frame = CGRect(x: 100, y: 100, width: 120, height: 50)
        label.text =  "Left"
        view.addSubview(label)
        let button   = UIButton(type: .system)
        button.frame = CGRect(x: 120, y: 150, width: 120, height: 50)
        button.setTitle("Close",for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    @objc func buttonAction(_ sender:UIButton!){
        drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
    }
 }
 class RightPage: UIViewController {
    var count = 0
    var label : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        label   = UILabel()
        label.frame = CGRect(x: 100, y: 100, width: 120, height: 50)
        label.text =  "Right"
        view.addSubview(label)
        let button   = UIButton(type: .system)
        button.frame = CGRect(x: 120, y: 150, width: 120, height: 50)
        button.setTitle("Close",for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    @objc func buttonAction(_ sender:UIButton!){
        drawerController?.toggleRightDrawerSide(animated: true, completion: nil)
    }
 }
 class CenterPage: UIViewController {
    var label : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        label   = UILabel()
        label.frame = CGRect(x: 100, y: 100, width: 120, height: 50)
        label.text =  "Center"
        view.addSubview(label)
        let button   = UIButton(type: .system)
        button.frame = CGRect(x: 120, y: 150, width: 120, height: 50)
        button.backgroundColor = .blue
        button.setTitle("Left Page Drawer",for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        let button1   = UIButton(type: .system)
        button1.frame = CGRect(x: 120, y: 200, width: 220, height: 50)
        button1.contentHorizontalAlignment = .left
        button1.setTitle("Right Page Drawer",for: .normal)
        button1.addTarget(self, action: #selector(buttonAction1(_:)), for: .touchUpInside)
        button1.backgroundColor = .red
        view.addSubview(button1)
    }
    @objc func buttonAction(_ sender:UIButton!){
        drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
    }
    @objc func buttonAction1(_ sender:UIButton!){
        drawerController?.toggleRightDrawerSide(animated: true, completion: nil)
    }
 }

