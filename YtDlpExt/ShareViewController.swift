//
//  ShareViewController.swift
//  YtDlpExt
//
//  Created by Tim Danner on 3/12/22.
//

import Cocoa
import Carbon

class ShareViewController: NSViewController {

    var script: NSAppleScript = {
        let script = NSAppleScript(source: """
            on download(url)
                tell application \"iTerm2\"
                  set newWindow to (create window with default profile)
                  tell current session of newWindow
                      write text \"cd ~/Movies \"
                      write text \"yt-dlp 'https://www.youtube.com/watch?v=m9EX0f6V11Y' || sleep 1000 \"
                      write text \"sleep 3 \"
                      write text \"exit \"
                  end tell
                end tell
            end download
            """
        )!
        let success = script.compileAndReturnError(nil)
        assert(success)
        return script
    }()
    
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
        let parameters = NSAppleEventDescriptor.list()
        parameters.insert(NSAppleEventDescriptor(string: url), at: 0)

        let event = NSAppleEventDescriptor(
            eventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setDescriptor(NSAppleEventDescriptor(string: "download"), forKeyword: AEKeyword(keyASSubroutineName))
        event.setDescriptor(parameters, forKeyword: AEKeyword(keyDirectObject))

        var error: NSDictionary? = nil
        _ = self.script.executeAppleEvent(event, error: &error) as NSAppleEventDescriptor?
    }
    
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
