//
//  ViewController.swift
//  rider
//
//  Created by Aniket Patil on 15/09/17.
//  Copyright © 2017 aniketpatil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    
    //    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var rider: UILabel!
    @IBOutlet weak var driver: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    
    var signUpMode = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func topTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "You must need to give email and password")
        } else {
            if let email = emailTextField.text {
                if let password = passwordTextField.text{
                    if signUpMode {
                        //SIGNUP
                        
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else {
                                //we need to check weather rider or driver
                                if self.riderDriverSwitch.isOn {
                                    //DRIVER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                }else{
                                    //RIDER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                        })
                    }else{
                        //LOG IN
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                if user?.displayName == "Driver"{
                                    //DRIVER
                                    print("Driver")
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                }else {
                                    //RIDER
                                    //print("Log In Success ")
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                            
                        })
                        
                    }
                }
            }
        }
    }
    func displayAlert(title: String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func bottomTap(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign UP ", for: .normal)
            rider.isHidden = true
            driver.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        }else{
            topButton.setTitle("Sign Up ", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            rider.isHidden = false
            driver.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
        
    }
    
    
}

