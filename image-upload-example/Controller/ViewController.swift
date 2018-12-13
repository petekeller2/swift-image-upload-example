//
//  ViewController.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/7/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import UIKit
import Material
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD
import CoreLocation
import Alamofire
import Toast_Swift
import IJProgressView

class ViewController: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fabButton: FABButton!
    
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor() // Not used
    
    var locImage: LocImage!
    var locImages = [LocImage]()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        prepareFABButton()
        
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
//        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        fabButton.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    func locationAuthStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            
            IJProgressView.shared.showProgressView()

            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            
            // this takes a while
            CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    IJProgressView.shared.hideProgressView()
                    return
                }
                
                if placemarks!.count > 0 {
                    Location.sharedInstance.address = Location.formatAddress(pm: placemarks![0])
                    IJProgressView.shared.hideProgressView()
                }
                else {
                    IJProgressView.shared.hideProgressView()
                    print("Problem with the data received from geocoder")
                }
            })
            
            self.downloadImageData {
                
            }
            
            return true;
        } else if status == .denied || status == .restricted {
            self.view.makeToast("You must allow this app to access your location!")
            
            return false;
        } else {

            locationManager.requestWhenInUseAuthorization()
            
            return false;
        }
    }
    
    @objc func buttonTouched(_ button: UIButton) {
        
        if (locationAuthStatus()) {
            gallery = GalleryController()
            gallery.delegate = self
        
            present(gallery, animated: true, completion: nil)
        }
    }
    
    // MARK: - LightboxControllerDismissalDelegate
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    // MARK: - GalleryControllerDelegate
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    // not used
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        
        self.view.makeToast("No videos or live images allowed")
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    let controller = AVPlayerViewController()
                    controller.player = AVPlayer(url: tempPath)
                    
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        // Save images to server and update table view @@@
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            for image in resolvedImages {
                let requestObj = RequestFactory().create(type: Constants.defaultRequestImp, url: Constants.url + Constants.newImage, requestData: ["location_desc": Location.sharedInstance.address, "image_desc": Location.sharedInstance.address, "lat": String(Location.sharedInstance.latitude), "lon": String(Location.sharedInstance.longitude)])
                self!.imageUpload(imageName: "location_image", image: image!, requestObj: requestObj)
            }
        })
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
    // MARK: - Helper
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        
        gallery.present(lightbox, animated: true, completion: nil)
    }
    
    // TODO: make this a static func in LocImage or a static class
    func imageUpload(imageName: String, image: UIImage, requestObj: RequestProtocol) {
        IJProgressView.shared.showProgressView()

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in requestObj.requestData {
                    multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
                
                let now = Date()
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyyMMddHHmm"
                let dateString = formatter.string(from: now)
                
                let imgData = image.jpegData(compressionQuality: 1.0)
                multipartFormData.append(imgData!, withName: "image_file", fileName: imageName + "_" + dateString + String(Int.random(in: 100000 ... 999999)) + "_" + ".jpg", mimeType: "image/jpg")
        }, to: requestObj.url){ (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseData { response in
//                        print(response.request)  // original URL request
//                        print(response.response) // URL response
//                        print(response.data)     // server data
//                        print(response.result)   // result of response serialization
                        self.downloadImageData {
                            IJProgressView.shared.hideProgressView()
                        }
                    
                }
                
            case .failure(let encodingError):
                IJProgressView.shared.hideProgressView()
                print("ERROR")
                print(encodingError)
            }
            
        }
    }
    
    // TODO: make this a static func in LocImage or a static class
    func downloadImageData(completed: @escaping DownloadComplete) {
        IJProgressView.shared.showProgressView()

        let url = Constants.url + Constants.closeImages + "?lat=" + String(Location.sharedInstance.latitude) + "&lon=" + String(Location.sharedInstance.longitude)
        Alamofire.request(url).responseJSON { response in
            
            // check for errors
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on " + url)
                print(response.result.error!)
                IJProgressView.shared.hideProgressView()
                return
            }
            
            // make sure we got some JSON since that's what we expect
            guard let json = response.result.value as? [Dictionary<String, AnyObject>] else {
                print("didn't get JSON from API")
                if let error = response.result.error {
                    print("Error: \(error)")
                }
                IJProgressView.shared.hideProgressView()
                return
            }

            self.locImages = [LocImage]()
            for obj in json {
                let locImage = LocImage(imageDict: obj)
                self.locImages.append(locImage)
            }
            self.tableView.reloadData()
            IJProgressView.shared.hideProgressView()

            completed()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "locImageCell", for: indexPath) as? LocImageCell {
            
            let locImage = locImages[indexPath.row]
            cell.configureCell(locImage: locImage)
            return cell
        } else {
            return LocImageCell()
        }
    }

}

extension ViewController {
    fileprivate func prepareFABButton() {
        fabButton.image = Icon.cm.add
        fabButton.tintColor = .white
        fabButton.pulseColor = .white
        fabButton.backgroundColor = Color.red.base
    }

}

