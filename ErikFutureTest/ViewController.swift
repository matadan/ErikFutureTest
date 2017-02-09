//
//  ViewController.swift
//  ErikFutureTest
//

import UIKit
import Erik

import BrightFutures
import Result

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

func erikFuture(url: URL) -> Future<String, NSError> {
    
    let promise = Promise<String, NSError>()
    
    Erik.visit(url: url) { doc, err in
        if err == nil {
            print("-: \(doc!.title!)")
            
            manipulateDom(document: doc!)
            
            promise.success("\(doc!.title!) DOM manipulated")
        } else {
            promise.failure(err as! NSError)
        }
    }
    
    return promise.future
}

func boolFuture() -> Future<Bool, NoError> {
    let promise = Promise<Bool, NoError>()
    
    promise.success(true)
    
    return promise.future
}

func erikFirst() {
    
    erikFuture(url: urls[0])
    .andThen {_ in 
        print(" Do somehting else")
    }
    .andThen { flag in
        print("1: \(flag)")
    }.onFailure { err in
        print("1: \(err)")
    }
}

func erikSecond() {

    boolFuture()
    .andThen { result in
        let _ = erikFuture(url: urls[0])
        .andThen { result in
            switch result {
            case .success(let message):
                print("2: \(message)")

            case .failure(let err):
                print("2: \(err)")
            }
        }
    }
    .onFailure { err in
        print("2: onFailure: \(err)")
    }
}

func demoErikPromiseKit() {
    
    print("----Erik first")
    erikFirst()
    erikSecond()
    
    //works
}

func demoErikPromiseKit2() {

    //fix:
    Erik.visit(url: URL(string: "https://www.google.com")!, completionHandler: nil)
    
    print("----Erik second")
    erikSecond()
    erikFirst()
    
    //does not work unless demoErikPromiseKit() called previously
}

