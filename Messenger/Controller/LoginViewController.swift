//
//  LoginViewController.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitle(" ", for: .disabled)
        
        if UserDefaults.standard.string(forKey: DefaultsKeys.authToken) != nil {
            openChannels()
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        guard let email = emailField.text else { return }
        guard let password = passwordField.text else { return }
        
        if email.isEmpty { return }
        if password.isEmpty { return }
        
        emailField.endEditing(true)
        passwordField.endEditing(true)
        
        setControlsState(enabled: false)
        
        performLogin(email: email, password: password)
    }
    
    func performLogin(email: String, password: String) {
        Task {
            let api = LoginApi()
            do {
                let auth = try await api.login(email: email, password: password)
                if let token = auth.data.code {
                    UserDefaults.standard.setValue(token, forKey: DefaultsKeys.authToken)
                }
                if let id = auth.data.id {
                    UserDefaults.standard.setValue(id, forKey: DefaultsKeys.userId)
                }
                if let name = auth.data.name {
                    UserDefaults.standard.setValue(name, forKey: DefaultsKeys.userName)
                }
                if let avatar = auth.data.avatar {
                    UserDefaults.standard.setValue(avatar, forKey: DefaultsKeys.userAvatar)
                }
                if auth.data.code != nil {
                    UserDefaults.standard.setValue(email, forKey: DefaultsKeys.email)
                    UserDefaults.standard.setValue(password, forKey: DefaultsKeys.password)
                    openChannels()
                }
                
                setControlsState(enabled: true)
            } catch {
                print(error)
                setControlsState(enabled: true)
            }
        }
    }
    
    private func setControlsState(enabled: Bool) {
        self.emailField.isEnabled = enabled
        self.passwordField.isEnabled = enabled
        self.loginButton.isEnabled = enabled
        if enabled {
            self.activityIndicator.stopAnimating()
        } else {
            self.activityIndicator.startAnimating()
        }
    }
    
    private func openChannels() {
        if let vc = storyboard?.instantiateViewController(identifier: "NavigationViewController") {
            UIApplication.shared.windows.first!.rootViewController = vc
        }
    }
}
