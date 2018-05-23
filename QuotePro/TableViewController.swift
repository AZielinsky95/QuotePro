//
//  TableViewController.swift
//  QuotePro
//
//  Created by Alejandro Zielinsky on 2018-05-23.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController {

    var quotes = [Quote]()
    var savedQuotes: [NSManagedObject] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchFromCoreData()
        print(savedQuotes);
    }

}

extension TableViewController : NSFetchedResultsControllerDelegate
{
     // let context = self.fetchedResultsController.managedObjectContext
    func saveToCoreData(quote:Quote)
    {

        // 1
        let managedContext = DataManager.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "SavedQuote",
                                       in: managedContext)!
        
        let newSaveQuote = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        newSaveQuote.setValue(quote.quoteAuthor, forKeyPath: "author")
        newSaveQuote.setValue(quote.quoteText, forKeyPath: "text")
        let imageAsNSData = UIImagePNGRepresentation(quote.snapshotImage!)! as NSData
        newSaveQuote.setValue(imageAsNSData, forKeyPath: "image")
        
        // 4
        do {
            try managedContext.save()
            //savedQuotes.append(newSaveQuote)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchFromCoreData()
    {
        let managedContext = DataManager.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedQuote")
        
        //3
        do
        {
        savedQuotes = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for quote in savedQuotes
        {
            let item = Quote(quote: quote.value(forKey: "text") as! String, author: quote.value(forKey: "author") as! String, link: "");
            let image = UIImage(data: quote.value(forKey: "image") as! Data);
            item.snapshotImage = image!;
            quotes.append(item);
        }
        
        tableView.reloadData()
    }
}

extension TableViewController : QuoteBuilderProtocol
{
    func saveQuote(quote: Quote)
    {
        quotes.append(quote);
        saveToCoreData(quote: quote);
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "quoteBuilder")
        {
            let vc = segue.destination as! ViewController;
            vc.delegate = self;
        }
    }
}

extension TableViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let quote = quotes[indexPath.row].snapshotImage;
        share(shareImage: quote);
    }
    
    func share(shareImage:UIImage?){
        
        var objectsToShare = [AnyObject]()
        
        if let shareImageObj = shareImage
        {
            objectsToShare.append(shareImageObj)
        }
        
        if shareImage != nil
        {
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
        else
        {
            print("There is nothing to share")
        }
    }
}

extension TableViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! QuoteTableViewCell
        cell.quoteLabel.text = quotes[indexPath.row].quoteText;
        cell.authorLabel.text = quotes[indexPath.row].quoteAuthor;
        
        return cell;
    }
    
    
    
}
