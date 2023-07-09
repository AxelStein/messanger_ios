//
//  TestViewController.swift
//  Messenger
//
//  Created by Александр Шерий on 31.12.2022.
//

import UIKit

class TestViewController: UIViewController {
    
    override func viewDidLoad() {
        let itemView = ChatItemView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(itemView)
        
        itemView.setMessage()
    }
}
