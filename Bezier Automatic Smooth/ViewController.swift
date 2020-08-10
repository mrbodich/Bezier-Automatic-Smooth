//
//  ViewController.swift
//  Bezier Automatic Smooth
//
//  Created by bodich on 5/20/19.
//  Copyright © 2019 bodich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    var card: CardView?
    
    @IBOutlet weak var centerView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        
        card = CardView(frame: CGRect(origin: CGPoint.zero, size: centerView.frame.size))
        
        centerView.addSubview(card!)
        
    }
    
    override func viewDidLayoutSubviews() {
        card?.frame.size = centerView.frame.size
    }

}

