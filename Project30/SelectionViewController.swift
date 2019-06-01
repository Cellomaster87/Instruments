//
//  SelectionViewController.swift
//  Project30
//
//  Created by Michele Galvagno on 12/04/2019.
//  Copyright (c) 2019 Michele Galvagno. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]()
    var savedImages = [String]()
    var imageNames = [String]()
    
    var images = [UIImage]()
	
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
		let fm = FileManager.default
        
        // Challenge 3 without the bonus
        if savedImages.isEmpty {
            print("No image found. Proceeding with image creation and rendering.")
            if let path = Bundle.main.resourcePath {
                if let tempItems = try? fm.contentsOfDirectory(atPath: path) {
                    for item in tempItems {
                        if item.range(of: "Large") != nil {
                            items.append(item)
                            
                            let currentImage = item
                            let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
                            
                            if let path = Bundle.main.path(forResource: imageRootName, ofType: nil) {
                                let original = UIImage(contentsOfFile: path)
                                
                                let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
                                let renderer = UIGraphicsImageRenderer(size: renderRect.size)
                                
                                let rounded = renderer.image { ctx in
                                    ctx.cgContext.addEllipse(in: renderRect)
                                    ctx.cgContext.clip()
                                    
                                    original?.draw(in: renderRect)
                                }
                                
                                images.append(rounded)
                                
                                // save compressed version to disk
                                let imageName = UUID().uuidString
                                let documentsDirectory = getDocumentsDirectory().appendingPathComponent(imageName)
                                
                                if let compressedImage = rounded.jpegData(compressionQuality: 0.8) {
                                    try? compressedImage.write(to: documentsDirectory)
                                    savedImages.append(documentsDirectory.path)
                                    imageNames.append(imageName)
                                }
                            }
                        }
                    }
                    print("Images rendered and saved")
                }
            }
        } else {
            // extract the images from disk and load them into the images array as we want to load UIImages, not strings.
            print("Images found. Loading from disk now...")
            images.removeAll(keepingCapacity: true) // in case something remained from a previous session.
            
            for imageName in imageNames {
                let imagePath = getDocumentsDirectory().appendingPathComponent(imageName).path
                
                if fm.fileExists(atPath: imagePath) {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        images.append(image)
                    } else {
                        print("Image not found at \(imagePath)")
                    }
                }
            }
            print("Loading complete. Enjoy!")
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			tableView.reloadData()
		}
	}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }

    // MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let currentImage = items[indexPath.row % items.count]
        let rounded = images[indexPath.row % images.count]
        
        cell.imageView?.image = rounded
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 90, height: 90))).cgPath
  
		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		navigationController!.pushViewController(vc, animated: true)
	}
}
