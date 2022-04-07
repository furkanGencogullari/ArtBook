//
//  DetailsViewController.swift
//  ArtBook
//
//  Created by Furkan Gençoğulları on 7.04.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    var chosenArt = ""
    var chosenArtId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = true
        
        //Getting Info
        if chosenArt != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let idString = chosenArtId?.uuidString
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                            if let artist = result.value(forKey: "artist") as? String {
                                artistTextField.text = artist
                                if let year = result.value(forKey: "year") as? Int {
                                    yearTextField.text = String(year)
                                    if let imageData = result.value(forKey: "image") as? Data {
                                        let image = UIImage(data: imageData)
                                        imageView.image = image
                                        imageView.contentMode = .scaleAspectFit
                                        imageView.isUserInteractionEnabled = false
                                        nameTextField.isUserInteractionEnabled = false
                                        artistTextField.isUserInteractionEnabled = false
                                        yearTextField.isUserInteractionEnabled = false
                                    }
                                    
                                }
                                    
                            }
                        }
                    }
                    
                }
                
            } catch {
                print("error")
                
            }
            
            
        } else {
            imageView.isUserInteractionEnabled = true
        }
        
        
        
        //Recognizers
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(viewTapGesture)
        
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePressed))
        imageView.addGestureRecognizer(imageTapGesture)
        
        
        

    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        
        newArt.setValue(nameTextField.text, forKey: "name")
        newArt.setValue(artistTextField.text, forKey: "artist")
        
        if let year = Int(yearTextField.text!) {
            newArt.setValue(year, forKey: "year")
        }
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey: "image")
        
        newArt.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
        } catch {
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    @objc func imagePressed () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        imageView.contentMode = .scaleAspectFit
        dismiss(animated: true)
        saveButton.isHidden = false
    }
    
}
