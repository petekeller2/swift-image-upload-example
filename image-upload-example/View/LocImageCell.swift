//
//  LocImageCell.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/11/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import UIKit

class LocImageCell: UITableViewCell {

    @IBOutlet weak var locCellImage: UIImageView!
    @IBOutlet weak var locationDesc: UITextView!
    @IBOutlet weak var dateDesc: UITextView!
    
    func configureCell(locImage: LocImage) {
        
        let url = URL(string: locImage.image_path)
        let data = try? Data(contentsOf: url!)
        let cellImage: UIImage = UIImage(data: data!)!
                
        locCellImage.image = cellImage
        locationDesc.text = locImage.image_desc
        dateDesc.text = locImage.created
    }

}
