//
//  ViewController.swift
//  Navigator2
//
//  Created by LocoColina on 15/01/2019.
//  Copyright © 2019 LocoColina. All rights reserved.
//

import UIKit
import WebKit
import SQLite3

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate{

    @IBOutlet weak var aceptar: UIButton!
    @IBOutlet weak var navUrl: UITextField!
    @IBOutlet weak var web: WKWebView!
    @IBOutlet weak var borrar: UIButton!
    @IBOutlet weak var historial: UIButton!
    
    var db: OpaquePointer?
    var urlList = [Historial]()
    var historia: [String] = []
    

    @IBOutlet weak var izq: UIButton!
    @IBOutlet weak var der: UIButton!
    override func viewDidLoad() {
        //var db: OpaquePointer?
        //var urlList = [Historial]()
        super.viewDidLoad()
        
        web.navigationDelegate = self
        navUrl.text="https://www.duckduckgo.com"
        let url=URL(string: navUrl.text!)
        let request=URLRequest(url:url!)
        web.load(request)
        
     
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Historial.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else {
            print("base abierta")
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Historial (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
        }
    }
    
    @IBAction func ir(_ sender: Any) {
        
        navUrl.text = navUrl.text?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        navUrl.text = String((navUrl.text?.characters.filter { !" ".characters.contains($0) })!)
        if !navUrl.text!.contains("https://www.") {
            navUrl.text="https://www.google.com/search?&q=" + navUrl.text!
        }
        let url=URL(string: navUrl.text!)
        let request=URLRequest(url:url!)
        web.load(request)
        //insertar()
    }

    
  
    func insertar()  {
        print("insertar")
        //getting values from textfields
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Historial ('url') VALUES ('" + navUrl.text! + "')"
        print(queryString)
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        
        
        //  readValues()
        
        //displaying a success message
        print("datos grabados")
        
    }
    
    @IBAction func atras(_ sender: Any) {
        //navUrl.text="pasa-12";

        if web.canGoBack {
            web.goBack()
            
        }
        navUrl.text = web.url?.absoluteString
        hide()
        //insertar()
    }
    
    @IBAction func adelante(_ sender: Any) {
        
        if web.canGoForward {
            web.goForward()
        }
        
        navUrl.text = web.url?.absoluteString
        hide()
        //insertar()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hide()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        navUrl.text = web.url?.absoluteString
        insertar()
    }
  
    func hide(){
        if web.canGoBack {
            izq.isEnabled = true;
        }else {izq.isEnabled = false}
        if web.canGoForward{
            der.isEnabled = true
        } else {der.isEnabled = false}
        
    }
    @IBAction func eliminar(_ sender: Any) {
        navUrl.text = "";
    }
}


class Historial {
    var url: String?
    init(url: String?){      
        self.url = url
    }
}

