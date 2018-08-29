/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Assignment 1
 Author: Vo Quoc Vu
 ID: s3575819
 Created date: 14/08/2018
 Acknowledgement: Hacking with Swift, Ray Wenderlich, StackOverflow, Apple Document, Github, Stanford cs193p youtube lecture, Ashley Mills
 */

import UIKit
import CoreData

class AddSongViewController: UIViewController {

    // INITIATED VARIABLES FOR USAGES WHEN ADDING SONG TO DATABASE WITH INDEXPATH
    var titleText = "Add Songs"
    var song: NSManagedObject? = nil
    var indexPathforSong: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        if let song = self.song{
            // SET THE TEXT FIELDS TO MATCH WITH THE FIELD NAME FROM CORE DATA
            snameTextField.text = song.value(forKey: "name") as? String
            sartistTextField.text = song.value(forKey: "artist") as? String
            syearTextField.text = song.value(forKey: "year") as? String
            simageurlTextField.text = song.value(forKey: "imageURL") as? String
            sdetailTextField.text = song.value(forKey: "detailURL") as? String
        }
    }
    
    // ALERTCONTROLLER POPS UP WHEN A MISSING INPUT FROM THE USER WAS FOUND
    func createAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
    }
    
    // NAME OF THE TEXT FIELD IN THE VIEW CONTROLLER
    @IBOutlet weak var snameTextField: UITextField!
    @IBOutlet weak var sartistTextField: UITextField!
    @IBOutlet weak var syearTextField: UITextField!
    @IBOutlet weak var simageurlTextField: UITextField!
    @IBOutlet weak var sdetailTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    // ACTIONS BUTTONS WHEN THE USERS SAVE OR CANCEL THE OPERATION
    @IBAction func saveAndClose(_ sender: Any) {
        // VALIDATE WHETHER THE USERS INPUT NULL OR NOT
        if(snameTextField.text?.isEmpty)! || (sartistTextField.text?.isEmpty)! ||  (syearTextField.text?.isEmpty)! || (simageurlTextField.text?.isEmpty)! || (sdetailTextField.text?.isEmpty)!{
            let alert = UIAlertController(title: "Are u missing something ?", message: "Pls retry",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OKay", style: .default) {action in})
            self.present(alert, animated: true, completion: nil)
        
        }
        else{
            // VALIDATE WHETHER THE YEAR FIELD IS INT OR NOT
            if(yearIsInt(string: syearTextField.text!) == false){
                let alert = UIAlertController(title: "Year must be NUMBER!", message: "Pls retry",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OKay", style: .default) {action in})
                self.present(alert, animated: true, completion: nil)
            }else{
                // A YEAR MUST HAVE 4 DIGIT
                if(syearTextField.text!.count == 4){
                    performSegue(withIdentifier: "unwindToSongList", sender: self)
                }else{
                    let alert = UIAlertController(title: "Year must have 4 digit", message: "Pls retry",preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OKay", style: .default) {action in})
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    // CANCEL THE ADDING VIEW
    @IBAction func cancelAndClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // A FUNCTION CREATED TO VALIDATE THE YEAR
    func yearIsInt(string: String) -> Bool {
        return Int(string) != nil
    }
}
