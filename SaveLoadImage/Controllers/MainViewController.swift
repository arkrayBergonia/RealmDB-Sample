//
//  ViewController.swift
//  SaveLoadImage
//
//  Created by Francis Jemuel Bergonia on 1/2/20.
//  Copyright © 2020 Arkray PHM. All rights reserved.
//

import UIKit
import RealmSwift

enum StorageType {
    case userDefaults
    case fileSystem
    case realmSwift
}

class MainViewController: UIViewController {

    @IBOutlet weak var storageSegmentControl: UISegmentedControl!
    @IBOutlet weak var imageToSave: UIImageView!
    @IBOutlet weak var imageToLoad: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var loadBtn: UIButton!
    
    let realm = try! Realm()
    
    var chosenStorageType: StorageType = StorageType.realmSwift
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.imageToLoad.isHidden = !(self.retrieveImage(forKey: "keyImage", inStorageType: chosenStorageType) != nil)
        
        if (self.retrieveImage(forKey: "keyImage", inStorageType: chosenStorageType) != nil) {
            self.imageToLoad.image = self.retrieveImage(forKey: "keyImage", inStorageType: chosenStorageType)
        }
    }
    
    
    @IBAction func dataSegmentControlsTapped(_ sender: UISegmentedControl) {
        switch self.storageSegmentControl.selectedSegmentIndex {
        case 0:
            self.chosenStorageType = StorageType.userDefaults
        case 1:
            self.chosenStorageType = StorageType.fileSystem
        case 2:
            self.chosenStorageType = StorageType.realmSwift
        default:
            break
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.selectFromGallery()
    }
    
    @IBAction func loadBtnTapped(_ sender: Any) {
        self.imageToLoad.isHidden = false
        self.imageToLoad.image = self.retrieveImage(forKey: "keyImage", inStorageType: chosenStorageType)
    }
    
    func checkNoteImageDataIsAvailable(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func selectFromGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // PhotoLibrary Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError("Expected a dictionary containing an image, but was provided the following: \(info)") }
        self.imageToSave.isHidden = false;
        self.imageToSave.image = selectedImage
        self.store(image: selectedImage, forKey: "keyImage", withStorageType: StorageType.fileSystem)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MainViewController {
    
    private func store(image: UIImage,
                       forKey key: String,
                       withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                if let filePath = filePath(forKey: key) {
                    do  {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation,
                                          forKey: key)
            case .realmSwift:
                print("RealmSwift ************ SAVING")
                let imageData = image.jpegData(compressionQuality: 0.5)
                let memo = MemoData()
                memo.memoText = "memoPlus XD"
                memo.memoImage = imageData
                
                do {
                    try realm.write {
                        realm.add(memo)
                    }
                } catch {
                    print("Error saving category \(error)")
                }
            }
        }
    }
   
    private func retrieveImage(forKey key: String,
                               inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                return image
            }
        case .userDefaults:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        case .realmSwift:
            print("RealmSwift ************ LOAD / RETRIEVE")
            let memoDataResult = realm.objects(MemoData.self)
            
            if memoDataResult.count > 0 {
                if let firstData = memoDataResult.first {
                    if let imageData = firstData.memoImage as? Data {
                        let image = UIImage(data: imageData)
                        return image
                    }
                }
            }
        }
        
        return nil
    }
    
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    

}
