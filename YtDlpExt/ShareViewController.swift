//
//  ShareViewController.swift
//  YtDlpExt
//
//  Created by Tim Danner on 3/12/22.
//

import Cocoa
import Carbon

class ShareViewController: NSViewController {

    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }

    override func loadView() {
        super.loadView()
    
        // Insert code here to customize the view
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
            NSLog("Attachments = %@", attachments as NSArray)
            for att in attachments {
                NSLog("Att = %@", att)
                if att.hasItemConformingToTypeIdentifier("public.url") {
                    att.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { item2, error in
                        if let err = error {
                            NSLog("error = %@", err.localizedDescription)
                        }
                        
                        NSLog("item2 = %@", item2.debugDescription)
                        var url: String? = nil
                        switch item2 {
                        case let data as Data:
                            url = String(decoding: data, as: UTF8.self)
                            NSLog("url:Data = %@", url!)
                        case let url as URL:
                            NSLog("url = %@", url.description)
                        case let url as String:
                            NSLog("url:String = %@", url)
                        default:
                            NSLog("no url found")
                        }
                        if url != nil {
                            self.startDownload(url!)
                        }
                    })
                    break
                }
            }
        } else {
            NSLog("No Attachments")
        }
    }

    // Adapted from https://developer.apple.com/forums/thread/98830
    func startDownload(_ url: String) {
        urlLabel.stringValue = url
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/home/tim/Movies/yt-dlp")
//        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/yt-dlp")
        task.arguments = [url]
        task.currentDirectoryURL = URL(fileURLWithPath: "/home/tim/Movies", isDirectory: true)
        do {
            try task.run()
        } catch {
            NSLog("Unexpected error: \(error).")
        }
    }
    
    @IBOutlet weak var urlLabel: NSTextField!
    
    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        // Complete implementation by setting the appropriate value on the output item
    
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
}

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}
