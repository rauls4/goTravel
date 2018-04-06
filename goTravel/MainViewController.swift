//
//  MainViewController.swift
//  goHome
//
//  Created by Raul Silva on 4/6/18.
//  Copyright © 2018 Silva. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
       Manager.shared.locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func goToWork(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mapIdentifier") as! MapViewController
        vc.destinationAddress = "222 Broadway, New York, NY 10038"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func goOnVacation(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mapIdentifier") as! MapViewController
        vc.destinationAddress = "Cancún, Quintana Roo, México"
        navigationController?.pushViewController(vc, animated: true)
    }
}
