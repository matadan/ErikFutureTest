//
//  ViewController.swift
//  ErikFutureTest
//
//  Created by sabo on 08/02/2017.
//  Copyright © 2017 sabo. All rights reserved.
//

import UIKit
import Erik

//import BrightFutures

import PromiseKit

class ViewController: UIViewController {
    
    @IBAction func test(_ sender: Any) {
        
        demoErikPromiseKit()
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

//func demoErikFutures() {
//    // Expected output:
//    //    1: Google
//    //    -: Microsoft – Official Home Page
//    //    2: Microsoft – Official Home Page DOM manipulated
//    //    3: Amazon.com
//    //    -: How people build software · GitHub
//    //    4: How people build software · GitHub DOM manipulated
//
//    func erikPromise(url: URL) -> Future<String, NSError> {
//        let promise = Erik.Promise<String, NSError>()
//        
//        let _ = Erik.visitFuture(url: url).andThen { result in
//            
//            switch result {
//            case .success(let doc):
//                print("-: \(doc.title!)")
//                
//                // do some things with the DOM
//                
//                promise.success("\(doc.title!) DOM manipulated")
//                
//            case .failure(let err):
//                print("-: \(err)")
//                promise.failure(err)
//            }
//            
//        }
//        
//        return promise.future
//    }
//    
//    let urlStrings = [
//        "https://www.google.com",
//        "https://www.microsoft.com",
//        "https://www.amazon.com",
//        "https://www.github.com"
//    ]
//    
//    let urls = urlStrings.map { URL(string: $0)! }
//    
//    
//    Erik.visit(urlString: urlStrings[0]) { doc, err in
//        if err == nil {
//            print("1: \(doc!.title!)")
//        } else {
//            print("1: \(err)")
//        }
//    }
//    
//    
//    let _ = erikPromise(url: urls[1]).andThen { result in
//        switch result {
//        case .success(let message):
//            print("2: \(message)")
//            
//        case .failure(let err):
//            print("2. \(err)")
//        }
//    }
//    
//    let _ = Erik.visitFuture(url: urls[2])
//        .andThen { result in
//            switch result {
//            case .success(let doc):
//                print("3: \(doc.title!)")
//                
//            case .failure(let err):
//                print("3: \(err)")
//            }
//        }.andThen { _ in
//            erikPromise(url: urls[3])
//                .onSuccess { message in
//                    print("4: \(message)")
//                }
//                .onFailure { err in
//                    print("4: \(err)")
//                }
//        }
//}

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

func demoErikPromiseKit() {
    // Expected output:
//        1: Optional("Google")
//        -: Microsoft – Official Home Page
//        Number of elements: xxx
//        2: Microsoft – Official Home Page DOM manipulated
//        3: Optional("Amazon.com")
//        -: How people build software · GitHub
//        Number of elements: xxx
//        4: How people build software · GitHub DOM manipulated
    
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
  
    let urlStrings = [
        "https://www.google.com",
        "https://www.microsoft.com",
        "https://www.amazon.com",
        "https://www.github.com"
    ]
    
    let urls = urlStrings.map { URL(string: $0)! }
    
    Erik.visit(urlString: urlStrings[0]) { doc, err in
        if err == nil {
            print("1: \(doc!.title)")
        } else {
            print("1: \(err)")
        }
    }
    
    let _ = erikPromise(url: urls[1])
    .then { message in
        print("2: \(message)")
    }
    .catch { err in
        print("2. \(err)")
    }
    
    let _ = firstly {
        Erik.visitPromise(url: urls[2])
    }
    .then { doc in
        print("3: \(doc.title)")
    }.then {
        erikPromise(url: urls[3])
    }.then { message in
        print("4: \(message)")
    }
    .catch { err in
        print("Error: \(err)")
    }
}
