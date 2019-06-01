//
//  ImageViewController.swift
//  Project30
//
//  Created by Michele Galvagno on 12/04/2019.
//  Copyright (c) 2019 Michele Galvagno. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
	weak var owner: SelectionViewController!
	var image: String?
	var animTimer: Timer?

	var imageView: UIImageView?

	override func loadView() {
		super.loadView()
		
		view.backgroundColor = UIColor.black

		// create an image view that fills the screen
		imageView = UIImageView()
        
        if let imageView = imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.alpha = 0
            
            view.addSubview(imageView)
            
            // make the image view fill the screen
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            // schedule an animation that does something vaguely interesting
            animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                // do something exciting with our image
                imageView.transform = CGAffineTransform.identity
                
                UIView.animate(withDuration: 3) {
                    imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }
        }
		
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let imageView = imageView else { return }

        if let image = image {
            title = image.replacingOccurrences(of: "-Large.jpg", with: "")
            
            if let path = Bundle.main.path(forResource: image, ofType: nil) {
                if let original = UIImage(contentsOfFile: path) {
                    let renderer = UIGraphicsImageRenderer(size: original.size)
                    
                    let rounded = renderer.image { ctx in
                        ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
                        ctx.cgContext.closePath()
                        
                        original.draw(at: CGPoint.zero)
                    }
                    
                    imageView.image = rounded
                }
            }
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        guard let imageView = imageView else { return }

		imageView.alpha = 0

		UIView.animate(withDuration: 3) {
            imageView.alpha = 1
		}
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let timer = animTimer else { return }
        
        timer.invalidate()
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let image = image else { return }
        
		let defaults = UserDefaults.standard
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey: image)

		// tell the parent view controller that it should refresh its table counters when we go back
		owner.dirty = true
	}
}
