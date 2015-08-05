import UIKit
import MobileCoreServices
import CoreData
import Foundation

@objc(Person)
class Person: NSManagedObject {
    @NSManaged var name:String
}

@objc(Image)
class Image: NSManagedObject {
    @NSManaged var name:String
    @NSManaged var image:NSData
}

@objc(CurrentUser)
class CurrentUser: NSManagedObject {
    @NSManaged var name:String
    @NSManaged var username:String
    @NSManaged var password:String
    @NSManaged var section:String
}

@objc(Email)
class Email: NSManagedObject {
    @NSManaged var email:String
    @NSManaged var student:String
    @NSManaged var username:String
}

@objc(Video)
class Video: NSManagedObject {
    @NSManaged var student:String
    @NSManaged var video:String
    @NSManaged var username:String
    @NSManaged var section:String
    @NSManaged var date:String
}


class cameraController: UIViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /* We will use this variable to determine if the viewDidAppear:
    method of our view controller is already called or not. If not, we will
    display the camera view */
    var beenHereBefore = false
    var controller: UIImagePickerController?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var name:String = ""
    var transfer_image:UIImage = UIImage()
    
    
    
    @IBOutlet weak var takenImage: UIImageView!
    
    
    @IBAction func showPortfolio(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("portfolioSegue", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("The name of the person selected is \(self.name)")
        //print(managedObjectContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String: AnyObject]){
            
            print("Picker returned successfully")
            
            let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
            
            if let type:AnyObject = mediaType{
                
                if type is String{
                    let stringType = type as! String
                    
                    if stringType == kUTTypeMovie as String{
                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                        if let url = urlOfVideo{
                            print("Video URL = \(url)")
                        }
                        
                    }
                        
                    else if stringType == kUTTypeImage as String{
                        /* Let's get the metadata. This is only for images. Not videos */
                        let metadata = info[UIImagePickerControllerMediaMetadata]
                            as? NSDictionary
                        if let _ = metadata{
                            let image = info[UIImagePickerControllerOriginalImage]
                                as? UIImage
                            if let theImage = image {
                                //print("Image Metadata = \(theMetaData)")
                                print("Image = \(theImage)")
                                takenImage.image = theImage
                                self.transfer_image = theImage
                            }

                        }
                    }
                    
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Picker was cancelled")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    func cameraSupportsMedia(mediaType: String,
        sourceType: UIImagePickerControllerSourceType) -> Bool{
            
            let availableMediaTypes =
            UIImagePickerController.availableMediaTypesForSourceType(sourceType) as
                [String]?
            
            if let types = availableMediaTypes{
                for type in types{
                    if type == mediaType{
                        return true
                    }
                }
            }
            
            return false
    }
    
    func doesCameraSupportTakingPhotos() -> Bool{
        return cameraSupportsMedia(kUTTypeImage as String, sourceType: .Camera)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue()) {
            if self.beenHereBefore{
                /* Only display the picker once as the viewDidAppear: method gets
                called whenever the view of our view controller gets displayed */
                return;
            } else {
                self.beenHereBefore = true
            }
            
            if self.isCameraAvailable() && self.doesCameraSupportTakingPhotos(){
                self.controller = UIImagePickerController()
                
                if let theController = self.controller{
                    theController.sourceType = .Camera
                    
                    theController.mediaTypes = [kUTTypeImage as String]
                    
                    theController.allowsEditing = true
                    theController.delegate = self
                    
                    self.presentViewController(theController, animated: true, completion: nil)
                }
                
            } else {
                print("Camera is not available")
            }
        }
    }
    
    let MenuSegueIdentifier = "portfolioSegue"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MenuSegueIdentifier {
            let destination = segue.destinationViewController as! portfolioController
            destination.student = self.name
            destination.image = UIImageJPEGRepresentation(self.transfer_image, 1.0)!
            destination.add_Image = true
        }
    }
    
}
