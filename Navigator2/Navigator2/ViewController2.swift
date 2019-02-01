//
//  ViewController2.swift
//  Navigator2
//
//  Created by LocoColina on 21/01/2019.
//  Copyright © 2019 LocoColina. All rights reserved.
//

import UIKit
import SQLite3

class ViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tabla: UITableView!

    var db: OpaquePointer?
    
    var historial: [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        leer()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func leer() {
       
        //tabla.reloadData()
        historial.removeAll()
        
        let queryString = "SELECT * FROM Historial"
        
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){            
            let url = String(cString: sqlite3_column_text(stmt, 1))
            
            //adding values to list
            let a = Historial(url: String(describing: url))
            historial.append((a.url!))
            print(url)
            print("aaaaa" + a.url!)

        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return historial.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "mycell")
        cell.textLabel?.text  = historial[indexPath.row]
        
        return cell
    }
    
    @IBAction func volver(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

