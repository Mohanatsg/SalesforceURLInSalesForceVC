/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore
import SalesforceSwiftSDK
import PromiseKit
import SmartStore
import SmartSync

class RootViewController : UITableViewController,SFSafariViewControllerDelegate
{
    var dataRows = [NSDictionary]()
    
    // MARK: - View lifecycle
    override func loadView()
    {
        super.loadView()
        self.title = "Mobile SDK Sample App"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let restApi = SFRestAPI.sharedInstance()
        restApi.Promises
            .query(soql: "SELECT Name FROM User LIMIT 10")
            .then {  request  in
                restApi.Promises.send(request: request)
            }.done { [unowned self] response in
                self.dataRows = response.asJsonDictionary()["records"] as! [NSDictionary]
                SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"request:didLoadResponse: #records: \(self.dataRows.count)")
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }.catch { error in
                SalesforceSwiftLogger.log(type(of:self), level:.debug, message:"Error: \(error)")
        }
        
        // for debug purposes
        SalesforceSwiftLogger.setLogLevel(.all)
        SFSDKLogger.setLogLevel(.all)
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    enum Poc: Int {
        case  AccountID=0, AccounID_IOSPREF, IOSPREF_AccountID
    }
   
    func invokeSafariController(url: String)  {
        guard let instanceUrl = SFRestAPI.sharedInstance().user.credentials.instanceUrl else {
            return
        }
        guard let accessToken = SFRestAPI.sharedInstance().user.credentials.accessToken else {
            return
        }
        let secureUrl = "/secur/frontdoor.jsp?sid="
        let retUrl = "&retURL="
        
        let webUrl: String = instanceUrl.description + secureUrl + accessToken + retUrl + url;
        
        let x = NSURL(string:webUrl )! as URL
        let safariVC = SFSafariViewController(url: x)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil )
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        
        case Poc.AccountID.rawValue :
            // Invoke SFsarafi Controller Oprion 01
            invokeSafariController(url: "lightning/n/SGWS_Account_Insight?AccountID=0013D00000Ynp0MQAR");
            break;
        case Poc.AccounID_IOSPREF.rawValue :
            // Invoke SFsarafi Controller Oprion 02
            invokeSafariController(url: "/lightning/n/SGWS_Account_Insight?iospref=web");
            break;
        //case Poc.IOSPREF_AccountID.rawValue :
        default:
            // Invoke SFsarafi Controller Oprion 03
            invokeSafariController(url: "/lightning/n/SGWS_Account_Insight?iospref=web&AccountID=0013D00000Ynp0MQAR");
            break;
        }
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return 3//self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellIdentifier"
        
        // Dequeue or create a cell of the appropriate type.
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier:cellIdentifier)
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // If you want to add an image to your cell, here's how.
        let image = UIImage(named: "icon.png")
        cell!.imageView!.image = image
        
        //        // Configure the cell to show the data.
        //        let obj = dataRows[indexPath.row]
        //        cell!.textLabel!.text = obj["Name"] as? String
        
        switch indexPath.row {
        case Poc.AccountID.rawValue :
            cell!.textLabel!.text = "AccountID"
        case Poc.AccounID_IOSPREF.rawValue :
            cell!.textLabel!.text = "AccounID_IOSPREF"
        case Poc.IOSPREF_AccountID.rawValue :
            cell!.textLabel!.text = "IOSPREF_AccountID"
        default:
            cell!.textLabel!.text = "SOUP QUERY TEST"
        }
        
        // This adds the arrow to the right hand side.
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
}

