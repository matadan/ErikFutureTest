//
//  ViewController.swift
//  ErikFutureTest
//
//  Created by sabo on 08/02/2017.
//  Copyright © 2017 sabo. All rights reserved.
//

import UIKit
import Erik
import BrightFutures

class ViewController: UIViewController {
    
    @IBAction func test(_ sender: Any) {
        
        demoErikFutures()
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

func demoErikFutures() {
    // Expected output:
    //    1: Google
    //    -: Microsoft – Official Home Page
    //    2: Microsoft – Official Home Page DOM manipulated
    //    3: Amazon.com
    //    -: How people build software · GitHub
    //    4: How people build software · GitHub DOM manipulated

    func erikPromise(url: URL) -> Future<String, NSError> {
        let promise = Promise<String, NSError>()
        
        let _ = Erik.visitFuture(url: url).andThen { result in
            
            switch result {
            case .success(let doc):
                print("-: \(doc.title!)")
                
                // do some things with the DOM
                
                promise.success("\(doc.title!) DOM manipulated")
                
            case .failure(let err):
                print("-: \(err)")
                promise.failure(err)
            }
            
        }
        
        return promise.future
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
            print("1: \(doc!.title!)")
        } else {
            print("1: \(err)")
        }
    }
    
    
    let _ = erikPromise(url: urls[1]).andThen { result in
        switch result {
        case .success(let message):
            print("2: \(message)")
            
        case .failure(let err):
            print("2. \(err)")
        }
    }
    
    let _ = Erik.visitFuture(url: urls[2])
        .andThen { result in
            switch result {
            case .success(let doc):
                print("3: \(doc.title!)")
                
            case .failure(let err):
                print("3: \(err)")
            }
        }.andThen { _ in
            erikPromise(url: urls[3])
                .onSuccess { message in
                    print("4: \(message)")
                }
                .onFailure { err in
                    print("4: \(err)")
                }
        }
}
