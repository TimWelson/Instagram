//
//  signUpVC.swift
//  Instagram
//
//  Created by Shao Kahn on 9/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Parse

class signUpVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate {
   
    @IBOutlet weak var gradientImgView: UIImageViewX!
    
    @IBOutlet weak var avaImg: UIImageView!
 
    @IBOutlet var allTextFieldsInScreen: [UITextField_Attributes]!
{didSet{_ = self.allTextFieldsInScreen.map{$0.delegate = self}}}
 
    @IBOutlet var allCountTip: [UILabel]!

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    fileprivate var currentColorArrayIndex = -1
    
    fileprivate var currentTextField:UITextField!
    
    fileprivate var colorArray:[(color1:UIColor,color2:UIColor)] = []
    
    fileprivate var tempString = ""
    
    fileprivate var tempCount = 0
    
   fileprivate var picker = UIImagePickerController()
     {didSet{self.picker.delegate = self}}
    
    fileprivate var alertController:UIAlertController?
    
   fileprivate let knownAction = UIAlertAction.init(title: "OK,I know that", style: .cancel, handler: nil)
   
    let rootLayer:CALayer = {
        let Layer = CALayer()
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        replicatorLayer.borderColor = UIColor.clear.cgColor
        replicatorLayer.cornerRadius = 5.0
        replicatorLayer.borderWidth = 1.0
        
        let circle = CALayer()
circle.frame = CGRect(origin: CGPoint.zero,
                              size: CGSize(width: 10, height: 10))
        circle.backgroundColor = UIColor.blue.cgColor
        circle.cornerRadius = 10
        
        //circle.position = CGPoint(x: 20, y: 100)
        replicatorLayer.addSublayer(circle)
        
let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
        shrinkAnimation.fromValue = 1
        shrinkAnimation.toValue = 0.1
        shrinkAnimation.duration = 1
shrinkAnimation.repeatCount = Float.greatestFiniteMagnitude
        circle.add(shrinkAnimation, forKey: nil)
        
        let instanceCount = 11
        replicatorLayer.instanceCount = instanceCount
replicatorLayer.instanceDelay = shrinkAnimation.duration / CFTimeInterval(instanceCount)
        
        let angle = -CGFloat.pi * 2 / CGFloat(instanceCount)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        Layer.addSublayer(replicatorLayer)
        return Layer
    }()
    
    let rightView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
       
        //create tap gesture
        createScreenDismissKeyboard()
        
        //set count label attributes
        setCountLabelAttributes()
        
        //ava image layer
        setAvaImgLayer()
        
        //declare select image
        declareSelectedImage()
 
        //initialize text fields false isEnable input
        initInputFirst()
        
        // add root layer to right view
        //addRootLayerToRightView()
        
        //set text fields right views
        setRightViews()
        
        //set image color set
        setColorArr()
        
        //recursively run animatedBackground()
        animatedBackground()
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       //create observers
        createObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
      //remove observers
        removeObservers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //click sign up
    @IBAction func signUpBtn_click(_ sender: UIButton) {
 
        //dismiss keyboard
   self.view.endEditing(true)
        
//send data to server to relative columns
let user = PFUser()
user.username = allTextFieldsInScreen[0].text?.lowercased()
user.email = allTextFieldsInScreen[4].text?.lowercased()
user.password = allTextFieldsInScreen[2].text
user["fullname"] = allTextFieldsInScreen[1].text?.lowercased()
user["bio"] = allTextFieldsInScreen[6].text
user["web"] = allTextFieldsInScreen[5].text?.lowercased()
        
        //in Edited Profile it's gonna be assigned
        user["tel"] = ""
        user["gender"] = ""
        
        //convert our image for sending to server
        guard let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5),let avaFile = PFFile(name: "ava.jpg", data: avaData) else {return}
     
     user["ava"] = avaFile
      
//save data in server
user.signUpInBackground { (success:Bool, error:Error?) in
            if success{
                
    //remember logged user
    UserDefaults.standard.set(user.username, forKey: "username")
    UserDefaults.standard.synchronize()
               
    //call login func from AppleDelegate.swift class
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
            }else{print(error ?? "")}
        }
    }
   
    //click cancel
    @IBAction func cancelBtn_click(_ sender: Any) {
        
    self.dismiss(animated: true, completion: nil)
    }
}//signUpVC class over line

//custom functions
extension signUpVC {
    
    fileprivate func addRootLayerToRightView(){
      
        rootLayer.frame = rightView.frame
        rootLayer.backgroundColor = UIColor.black.cgColor
        rightView.layer.addSublayer(rootLayer)
    }
    
    fileprivate func setRightViews(){
       
        _ = allTextFieldsInScreen.map{
            $0.rightView?.frame = CGRect(x: 0, y: 5, width: 30 , height:30)
            $0.rightViewMode = .never
        }
    }
    
    fileprivate func createScreenDismissKeyboard(){
        let gestrue = UITapGestureRecognizer.init(target: self, action: #selector(tapGestrue))
        self.view.addGestureRecognizer(gestrue)
    }
    
    fileprivate func setCountLabelAttributes(){
 
_ = allCountTip.map{
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = 3
}
}
    
    fileprivate  func setAvaImgLayer(){
        
        //round ava
avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        
        //clip image
        avaImg.clipsToBounds = true
        
        avaImg.layer.borderWidth = 3
        avaImg.layer.borderColor = UIColor.white.cgColor
    }
    
    //initialize text fields false isEnable input
 fileprivate func initInputFirst(){
    
    signUpBtn.applyGradient(gradient: CAGradientLayer(), colours: [UIColor(hex:"dE6161"),UIColor(hex:"2657EB")], locations: [0.0, 0.5, 1.0], stP: CGPoint(x:0.0,y:0.0), edP: CGPoint(x:1.0,y:0.0), gradientAnimation: CABasicAnimation())
    
    cancelBtn.applyGradient(gradient: CAGradientLayer(), colours: [UIColor(hex: "FC5C7D"), UIColor(hex: "6A82FB")], locations:[0.0,1.0], stP: CGPoint(x:0.0, y:0.0), edP: CGPoint(x:1.0, y:0.0), gradientAnimation: CABasicAnimation())
    }
    
    //declare select image
 fileprivate func declareSelectedImage(){
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(self.loadImg(recognizer:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true //user can click image
        avaImg.addGestureRecognizer(avaTap)
    }
    
     //set image color set
    fileprivate func setColorArr(){
colorArray.append(contentsOf: [(color1: #colorLiteral(red: 0.2039215686, green: 0.9098039216, blue: 0.6196078431, alpha: 1), color2: #colorLiteral(red: 0.05882352941, green: 0.2039215686, blue: 0.262745098, alpha: 1)),(color1: #colorLiteral(red: 0.03529411765, green: 0.2117647059, blue: 0.2156862745, alpha: 1), color2: #colorLiteral(red: 0.2666666667, green: 0.6274509804, blue: 0.5529411765, alpha: 1)),(color1: #colorLiteral(red: 0.4039215686, green: 0.6980392157, blue: 0.4352941176, alpha: 1), color2: #colorLiteral(red: 0.2980392157, green: 0.6352941176, blue: 0.8039215686, alpha: 1)),(color1: #colorLiteral(red: 0, green: 0.7647058824, blue: 1, alpha: 1), color2: #colorLiteral(red: 1, green: 1, blue: 0.1098039216, alpha: 1)),(color1: #colorLiteral(red: 0.968627451, green: 0.6156862745, blue: 0, alpha: 1), color2: #colorLiteral(red: 0.3921568627, green: 0.9529411765, blue: 0.5490196078, alpha: 1))])
}
    
    //recursively run animatedBackground()
    fileprivate func animatedBackground(){
        
currentColorArrayIndex = currentColorArrayIndex == (colorArray.count - 1) ? 0 : currentColorArrayIndex + 1
UIView.transition(with: gradientImgView, duration: 2, options: [.transitionCrossDissolve], animations: {
self.gradientImgView.firstColor = self.colorArray[self.currentColorArrayIndex].color1
self.gradientImgView.secondColor = self.colorArray[self.currentColorArrayIndex].color2
        }) { (success) in
            self.animatedBackground()
        }
    }
    
fileprivate func setCountTip(with someoneCount:UILabel,someoneLimitCount:UILabel){
 
currentTextField.rightViewMode = .never
tempCount = (currentTextField.text?.count)!
if tempCount == 0{
someoneCount.textColor = UIColor.red
}else{someoneCount.textColor = someoneLimitCount.textColor}
if tempCount == Int(someoneLimitCount.text!)!{
someoneCount.text = someoneLimitCount.text
tempString = currentTextField.text!
}else if tempCount > Int(someoneLimitCount.text!)!{
someoneCount.text = someoneLimitCount.text
currentTextField.text = tempString
}else {someoneCount.text = "\(tempCount)"}
}
   
fileprivate func performNilCheck(with nilMessage: String){
        
    guard currentTextField.text != "" else{
        alertController = nil
        alertController = UIAlertController.init(title: "Something wrong", message: nilMessage, preferredStyle: .alert)
        alertController?.addAction(knownAction)
        currentTextField.rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
        currentTextField.rightViewMode = .always
        present(alertController!, animated: true, completion: nil)
        return
    }
}
    
    fileprivate func showAlert(with message:String){
        
alertController = nil
alertController = UIAlertController.init(title: "Something wrong", message: message, preferredStyle: .alert)
        alertController?.addAction(knownAction)
present(alertController!, animated: true, completion: nil)
    }
}

//custom functions selectors
extension signUpVC{
    
    @objc fileprivate func tapGestrue(){
        self.view.endEditing(true)
    }
    
    //choose the photo from the phone library
@objc fileprivate func loadImg(recognizer:UITapGestureRecognizer){
        
        //picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}

//observers
extension signUpVC{
    
    fileprivate func createObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCountTip(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkText(argu:)), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
    }
    
    fileprivate func removeObservers(){
        
        NotificationCenter.default.removeObserver(self)
    }
}

//observers selectors
extension signUpVC{
    
    @objc fileprivate func setCountTip(_ argu:Notification){
        
_ = [10,20,30,40,70].enumerated().map{ (offset,element) in
    
    if element == currentTextField.tag{
setCountTip(with: allCountTip[offset * 2], someoneLimitCount: allCountTip[offset * 2 + 1])
       }
  }
}
    
    @objc fileprivate func checkText(argu:Notification){
        
if currentTextField.tag == 10 {

    guard allTextFieldsInScreen[0].text != "" else{
        alertController = nil
        alertController = UIAlertController.init(title: "Something wrong", message: "username can' be nil", preferredStyle: .alert)
        alertController?.addAction(knownAction)
        allTextFieldsInScreen[0].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
        allTextFieldsInScreen[0].rightViewMode = .always
        present(alertController!, animated: true, completion: nil)
        return
    }
    guard Validate.username((allTextFieldsInScreen[1].text)!).isRight else {
    allTextFieldsInScreen[0].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    allTextFieldsInScreen[0].rightViewMode = .always
    showAlert(with: "username can only include letters,numbers,dot,underline");return
    }
    
    let query = PFQuery.init(className: "_User")
    query.whereKey("username", equalTo: allTextFieldsInScreen[0].text!)
    query.findObjectsInBackground(block: { (objects, error) in
        if error == nil{
            if objects!.count > 0{
self.allTextFieldsInScreen[0].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
self.allTextFieldsInScreen[0].rightViewMode = .always
self.showAlert(with: "username has been taken")
            } else {
self.allTextFieldsInScreen[0].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
self.allTextFieldsInScreen[0].rightViewMode = .always
            }
        }else {print(error!.localizedDescription)}
    })
}

        if currentTextField.tag == 20 {
  
guard allTextFieldsInScreen[1].text != "" else{
alertController = nil
alertController = UIAlertController.init(title: "Something wrong", message: "fullname can't be nil", preferredStyle: .alert)
alertController?.addAction(knownAction)
allTextFieldsInScreen[1].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
allTextFieldsInScreen[1].rightViewMode = .always
present(alertController!, animated: true, completion: nil)
   return
}
            
guard Validate.fullname((allTextFieldsInScreen[1].text)!).isRight else {
    self.currentTextField.rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    self.currentTextField.rightViewMode = .always
showAlert(with: "fullname can only include letters,numbers,dot,underline");return
}
            
let query = PFQuery.init(className: "_User")
query.whereKey("fullname", equalTo: allTextFieldsInScreen[1].text!)
query.findObjectsInBackground(block: { (objects, error) in
if error == nil{
    if objects!.count > 0{
        self.allTextFieldsInScreen[1].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
        self.allTextFieldsInScreen[1].rightViewMode = .always
self.showAlert(with: "fullname has been taken")
} else {
self.allTextFieldsInScreen[1].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
self.allTextFieldsInScreen[1].rightViewMode = .always}
}else {print(error!.localizedDescription)}
})
}
        
    if currentTextField.tag == 30{

guard allTextFieldsInScreen[2].text != "" else{
alertController = nil
alertController = UIAlertController.init(title: "Something wrong", message:  "password can't be nil", preferredStyle: .alert)
alertController?.addAction(knownAction)
allTextFieldsInScreen[2].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
allTextFieldsInScreen[2].rightViewMode = .always
present(alertController!, animated: true, completion: nil)
            return
}
        
guard Validate.password((allTextFieldsInScreen[2].text)!).isRight else {
    self.allTextFieldsInScreen[2].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    self.allTextFieldsInScreen[2].rightViewMode = .always
showAlert(with: "password can only include letters,numbers");return
    }
self.allTextFieldsInScreen[2].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
self.allTextFieldsInScreen[2].rightViewMode = .always
}
        
if currentTextField.tag == 40{
 
guard allTextFieldsInScreen[3].text != "" else{
        alertController = nil
        alertController = UIAlertController.init(title: "Something wrong", message:  "must repeat password", preferredStyle: .alert)
        alertController?.addAction(knownAction)
     allTextFieldsInScreen[3].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
  allTextFieldsInScreen[3].rightViewMode = .always
        present(alertController!, animated: true, completion: nil)
        return
    }
    
if allTextFieldsInScreen[3].text != allTextFieldsInScreen[2].text{
    self.allTextFieldsInScreen[3].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    self.allTextFieldsInScreen[3].rightViewMode = .always
    showAlert(with: "Twice inputs is not same")
}else {self.allTextFieldsInScreen[3].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
    self.allTextFieldsInScreen[3].rightViewMode = .always
    }
}
    
    if currentTextField.tag == 50{

guard allTextFieldsInScreen[4].text != "" else{
alertController = nil
alertController = UIAlertController.init(title: "Something wrong", message:  "email can't be nil", preferredStyle: .alert)
alertController?.addAction(knownAction)
allTextFieldsInScreen[4].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
allTextFieldsInScreen[4].rightViewMode = .always
present(alertController!, animated: true, completion: nil)
return
}
        
guard Validate.email((allTextFieldsInScreen[4].text)!).isRight else{
    self.allTextFieldsInScreen[4].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    self.allTextFieldsInScreen[4].rightViewMode = .always
showAlert(with: "email scheme must 4-7 words, and 2-3 letters after dot");return
}
            
let query = PFQuery.init(className: "_User")
query.whereKey("email", equalTo: allTextFieldsInScreen[4].text!)
query.findObjectsInBackground(block: { (objects, error) in
if error == nil{
if objects!.count > 0{
    self.allTextFieldsInScreen[4].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    self.allTextFieldsInScreen[4].rightViewMode = .always
self.showAlert(with: "email has been taken")
} else {
    self.allTextFieldsInScreen[4].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
    self.allTextFieldsInScreen[4].rightViewMode = .always}
}else {print(error!.localizedDescription)}
})
}
       
        if currentTextField.tag == 60{
guard allTextFieldsInScreen[5].text != "" else{
alertController = nil
alertController = UIAlertController.init(title: "Something wrong", message:  "URL can't be nil", preferredStyle: .alert)
    alertController?.addAction(knownAction)
allTextFieldsInScreen[5].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
allTextFieldsInScreen[5].rightViewMode = .always
present(alertController!, animated: true, completion: nil)
return
}
guard Validate.URL((allTextFieldsInScreen[5].text)!).isRight else{
    self.allTextFieldsInScreen[5].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
    self.allTextFieldsInScreen[5].rightViewMode = .always
showAlert(with: "URL format is www.xxxxx.xxx, and xxx must 2-3 letters");return
}
self.allTextFieldsInScreen[5].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
self.allTextFieldsInScreen[5].rightViewMode = .always
}
        
  if currentTextField.tag == 70{
    guard allTextFieldsInScreen[6].text != "" else{
        alertController = nil
        alertController = UIAlertController.init(title: "Something wrong", message:  "bio can't be nil", preferredStyle: .alert)
        alertController?.addAction(knownAction)
        allTextFieldsInScreen[6].rightView = UIImageView.init(image: #imageLiteral(resourceName: "wrong"))
        allTextFieldsInScreen[6].rightViewMode = .always
        present(alertController!, animated: true, completion: nil)
        return
    }
    
    self.allTextFieldsInScreen[6].rightView = UIImageView.init(image: #imageLiteral(resourceName: "right"))
    self.allTextFieldsInScreen[6].rightViewMode = .always
        }
    }
    
}

//UITextFieldDelegate
extension signUpVC{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
_ = allTextFieldsInScreen.map{ $0.resignFirstResponder()}
        
        return true
    }
}

//UIImagePickerControllerDelegate
extension signUpVC{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}

//UIScrollViewDelegate
extension signUpVC{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let verticalIndicator = (scrollView.subviews[(scrollView.subviews.count - 1)] as! UIImageView)
        verticalIndicator.backgroundColor = UIColor.orange
    }
    
}

