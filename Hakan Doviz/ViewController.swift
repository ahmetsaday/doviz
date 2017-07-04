//
//  ViewController.swift
//  Hakan Doviz
//
//  Created by Ece Karaçanta on 2.07.2017.
//  Copyright © 2017 ecekaracanta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, XMLParserDelegate{

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var webUIView: UIView!
    @IBOutlet weak var subWebview: UIWebView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_alis: UILabel!
    @IBOutlet weak var lbl_satis: UILabel!
    @IBOutlet weak var kurView: UIView!
    
    var count = 1
    var kurLogo = ["","","",""]
    
    // xml parsing variables
    var articles = NSMutableArray()
    var parser = XMLParser()
    var elements = NSMutableDictionary()
    var element = NSString()
    var alis = NSMutableString()
    var satis = NSMutableString()
    var durum = NSMutableString()
    
    override func viewDidLoad() {
        
        self.view.addBackground()
        
        webview.isHidden = true
        webUIView.isHidden = true
        subWebview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/index_ticker.php")!))
        
        lbl_title.text = ""
        
        parsingDataUrl()
        print(articles)
        
        // 0 dolar, 1 euro, 2 eu/dr, 3 ons
        dovizBackgroundColor(type: 0)
        
    }


    func visible(){
        webview.isHidden = false
        webUIView.isHidden = false
    }
    
    func invisible(){
        webview.isHidden = true
        webUIView.isHidden = true
    }
    
    //MARK: - Buttons
    @IBAction func btn_serbestPiyasa(_ sender: UIButton) {
        
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/doviz.php")!))
        lbl_title.text = "Serbest Piyasa"
        
    }
    
    @IBAction func btn_ekonomikTakvim(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/takvim.php")!))
        lbl_title.text = "Ekonomik Takvim"
    }

    @IBAction func btn_haberler(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/haberler.php")!))
        lbl_title.text = "Haberler"
    }
    
    @IBAction func btn_faiz(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/faiz.php")!))
        lbl_title.text = "Faiz"
    }
    
    @IBAction func btn_altin(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/altin.php")!))
        lbl_title.text = "Altın"
    }
    
    @IBAction func btn_pariteler(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/pariteler.php")!))
        lbl_title.text = "Pariteler"
    }
    @IBAction func btn_endeksler(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/endeksler.php")!))
        lbl_title.text = "Endeksler"
    }
    @IBAction func btn_bizKimiz(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/hakkimizda.php")!))
        lbl_title.text = "Biz Kimiz"
    }
    @IBAction func btn_bizeUlasin(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/iletisim.php")!))
        lbl_title.text = "Bize Ulaşın"
    }
    @IBAction func btn_emtia(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/emtia.php")!))
        lbl_title.text = "Emtial"
    }
    @IBAction func btn_hizmetlerimiz(_ sender: UIButton) {
        visible()
        webview.loadRequest(URLRequest(url: URL(string: "http://www.hakandoviz.com/mobilApp/hizmetler.php")!))
        lbl_title.text = "Hizmetlerimiz"
    }
    
    @IBAction func btn_callNumber(_ sender: UIButton) {
        
        let Phone = "02165771100"
        if let url = URL(string: "tel://\(Phone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btn_facebook(_ sender: Any) {
        
        let url = URL(string: "http://www.facebook.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func btn_twitter(_ sender: Any) {
        
        let url = URL(string: "http://www.twitter.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func btn_google(_ sender: UIButton) {
        
        let url = URL(string: "http://www.plus.google.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func btn_back(_ sender: UIButton) {
        
        invisible()
    }
    
    // her tıklandığında count a göre döviz kuru datası seçip gösterecek. 
    // Parse edilmiş datalar burada çağrılacak. (durum, alım, satım)
    @IBAction func btn_kur(_ sender: UIButton) {
        
        
        dovizBackgroundColor(type: count)
        kurAlim(type: count)
        kurSatim(type: count)
        count = count + 1
        
        if count >= 4{
            count = 0
        }
        
    }
    
    //MARK: - XML Data Parsing
    
    func parsingDataUrl(){
        
        articles = []
        parser = XMLParser(contentsOf: NSURL(string: "http://hakandoviz.com/mobilApp/doviz.xml.php")! as URL)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        element = elementName as NSString
        if ( elementName as NSString).isEqual(to: "DATA"){
            elements = NSMutableDictionary()
            elements = [:]
            alis = NSMutableString()
            alis = ""
            satis = NSMutableString()
            satis = ""
            durum = NSMutableString()
            durum = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if element.isEqual(to: "Alis")
        {
            alis.append(string)
            alis.append(string)
        }else if element.isEqual(to: "Satis"){
            satis.append(string)
            satis.append(string)
        }else if element.isEqual(to: "Durum"){
            durum.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if(elementName as NSString).isEqual(to: "DATA"){
            if !alis.isEqual(nil){
                elements.setObject(alis, forKey: "alış" as NSCopying)
            }
            if !satis.isEqual(nil){
                elements.setObject(satis, forKey: "satış" as NSCopying)
            }
            if !durum.isEqual(nil){
                elements.setObject(durum, forKey: "durum" as NSCopying)
            }
            
            
            articles.add(elements)
        }
    }
    
    // döviz kuru arkaplan rengini ayarlayan fonksiyon
    func dovizBackgroundColor(type: Int){
        
        if let dict = articles[type] as? Dictionary<String, AnyObject>{
            
            let item = dict["durum"]
            
            let item2 = item?.replacingOccurrences(of: "*", with: "")
            let cleanItem = item2?.replacingOccurrences(of: "\n", with: "")
            print(cleanItem!)
            
            if cleanItem == "asagi"{
                kurView.backgroundColor = UIColor.red
            }else if cleanItem == "yukari"{
                kurView.backgroundColor = UIColor.green
            }
            
        }
    }
    
    // döviz kurum alım
    func kurAlim(type: Int){
        if let dict = articles[type] as? Dictionary<String, AnyObject>{
            
            var status = 8
            if type == 3{
                status = 9
            }
            
            let item = dict["alış"]
            let item2 = item?.substring(to: (item?.length)! - status)
            //print(item2 ?? "olmadı")
            lbl_alis.text = String(describing: item2!)
        }
    }
    // döviz kurum satım
    func kurSatim(type: Int){
        if let dict = articles[type] as? Dictionary<String, AnyObject>{
            
            var status = 8
            if type == 3{
                status = 9
            }
            
            let item = dict["satış"]
            let item2 = item?.substring(to: (item?.length)! - status)
            //print(item2 ?? "olmadı")
            lbl_satis.text = String(describing: item2!)
        }
    }
}


extension UIView {
    func addBackground() {
        
        
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let size = CGRect(x: 0, y: 0, width: width, height: height)
        
        let imageViewBackground = UIImageView(frame: size)
        imageViewBackground.image = UIImage(named: "bg.png")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
}
}

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}




















