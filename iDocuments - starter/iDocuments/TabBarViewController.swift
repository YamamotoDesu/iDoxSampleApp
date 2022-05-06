//
//  ViewController.swift
//  iDocuments
//
//  Created by Martina on 08/04/22.
//


import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    let layer = CAShapeLayer()
    var layerHeight = CGFloat()
    var middleButton: UIButton = {
        let b = UIButton()
        let c = UIImage.SymbolConfiguration(pointSize: 15, weight: .heavy, scale: .large)
        b.setImage(UIImage(systemName: "plus", withConfiguration: c), for: .normal)
        b.imageView?.tintColor = .white
        b.backgroundColor = UIColor(named: "iDoxViewColor")
        return b
    }()
    
    let bgColor = UIColor(named: "iDoxLightColor")
    let sColor = UIColor(named: "iDoxAccentColor")
    let tColor = UIColor(named: "iDoxShadowColor")
    
    var buttonTapped = false
    
    var index = Int()
    var optionButtons: [UIButton] = []
    var options = [
       option(name: "A", image: UIImage(systemName: "a") ?? UIImage(), segue: "a"),
       option(name: "B", image: UIImage(systemName: "a") ?? UIImage(), segue: "b"),
       option(name: "C", image: UIImage(systemName: "a") ?? UIImage(), segue: "c")
    ]
    struct option {
       var name = String()
       var image = UIImage()
       var segue = String()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTabBar()
    }
    
    func setUpTabBar() {
        
        // tab bar layer
        let x: CGFloat = 10
        let y: CGFloat = 20
        let width = self.tabBar.bounds.width - x * 2
        let height = self.tabBar.bounds.height + y * 1.5
        layerHeight = height
        layer.fillColor = bgColor?.cgColor
        layer.path = UIBezierPath(roundedRect: CGRect(x: x,
                                                      y: self.tabBar.bounds.minY - y,
                                                      width: width,
                                                      height: height),
                                  cornerRadius: height / 2).cgPath
        
        // tab bar shadow
        layer.shadowColor = tColor?.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        
        // add tab bar layer
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        // fix items positioning
        self.tabBar.itemWidth = width / 6
        self.tabBar.itemPositioning = .centered
        self.tabBar.unselectedItemTintColor = sColor
        
        // add middle button
        addMiddleButton()
        
    }
    
    private func addMiddleButton() {
        
        // DISABLE TABBAR ITEM - behind the "+" custom button:
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                 items[1].isEnabled = false
            }
        }
        
        // add middle button
        tabBar.addSubview(middleButton)
        let size = CGFloat(50)
        let constant: CGFloat = -20 + ( layerHeight / 2 ) - 5
        // set constraints
        let constraints = [
           middleButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
           middleButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: constant),
           middleButton.heightAnchor.constraint(equalToConstant: size),
           middleButton.widthAnchor.constraint(equalToConstant: size)
        ]
        for constraint in constraints {
           constraint.isActive = true
        }
        middleButton.layer.cornerRadius = size / 2
        // shadow
        middleButton.layer.shadowColor = tColor?.cgColor
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        middleButton.layer.shadowOpacity = 0.75
        middleButton.layer.shadowRadius = 13
        // other
        middleButton.layer.masksToBounds = false
        middleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // action
        middleButton.addTarget(self, action: #selector(buttonHandler(sender:)), for: .touchUpInside)
    }
    
    @objc func buttonHandler(sender: UIButton) {
        
        let buttonBGColor = UIColor(named: "iDoxViewColor")
        self.setUpButtons(count: self.options.count, center: self.middleButton, radius: 80)
        if buttonTapped == false {
            
            UIView.animate(withDuration: 0.3, animations: ({
                
                // rotate the button
                self.middleButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4 )
                
                // change appearance
                self.middleButton.backgroundColor = .white
                self.middleButton.imageView?.tintColor = buttonBGColor
                
                self.middleButton.layer.borderWidth = 5
                self.middleButton.layer.borderColor = buttonBGColor?.cgColor
                
                // button is on selected mode
                self.buttonTapped = true
                
                // perform an action
                // self.setUpButtons(count: self.options.count, center: self.middleButton, radius: 80)
                
            }))
            
            
        } else {
            
            UIView.animate(withDuration: 0.15, animations: ({
                
                // rotate the button back
                self.middleButton.transform = CGAffineTransform(rotationAngle: 0)
                
                // change appearance
                self.middleButton.backgroundColor = buttonBGColor
                self.middleButton.layer.borderWidth = 0
                self.middleButton.imageView?.tintColor = .white
                
                // button is no longer on selected mode
                self.buttonTapped = false
                
                // perform an action
                self.removeButtons()
                
            }))
        }
    }
    
    func setUpButtons(count: Int, center: UIView, radius: CGFloat) {
        
        // set buttons distance using degrees
        let degrees = 135 / CGFloat(count)
        
        // create background to avoid other interactions
        let background = createBackground()
        background.addTarget(self, action: #selector(backgroundPressed(sender:)), for: .touchUpInside)
        background.addTarget(self, action: #selector(backgroundPressed(sender:)), for: .touchDragInside)
        self.optionButtons.append(background)
        
        // set middle button to be in front
        tabBar.bringSubviewToFront(middleButton)
        
        // create three buttons
        for i in 0 ..< count {
            
            // set index to assign action
            self.index = i
            
            // create and set the buttons
            let button = createButton(size: 44)
            self.optionButtons.append(button)
            self.view.addSubview(button)
            button.imageView?.isHidden = false
            
            // set constraints using trigonometry
            let x = cos(degrees * CGFloat(i+1) * .pi/180) * radius
            let y = sin(degrees * CGFloat(i+1) * .pi/180) * radius
            button.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor, constant: -x).isActive = true
            button.centerYAnchor.constraint(equalTo: center.centerYAnchor, constant: -y).isActive = true
            
            // final setup
            button.setImage(options[i].image, for: .normal)
            self.view.bringSubviewToFront(button)
            button.addTarget(self, action: #selector(optionHandler(sender:)), for: .touchUpInside)
        }
    }
    
    func createButton(size: CGFloat) -> UIButton {
        
        // button's appearance
        let buttonBGColor = UIColor(named: "iDoxViewColor")
        let button = UIButton(type: .custom)
        button.backgroundColor = buttonBGColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // button's constraints
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        button.layer.cornerRadius = size / 2
        
        // double check that the button is tapped
        if buttonTapped == true {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations:  {
                button.imageView?.tintColor = .clear
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                button.imageView?.tintColor = .white
                button.transform = CGAffineTransform(scaleX: 1, y: 1) })
            
        }
        
        // return button
        return button
        
    }
    
    
    @objc func optionHandler(sender: UIButton) {
        
        switch index {
            
        case 0: print("Button 1 was pressed.")
        case 1: print("Button 2 was pressed.")
        default: print("Button 3 was pressed.")
            
        }
    }
    
    func createBackground() -> UIButton {
        
        // background button to deselect middle button
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.titleLabel?.text = ""
        view.addSubview(button)
        
        // button's constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        // return button
        return button
        
    }

    
    @objc func backgroundPressed(sender: UIButton) {
        if buttonTapped == true {
            middleButton.sendActions(for: .touchUpInside)
        } else {
            sender.isUserInteractionEnabled = false
            sender.removeFromSuperview()
        }
        
    }
    
    func removeButtons() {
        
        for button in self.optionButtons {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                button.transform = CGAffineTransform(scaleX: 1.15, y: 1.1)
            }, completion: { _ in
                button.alpha = 0
                if button.alpha == 0 {
                    button.removeFromSuperview()
                }
            })
        }
    }
}
