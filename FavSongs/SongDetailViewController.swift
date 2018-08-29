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
import SafariServices

class SongDetailViewController: UIViewController {
    
    // INITIATED VARIABLE FOR USAGE
    var song: NSManagedObject? = nil
    var detailURLDetail:String = ""
    var imageURLDetail:String = ""
    var isDeleted:Bool = false
    var indexPath: IndexPath? = nil
    var inAppPic = UIImage(named: "Image")
    var data:Data? = nil
    var reachability: Reachability?


    override func viewDidLoad() {
        super.viewDidLoad()
        sName.text = song?.value(forKey: "name") as? String
        sArtist.text = song?.value(forKey: "artist") as? String
        sYear.text = song?.value(forKey: "year") as? String
        detailURLDetail = (song?.value(forKey: "detailURL"))! as! String
        
        // INITIATE THE FUNCTION TO VALIDATE WHETHER THE DEVICE IS CONNECTED TO THE INTERNET OR NOT
        self.reachability = Reachability.init()
        
        // CHECK WHETER THE URL IS A URL OR NOT
        imageURLDetail = (song?.value(forKey: "imageURL"))! as! String
        let url = URL(string: imageURLDetail)
        
        // VALIDATE THE INTERNET CONNECTION BEFORE LOAD THE IMAGE FROM imageURL
        if((self.reachability!.connection) != .none){
            if(isStringLink(string: imageURLDetail) == true){
                data = try? Data(contentsOf: url!)
                SimageLoader.image = UIImage(data: data!)
            }else{
                SimageLoader.image = inAppPic
            }
        }else{
            SimageLoader.image = inAppPic
        }
        
        // ENABLE THE IMAGE TO BE ABLE TO BE TAPPED BY THE USER
        SimageLoader.isUserInteractionEnabled = true
        let googleIT = UITapGestureRecognizer(target: self, action: #selector(self.goSongDetail))
        SimageLoader.addGestureRecognizer(googleIT)
    }

    // FUNC isStringLink IS CREATED TO VALIDATE THE URL WHETHER IT IS A URL OR NOT AND RETURN TRUE OR FALSE
    func isStringLink(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && string.count > 0) else { return false }
        if detector!.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) > 0 {
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //VIEW LABEL AND BUTTONS
    @IBOutlet weak var sName: UILabel!
    @IBOutlet weak var sArtist: UILabel!
    @IBOutlet weak var sYear: UILabel!
    @IBAction func DetailURLAccess(_ sender: AnyObject) {
       print(detailURLDetail)
        goSongDetail();
    }
    @IBOutlet weak var SimageLoader: UIImageView!
    // BACK BUTTON IS USED TO GO BACK TO SONGVIEWCONTROLLER WITH SEGUE
    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "unwindtoSongList", sender: self)
    }
    // BACK BUTTON IS USED TO GO BACK TO SONGVIEWCONTROLLER WITH SEGUE
    @IBAction func DeleteSong(_ sender: Any) {
        isDeleted = true
        performSegue(withIdentifier: "unwindtoSongList", sender: self)
    }
    
    // FUNCTION BUILD TO SEARCH DETAIL OF SONG THROUGH URL
    @objc func goSongDetail(){
        if((detailURLDetail.lowercased().range(of: "http://") != nil) || (detailURLDetail.lowercased().range(of: "https://") != nil)){
            if(isStringLink(string: detailURLDetail) == true){
                    if let url = URL(string: "\(detailURLDetail.lowercased())") {
                    let safariVC = SFSafariViewController(url: url)
                    self.present(safariVC, animated: true, completion: nil)
                }
            }
        }else{
            self.detailURLDetail = "http://" + detailURLDetail
            if(isStringLink(string: detailURLDetail) == true){
                    if let url = URL(string: "\(detailURLDetail.lowercased())") {
                    let safariVC = SFSafariViewController(url: url)
                    self.present(safariVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // PREPARE FUNCTION, FOR THE INFORMATION THAT THE USER INTERACT.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "editSong"{
            guard let viewController = segue.destination as? AddSongViewController else{return}
            viewController.titleText = "Edit Song"
            viewController.song = song
            viewController.indexPathforSong = self.indexPath!
        }
    }
}
