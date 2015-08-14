import UIKit
import CoreData

class sectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var appsTableView : UITableView!
    @IBOutlet var options : UIView!
    
    var section_names = [String]()
    var section_ids = [String]()
    var username:String = ""
    var password:String = ""
    var refId:String  = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var access_token:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let b = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: Selector("logout"))
        self.navigationItem.rightBarButtonItem = b
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.hidesBackButton = true
        getInfoFromCore()
        getSIF()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getInfoFromCore() {        //this function allows you to go back from any page and make requests with stored data
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
           self.username = fetchResults[i].username
           self.password = fetchResults[i].password
        }
    }
    
    
    func getSections(access_token:String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ec2-54-144-153-235.compute-1.amazonaws.com/v2/staffPersons/\(self.refId)/rosters")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        request.addValue("\(access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            print(response)
            print("How about here?")
            let json = try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            let rosters = json["rosters"] as! Dictionary<String, AnyObject>
            let roster = rosters["roster"] as! NSArray
            for (var i=0; i<roster.count; i++) {
                self.section_ids.append(roster[i]["@ref_id"] as! String)
                self.section_names.append(roster[i]["courseTitle"] as! String)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.appsTableView!.reloadData()
            })
        })
        
        task!.resume()
    }
    
    
    let MenuSegueIdentifier = "studentSegue"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            self.storeCurrentUser()
            let navController = segue.destinationViewController as! UINavigationController
            let destination = navController.topViewController as! ViewController
            if let nameIndex = self.appsTableView.indexPathForSelectedRow?.row {
                destination.section_id = self.section_ids[nameIndex]
                destination.username = self.username
                destination.password = self.password
            }
        }
    }
    
    func storeCurrentUser() { //stores the current user information, so common information does not need to continually
        // be passed")
        let fetchRequest = NSFetchRequest(entityName: "CurrentUser")
        let fetchResults = try!self.managedObjectContext.executeFetchRequest(fetchRequest) as! [CurrentUser]
        for (var i=0; i<fetchResults.count; i++) {
            managedObjectContext.deleteObject(fetchResults[i])
        }
        let currentUser = NSEntityDescription.insertNewObjectForEntityForName("CurrentUser", inManagedObjectContext: self.managedObjectContext) as! CurrentUser
        currentUser.username = self.username
        currentUser.password = self.password
        try!self.managedObjectContext.save()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section_names = self.section_names.sort()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        let numCells = Int(screenHeight/44)
        var num:Int = self.section_names.count
        if self.section_names.count < numCells {
            num = numCells
        }
        return num
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (appsTableView.dequeueReusableCellWithIdentifier("MyTestCell"))!
        cell.backgroundColor = UIColor.clearColor()
        if indexPath.row > section_names.count-1 {
            cell.textLabel!.text = ""
            cell.userInteractionEnabled = false
            if indexPath.row%2 == 0 {
                cell.backgroundColor = UIColor(red: 163/255, green: 163/255.0, blue: 163/255.0, alpha:1.0)
            }
            else {
                cell.backgroundColor = UIColor(red: 99/255, green: 99/255.0, blue: 99/255.0, alpha:0.85)
            }
            return cell
        }
        else {
            cell.userInteractionEnabled = true
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: 51/255, green: 102/255.0, blue: 255/255.0, alpha:1.0)
            cell.selectedBackgroundView = backgroundView
            cell.textLabel!.text =  "\t" + section_names[indexPath.row]
            cell.textLabel!.font = UIFont(name: "Noteworthy-Bold", size: 15)
            cell.imageView!.image = UIImage(named: "user_student.png")
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if indexPath.row%2 == 0 {
                cell.backgroundColor = UIColor(red: 163/255, green: 163/255.0, blue: 163/255.0, alpha:0.85)
            }
            else {
                cell.backgroundColor = UIColor(red: 99/255, green: 99/255.0, blue: 99/255.0, alpha:0.85)
            }
        }
        return cell
    }
    
    func getSIF() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://sandbox.api.hmhco.com/v1/sample_token?client_id=2e94fbac-d2ae-4afe-9a6a-812ab51c40c7.hmhco.com&grant_type=password&username=\(self.username)&password=\(self.password)")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        //let err: NSError?
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("d1b1908f94fb999286a1e9b7f756981d", forHTTPHeaderField: "Vnd-HMH-Api-Key")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                    if let access_token: NSString = json["access_token"] as? NSString {
                        //let refId = json["ref_id"] as! String
                        self.refId = json["ref_id"] as! String
                        
                        self.getSections(access_token as String)
                    }
                }
                else {
                    print("Something went wrong with getting the SIF token.")
                    self.getSIF()
                }
            }
            catch {
                print("Something went wrong!")
                self.getSIF()
            }

        })
        task!.resume()
    }
    
    func logout() {
        let navigationController = UINavigationController(rootViewController: (self.storyboard?.instantiateViewControllerWithIdentifier("loginVC"))!)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
