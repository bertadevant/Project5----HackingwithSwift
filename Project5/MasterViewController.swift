//
//  MasterViewController.swift
//  Project5
//
//  Created by Berta Devant on 12/10/15.
//  Copyright © 2015 Berta Devant. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [String]()
    var allWords = [String]()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt")
        {
            if let startWords = try? String(contentsOfFile: startWordsPath, usedEncoding: nil)
            {
                allWords = startWords.componentsSeparatedByString("\n")
            } else {
            allWords = ["silkworm"]
            }
        }
        startGame()
    }

    func startGame(action: UIAlertAction! = nil) {
        
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        //print(allWords[0])
        title = allWords[0]
        objects.removeAll(keepCapacity:true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default)
        {[unowned self, ac] _ in                                            //closure is a unnamed func //in is beginning of func end of declaring; _ is passing an UIAlertAction variable
            if (ac.textFields?[0] != nil ||  ac.textFields?[0] == " ") {    //unowned == closure will use variable but does not own them
                let answer = ac.textFields![0]
                self.submitAnswer(answer.text!)
            } else {
                self.promptForAnswer()
            }
        }
        ac.addAction(submitAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func submitAnswer (answer:String) {
        let lowerAnswer = answer.lowercaseString
        
        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    objects.insert(answer, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0) //NSIndexPath row number == index we added the object
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic) //we insert a tableRow instead of calling reloadData() method so we can use animation
                }
            }
        }
    }
    
    func wordIsPossible (answer:String) -> Bool {
        //create a set with all characters of title == all characters you can use to create your word
        var titleArray =  Array(title!.characters)
        
        for Acharacter in answer.characters {
            if titleArray.contains(Acharacter) {
               titleArray.removeOne(Acharacter)
               //print(titleArray)
            } else {
                showUIAlertAction("The character \(Acharacter) is not contained in \(title!)")
                return false
            }
        }
        return true
    }
    
    func wordIsOriginal (answer:String) -> Bool {
    //I could have used forEach or just return: return !objects.contains(word)
        for word in objects {
            if answer == word {
                showUIAlertAction("The word: \(answer) is alreday part of the answers")
                return false
            }
        }
        return true
    }
    
    func wordIsReal (answer:String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, answer.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(answer, range: range, startingAt: 0, wrap: false, language: "en")
        // could have used -- return misspelledRange.location == NSNotFound -- if I was not trying to get a UIAlert too
        if misspelledRange.location == NSNotFound {
            return true
        }
        showUIAlertAction("The word \(answer) does not exist in English")
        return false
    }
    
    func endGame (action: UIAlertAction! = nil) {
        //count how many words and letters you used
        var letters = 0
        for word in objects {
            letters += word.characters.count
        }
        ReadWriteToFile("\(objects.count) \(letters)", file: "leaderboard.txt", write: true)
        let ac = UIAlertController(title: "You completed \(objects.count) valid words and used \(letters) characters", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title:"LeaderBoard", style: .Default, handler:endGame))
        
    }
    
    func showUIAlertAction (text:String) {
        let ac = UIAlertController(title: text, message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title:"Continue", style: .Default, handler:nil))
        ac.addAction(UIAlertAction(title:"End Game", style: .Default, handler:endGame))
        presentViewController(ac, animated: true, completion: nil)

    }
    
    func ReadWriteToFile (text:String, file:String, write: Bool) -> String {
        var read = "File Empty"
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true ).first {
            let path = dir.stringByAppendingPathComponent(file)
            //write
            if write {
                do {
                    try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                } catch {
                    print("Could not write on File")
                }
            } else {
                do {
                    read = try NSString (contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
                    return read
                } catch {
                    print("Could not read file")
                }
            }
        }
        return "Done"
    }
    

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

}

extension Array where Element: Equatable {
    mutating func removeOne(e: Element) -> Bool {
        if let int = indexOf(e) {
            removeAtIndex(int)
            
        }
        return true
    }
}


