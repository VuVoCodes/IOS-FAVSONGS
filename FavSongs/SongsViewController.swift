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
import Foundation
import SafariServices

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cellIconView: UIImageView!
    
}

class SongsViewController: UITableViewController{
    
    //INITIATED VARIABLES FOR LATER USES OF THE PROJECT
    var songDetailURL = ""
    var songs: [NSManagedObject] = []
    var inAppPic = UIImage(named: "Image")
    var data:Data? = nil
    var reachability: Reachability?
    
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.reachability = Reachability.init()
        tableView.tableFooterView = UIView()
        
        //VALIDATE THE INTERNET CONNECTIONS
        internetValidator()
        fetch()
        tableView.reloadData()
        
    }
    
    // TELL THE APP TO FETCH DATA FROM COREDATA
    func fetch(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedObjectcontext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        do{
            songs = try managedObjectcontext.fetch(fetchRequest) as! [NSManagedObject]
        }catch let error as NSError{
            print("Could not fetch. \(error)")
        }
    }
    
    // ADD NEW FILE INTO COREDATA AND SHOW IN TABLEVIEW
    func save(name:String,artist:String,year:String,imageURL:String,detailURL:String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let managedObjectcontext =  appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Song", in:
            managedObjectcontext) else {return}
        let song = NSManagedObject(entity: entity, insertInto: managedObjectcontext)
            song.setValue(name, forKey: "name")
            song.setValue(artist, forKey: "artist")
            song.setValue(year, forKey: "year")
            song.setValue(imageURL, forKey: "imageURL")
            song.setValue(detailURL, forKey: "detailURL")
        do{
            try managedObjectcontext.save()
            self.songs.append(song)
        }catch let error as NSError{
            print("Could not save. \(error)")
        }
    }
    
    // UPDATE THE SELECTED FILE  AND SAVE IT AGAIN INTO COREDATA, SHOW IN TABLEVIEW
    func update(name:String,artist:String,year:String,imageURL:String,detailURL:String,indexPath: IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let manageObjectcontext = appDelegate.persistentContainer.viewContext
        let song = songs[indexPath.row]
        song.setValue(name, forKey: "name")
        song.setValue(artist, forKey: "artist")
        song.setValue(year, forKey: "year")
        song.setValue(imageURL, forKey: "imageURL")
        song.setValue(detailURL, forKey: "detailURL")
        do{
            try manageObjectcontext.save()
            songs[indexPath.row] = song
        }catch let error as NSError{
            print("could not update. \(error)")
        }
    }
    
    // DELETE A SELECTED SONG IN THE COREDATA
    func delete(song:NSManagedObject, at indexPath: IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let manageObjectcontext = appDelegate.persistentContainer.viewContext
        manageObjectcontext.delete(song)
        do{
            try manageObjectcontext.save()
        }catch let error as NSError{
            print("can not delete. \(error)")
        }
        songs.remove(at: indexPath.row)
    }
    
    // TABLEVIEW SET UP(ROWS AND CELLS)
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    // SET CELL TO BE ABLE TO BE SWIPE TO VIEW SONG DETAIL
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let openSongSafari = UITableViewRowAction(style: .default, title: "Go to Detail") { (action, indexPath) in
            let song = self.songs[indexPath.row]
            //CHECK WHETHER THE URL CONTAINS HTTP:// OR HTTPS://
            let detailofSong:String = song.value(forKey: "detailURL") as! String
            if((detailofSong.lowercased().range(of: "http://") != nil) ||
                (detailofSong.lowercased().range(of: "https://") != nil)) {
                // CHECK THE URL SYNTAX TO VALIDATE THE URL IS MISSING SOMETHING OR NOT
                if(self.isStringLink(string: detailofSong) == true){
                    if let url = URL(string: "\(detailofSong.lowercased())") {
                        let safariVC = SFSafariViewController(url: url)
                        self.present(safariVC, animated: true, completion: nil)
                    }
                }
            }else{
                // ADD HTTP:// WHEN A LINK IS MISSING HTTP
                let nsongURL = "http://" + detailofSong
                if(self.isStringLink(string: nsongURL) == true){
                    if let url = URL(string: "\(nsongURL.lowercased())") {
                        let safariVC = SFSafariViewController(url: url)
                        self.present(safariVC, animated: true, completion: nil)
                    }
                }
            }
        }
        openSongSafari.backgroundColor = UIColor(red: 0/255, green: 230/255, blue: 240/255, alpha: 1.0)
        return [openSongSafari]
    }
    
    // SET ALL THE CELL TO HAVE ALL THE DATA FROM THE DATABASE(COREDATA)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell",for :indexPath) as! SongTableViewCell
        let song = songs[indexPath.row]
        
        //GET THE URL FROM THE imageURL FROM USER'S INPUT
        let url = URL(string: song.value(forKey: "imageURL") as! String)
        songDetailURL = song.value(forKey: "detailURL") as! String
        
        // CHECK THE CONNECTION OF THE DEVICE BEFORE LOADING ANY URL PICTURE TO PREVENT CRASHS
        if((self.reachability!.connection) != .none){ //USING AN IMPORTED LIBRARY FROM GITHUB(https://github.com/ashleymills/Reachability.swift)
            if(isStringLink(string: song.value(forKey: "imageURL") as! String) == true){ //USING FUNCTION CALLED isStringLink THAT I BUILD TO VALIDATE THE URL
                data = try? Data(contentsOf: url!)
                cell.cellIconView?.image = UIImage(data: data!)
            }else{
                cell.cellIconView?.image = inAppPic
            }
        }else{
            cell.cellIconView?.image = inAppPic
        }
        
        //SET CELL LABEL AND DETAIL LABEL TO SHOW SONG NAME AND ARTIST NAME
        cell.nameLabel?.text = song.value(forKey: "name") as? String
        cell.detailLabel?.text = song.value(forKey: "artist") as? String
        
        //SET THE ICON TO BE ABLE TO TAPPED BY THE USER (STILL ON FALSE)
        cell.cellIconView.isUserInteractionEnabled = false
        
        //SET THE CELL TO HAVE THE END SYMBLE
        cell.accessoryType = .disclosureIndicator
        //USING FUNCTION googleIT TO PROX SAFARI WITH URL LINK
        let googleIT = UITapGestureRecognizer(target: self, action: #selector(goSongDetail))
        cell.cellIconView.addGestureRecognizer(googleIT)
        return cell
    }
    
    // FUNCTION TO RUN SAFARI WHEN ICON IS TAPPED
    @objc func goSongDetail(){
        if((songDetailURL.lowercased().range(of: "http://") != nil) || (songDetailURL.lowercased().range(of: "https://") != nil)){
            if(isStringLink(string: songDetailURL) == true){
                if let url = URL(string: "\(songDetailURL.lowercased())") {
                    let safariVC = SFSafariViewController(url: url)
                    self.present(safariVC, animated: true, completion: nil)
                }
            }
        }else{
            self.songDetailURL = "http://" + songDetailURL
            if(isStringLink(string: songDetailURL) == true){
                if let url = URL(string: "\(songDetailURL.lowercased())") {
                    let safariVC = SFSafariViewController(url: url)
                    self.present(safariVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // INTERNET VALIDATION POP UP WHEN NO INTERNET ARE FOUND
    func createAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay i got it", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
    }
    
    // FUNCTION TO VALIDATE THE INTERNET
    func internetValidator(){
        if((self.reachability!.connection) == .none){
            let alert = UIAlertController(title: "No Internet Connection / Image Won't load", message: "Try to Connect to wifi ",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OKay i got it", style: .default) {action in})
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // FUNCTION THAT VALIDATE THE URL WHETHER IT'S VALID OR NOT
    func isStringLink(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && string.count > 0) else { return false }
        if detector!.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) > 0 {
            return true
        }
        let alert = UIAlertController(title: "Image Link Or Detail Link is not in correct format", message: "You can recheck your URL",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OKay i got it", style: .default) {action in})
        self.present(alert, animated: true, completion: nil)
        return false
    }
    
    
    // UNWIND SEGUE, PARSE INFORMATION FROM VIEW TO VIEW
    @IBAction func unwindToSongList(segue:UIStoryboardSegue){
        if let viewController = segue.source as? AddSongViewController{
            guard let name:String = viewController.snameTextField.text,
                let artist:String = viewController.sartistTextField.text,
                let year:String = viewController.syearTextField.text,
                let imageURL:String = viewController.simageurlTextField.text,
                let detailURL:String = viewController.sdetailTextField.text else{return}
            // PREVENT THE USER FROM INPUT NULL VALUES
            if(name != "" && artist != "" && year != "" && imageURL != "" && detailURL != ""){
                if let indexPath = viewController.indexPathforSong{
                        update(name: name, artist: artist, year: year, imageURL: imageURL, detailURL: detailURL, indexPath: indexPath)
                    }else{
                        save(name: name, artist: artist, year: year, imageURL: imageURL, detailURL: detailURL)
                    }
            }else{
                print("error missing files")
            }
                tableView.reloadData()
            }else if let viewController = segue.source as? SongDetailViewController{
                if(viewController.isDeleted){
                    guard let indexPath: IndexPath = viewController.indexPath else{return}
                    let song = songs[indexPath.row]
                    delete(song: song, at: indexPath)
                    tableView.reloadData()
                }
            }
    }
    
    // PREPARE FUNCTION FOR THE VIEWCONTROLLER'S INFORMATION(USER'S INPUT)
    override func prepare(for segue: UIStoryboardSegue,sender:Any?){
        if segue.identifier == "songDetailSegue"{
            guard let viewController = segue.destination as? SongDetailViewController else{return}
            guard let indexPath = tableView.indexPathForSelectedRow else{return}
            let songRecored = songs[indexPath.row]
            viewController.song = songRecored
            viewController.indexPath = indexPath
        }
    }
}
