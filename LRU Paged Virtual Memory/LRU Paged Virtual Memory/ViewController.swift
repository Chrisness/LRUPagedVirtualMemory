//
//  ViewController.swift
//  LRU Paged Virtual Memory
//
//  Created by Chris Mahoney on 4/6/15.
//  Copyright (c) 2015 Chris Mahoney. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    //Table text
    @IBOutlet weak var frame0data: NSTextField!
    @IBOutlet weak var frame1data: NSTextField!
    @IBOutlet weak var frame2data: NSTextField!
    @IBOutlet weak var frame3data: NSTextField!
    @IBOutlet weak var frame4data: NSTextField!
    @IBOutlet weak var frame5data: NSTextField!
    @IBOutlet weak var frame6data: NSTextField!
    @IBOutlet weak var frame7data: NSTextField!
    @IBOutlet weak var frame8data: NSTextField!
    @IBOutlet weak var frame9data: NSTextField!
    @IBOutlet weak var frame10data: NSTextField!
    @IBOutlet weak var frame11data: NSTextField!
    @IBOutlet weak var frame12data: NSTextField!
    @IBOutlet weak var frame13data: NSTextField!
    @IBOutlet weak var frame14data: NSTextField!
    @IBOutlet weak var frame15data: NSTextField!
    @IBOutlet weak var stats: NSTextField!
    
    //Our frame table, values initialized to ""
    var frameTable = [String](count: 16, repeatedValue: "")
    
    //How old each memory reference is
    var memoryAge = [Int](count: 16, repeatedValue: 0)
    
    //Number of times a process is referenced
    var numberOfReferences = [Int](count: 16, repeatedValue: 0)
    
    //Number of faults a process creates
    var numberOfFaults = [Int](count: 16, repeatedValue: 0)
    
    //File input gets stored here
    var memoryReferenceArray = [String]()
    
    //Where we are in the file
    var framePointer = 0
    
    var faultHit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Read data
        let read : String = File.read("/Users/Chris/Desktop/input3a.txt")!
        
        //Parse the text into an array
        memoryReferenceArray = read.componentsSeparatedByString("\n")
    }
    
    //One reference happens (next button pressed)
    @IBAction func nextPressed(sender: NSButton) {
        if framePointer < memoryReferenceArray.count{
            useMemory(memoryReferenceArray[framePointer])
            ++framePointer
        }
        
        updateGUI()
    }
    
    //Keep going until a fault happens (fault button pressed)
    @IBAction func faultPressed(sender: NSButton) {
        while faultHit == false && framePointer < memoryReferenceArray.count{
           useMemory(memoryReferenceArray[framePointer])
            ++framePointer
        }
        faultHit = false
        updateGUI()
    }
    
    //Go through the whole file (complete button pressed)
    @IBAction func completePressed(sender: NSButton) {
        while framePointer < memoryReferenceArray.count{
            useMemory(memoryReferenceArray[framePointer])
            ++framePointer
        }
        updateGUI()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //The main method that places references in the memory table
    func useMemory(frame: String) {
        
        var addedFrame = false
        
        //Check if the reference is already in the frame
        if checkIfInFrame(frame){
            addedFrame = true
            age(frame)
            //Parse the process number from the reference string
            var processReferencing = String(frame[advance(frame.startIndex, 1)]).toInt()
            ++numberOfReferences[processReferencing!]
            
        }
        
        //If it's not in the frame, and if there are empty frames, place it on top
        if frameTable[15] == ""{
            var count = 0
            for str in frameTable{
                if str == ""{
                    if addedFrame == false{
                        frameTable[count] = frame
                        addedFrame = true
                        faultHit = true
                        age(frame)
                        //Parse the process number from the reference string
                        var processFaulting = String(frame[advance(frame.startIndex, 1)]).toInt()
                        ++numberOfFaults[processFaulting!]
                        ++numberOfReferences[processFaulting!]
                    }
                }
                ++count
            }
        }
        //If not in the frame, and the frame list if full
        //replace the last recently used with new frame
        else{
            if addedFrame == false{
                var set = false
                for index in 0...15{
                    //Replace the "least recently referenced frame
                    if memoryAge[index] == maxElement(memoryAge) && set == false{
                        frameTable[index] = frame
                        age(frame)
                        faultHit = true
                        addedFrame = true
                        set = true
                        //Parse the process number from the reference string
                        var processFaulting = String(frame[advance(frame.startIndex, 1)]).toInt()
                        ++numberOfFaults[processFaulting!]
                        ++numberOfReferences[processFaulting!]
                    }
                }
            }
        }
    }
    
    //the GUI is updated with every button press
    func updateGUI(){
        frame0data.stringValue = frameTable[0]
        frame1data.stringValue = frameTable[1]
        frame2data.stringValue = frameTable[2]
        frame3data.stringValue = frameTable[3]
        frame4data.stringValue = frameTable[4]
        frame5data.stringValue = frameTable[5]
        frame6data.stringValue = frameTable[6]
        frame7data.stringValue = frameTable[7]
        frame8data.stringValue = frameTable[8]
        frame9data.stringValue = frameTable[9]
        frame10data.stringValue = frameTable[10]
        frame11data.stringValue = frameTable[11]
        frame12data.stringValue = frameTable[12]
        frame13data.stringValue = frameTable[13]
        frame14data.stringValue = frameTable[14]
        frame15data.stringValue = frameTable[15]
        
        stats.stringValue = "Process 1 referenced \(String(numberOfReferences[1])) times and faulted \(String(numberOfFaults[1])) times\nProcess 2 referenced \(String(numberOfReferences[2])) times and faulted \(String(numberOfFaults[2])) times\nProcess 3 referenced \(String(numberOfReferences[3])) times and faulted \(String(numberOfFaults[3])) times\n"
        stats.stringValue += "Process 4 referenced \(String(numberOfReferences[4])) times and faulted \(String(numberOfFaults[4])) times\nProcess 5 referenced \(String(numberOfReferences[5])) times and faulted \(String(numberOfFaults[5])) times"
    }
    
    //Checks if the frame is in the frame table
    func checkIfInFrame(check: String) -> Bool{
        
        for str in frameTable{
            if str == check{
                return true
            }
        }
        return false
    }
    
    //Every memory reference ages all other frames by 1
    //The referenced frame gets reset to zero
    func age(intoMem: String){
        for index in 0...15{
            ++memoryAge[index]
            if frameTable[index] == intoMem{
                memoryAge[index] = 0
            }
        }
    }
}

//Basic Swift file input class from stackoverflow
class File {
    
    class func exists (path: String) -> Bool {
        return NSFileManager().fileExistsAtPath(path)
    }
    
    class func read (path: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        if File.exists(path) {
            return String(contentsOfFile:path, encoding: encoding, error: nil)!
        }
        
        return nil
    }
    
    class func write (path: String, content: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        return content.writeToFile(path, atomically: true, encoding: encoding, error: nil)
    }

}

