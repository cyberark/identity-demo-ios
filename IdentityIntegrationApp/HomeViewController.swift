//
//  HomeViewController.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 19/07/21.
//

import UIKit
import Identity
class HomeViewController: UIViewController {

    @IBOutlet weak var enroll_button: UIButton!
    @IBOutlet weak var QR_button: UIButton!
    @IBOutlet weak var logout_button: UIButton!
    @IBOutlet weak var refresh_button: UIButton!
    let builder = QRCodeReaderBuilder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        addLogoutObserver()
    }
}
extension HomeViewController {
    @IBAction func do_click(_ sender: Any) {
        navigate(button: sender as! UIButton)
    }
}
//MARK: Weblogin
extension HomeViewController {
    func navigate(button: UIButton) {
        if button == enroll_button {
        }  else if button == refresh_button {
            refreshToken()
        }else if button == logout_button {
            closeSession()
        }else {
            navigateToScanner()
        }
    }

    func navigateToLogin() {
        CyberArkAuthProvider.webAuth()?.set(presentingViewController: self)
            .setCustomParam(key: "", value: "")
            .build()
            .login(completion: { (result, error) in
                if((result) != nil) {
                    
                }
        })
    }
    func addObserver(){
        CyberArkAuthProvider.viewmodel()?.didReceiveRefreshToken = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    //self.dismiss(animated: true) {
                        self.showAlert(with :"Refresh Token: ", message: accessToken)
                   // }
                }
            }
        }
    }
  
    func refreshToken() {
        CyberArkAuthProvider.sendRefreshToken()
    }
    func navigateToScanner() {
        builder.authenticateQrCode(presenter: self)
    }
}
extension HomeViewController {}
extension HomeViewController {
    func closeSession() {
        CyberArkAuthProvider.webAuth()?.set(presentingViewController: self)
            .setCustomParam(key: "", value: "")
            .build()
            .closeSession(completion: { (result, error) in
                if((result) != nil) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
    }
    func addLogoutObserver(){
        CyberArkAuthProvider.viewmodel()?.didLoggedOut = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
