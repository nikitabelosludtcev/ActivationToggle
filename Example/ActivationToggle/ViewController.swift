//
//  ViewController.swift
//  ActivationToggle
//
//  Created by Nikta Belosludtcev on 06/08/2018.
//  Copyright (c) 2018 Nikta Belosludtcev. All rights reserved.
//

import UIKit
import ActivationToggle

class ViewController: UIViewController {
    
    @IBOutlet weak var exampleStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default activation toggle (with value change handling)
        let defaultToggleLabel = UILabel()
        defaultToggleLabel.text = "Initialized from the code:"
        exampleStackView.addArrangedSubview(defaultToggleLabel)
        
        let defaultToggle = ActivationToggle()
        defaultToggle.translatesAutoresizingMaskIntoConstraints = false
        defaultToggle.widthAnchor.constraint(equalToConstant: ActivationToggle.DefaultSize.width).isActive = true
        defaultToggle.heightAnchor.constraint(equalToConstant: ActivationToggle.DefaultSize.height).isActive = true
        exampleStackView.addArrangedSubview(defaultToggle)
        
        // Value change handling
        defaultToggle.addTarget(self, action: #selector(valueChanged(control:)), for: .valueChanged)
        
        // Shadow
        let shadowToggleLabel = UILabel()
        shadowToggleLabel.text = "Shadow disabled:"
        exampleStackView.addArrangedSubview(shadowToggleLabel)
        
        let shadowToggle = ActivationToggle()
        shadowToggle.isShowToggleShadow = false
        shadowToggle.translatesAutoresizingMaskIntoConstraints = false
        shadowToggle.widthAnchor.constraint(equalToConstant: ActivationToggle.DefaultSize.width).isActive = true
        shadowToggle.heightAnchor.constraint(equalToConstant: ActivationToggle.DefaultSize.height).isActive = true
        exampleStackView.addArrangedSubview(shadowToggle)
        
        // Customized activation toggle
        let customizedToggleLabel = UILabel()
        customizedToggleLabel.text = "Custom container and toggle colors:"
        exampleStackView.addArrangedSubview(customizedToggleLabel)
        
        let customizedToggle = ActivationToggle()
        customizedToggle.onColor = UIColor.purple
        customizedToggle.offColor = UIColor.darkGray
        customizedToggle.toggleColor = UIColor.green
        customizedToggle.translatesAutoresizingMaskIntoConstraints = false
        customizedToggle.widthAnchor.constraint(equalToConstant: ActivationToggle.DefaultSize.width).isActive = true
        customizedToggle.heightAnchor.constraint(equalToConstant: ActivationToggle.DefaultSize.height).isActive = true
        exampleStackView.addArrangedSubview(customizedToggle)
        
        // Custom size
        let customSizeToggleLabel = UILabel()
        customSizeToggleLabel.text = "Custom size:"
        exampleStackView.addArrangedSubview(customSizeToggleLabel)
        
        let customSizeToggle = ActivationToggle()
        customSizeToggle.offColor = UIColor.darkGray
        customSizeToggle.translatesAutoresizingMaskIntoConstraints = false
        customSizeToggle.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        customSizeToggle.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        exampleStackView.addArrangedSubview(customSizeToggle)
    }
    
    @objc
    func valueChanged(control: UIControl) {
        if let toggle = control as? ActivationToggle {
            print(toggle.isOn)
        }
    }
}
