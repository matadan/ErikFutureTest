//
//  ViewController.swift
//  ErikFutureTest
//

import UIKit
import Erik

import PromiseKit

class ViewController: UIViewController {
    
    @IBAction func test(_ sender: Any) {
        
        demoErikPromiseKit()
    }
    
    @IBAction func test2(_ sender: Any) {

        demoErikPromiseKit2()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension Erik {
    public func visitPromise(url: URL) -> Promise<Document> {
        
        return Promise { fulfill, reject in
            let _ = Erik.visit(url: url) { doc, err in
                if err == nil {
                    fulfill(doc!)
                } else {
                    reject(err!)
                }
            }
        }
    }
    
    public static func visitPromise(url: URL) -> Promise<Document> {
        return Erik.sharedInstance.visitPromise(url: url)
    }

}


let urlStrings = [
    "https://www.google.com",
    "https://www.trello.com/forgot/",
    "https://www.microsoft.com",
    "https://www.trello.com/forgot/",
    "https://www.amazon.com",
    "https://www.github.com"
]

let urls = urlStrings.map { URL(string: $0)! }

func manipulateDom(document: Document) {
    print("Number of elements: \(document.elements.count)")
}

func erikPromise(url: URL) -> Promise<String> {
    
    let promise: Promise<String> = Erik.visitPromise(url: url)
        .then { doc in
            print("-: \(doc.title!)")
            
            manipulateDom(document: doc)
            
            return Promise<String>(value: "\(doc.title!) DOM manipulated")
        }
        .catch { err in
            print("-: \(err)")
    }
    
    return promise
}

func erikFirst() {
    let _ = firstly {
        erikPromise(url: urls[0])
    }
    .then { _ in
        return Promise<Bool>(value: true)
    }.then { flag in
        print("1: \(flag)")
    }
    .catch { err in
        print("1. \(err)")
    }
}

func erikSecond() {
    let _ = firstly {
        return Promise<Bool>(value: true)
    }
    .then { _ in
        erikPromise(url: urls[0])
    }.then { message in
        print("2: \(message)")
    }
    .catch { err in
        print("2. \(err)")
    }
    
}

func demoErikPromiseKit() {
    
    print("----Erik first")
    erikFirst()
    erikSecond()
    
    //works
}

func demoErikPromiseKit2() {

    print("----Erik second")
    erikSecond()
    erikFirst()
    
    //does not work unless demoErikPromiseKit() called previously
}

