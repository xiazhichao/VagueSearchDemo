//
//  ViewController.swift
//  VagueSearchDemo
//
//  Created by xzc on 2018/9/11.
//  Copyright © 2018年 xzc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    struct CityDetailModel{
        var name:String?
        var spell:String?
    }
    //用于存储所有的数据，当搜索框内为空的时候，显示所有数据
    var dataList:Array<ViewController.CityDetailModel> = Array()
    //用于存储符合搜索框内关键字的数据
    var searchDataList:Array<ViewController.CityDetailModel> = Array()
    @IBOutlet weak var searchrBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchrBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //创建一些demo例子
        let model1:CityDetailModel = CityDetailModel(name: "苏州", spell: "suzhou")
        let model2:CityDetailModel = CityDetailModel(name: "扬州", spell: "yangzhou")
        let model7:CityDetailModel = CityDetailModel(name: "杨树", spell: "yangshu")
        let model8:CityDetailModel = CityDetailModel(name: "杨舒珊", spell: "yangshushan")
        let model9:CityDetailModel = CityDetailModel(name: "杨舒舒服", spell: "yangshushufu")
        let model10:CityDetailModel = CityDetailModel(name: "su州市区人民", spell: "suzhoushiqurenmin")
        let model3:CityDetailModel = CityDetailModel(name: "哈尔滨", spell: "haerbin")
        let model4:CityDetailModel = CityDetailModel(name: "苏州市", spell: "suzhoushi")
        let model5:CityDetailModel = CityDetailModel(name: "苏州市相城区", spell: "suzhoushixiangchengqu")
        let model6:CityDetailModel = CityDetailModel(name: "苏城区", spell: "suchengqu")
        self.dataList.append(model1)
        self.dataList.append(model2)
        self.dataList.append(model3)
        self.dataList.append(model4)
        self.dataList.append(model5)
        self.dataList.append(model6)
        self.dataList.append(model7)
        self.dataList.append(model8)
        self.dataList.append(model9)
        self.dataList.append(model10)
        //初始化
        self.searchDataList = self.dataList
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//MARK:- tableView代理
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.searchDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil
        {
            cell = UITableViewCell(style:.default, reuseIdentifier: "UITableViewCell")
        }
        let model:CityDetailModel = self.searchDataList[indexPath.row]
        cell.textLabel?.text = model.name
        return cell
    }

//MARK:- searchBar代理（模糊搜索主体）
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        var searchText :String = String()
        if range.length>0
        {
            if range.location > 0
            {
                let subStartStr = searchBar.text?.prefix(range.location)
                let subEndStr = searchBar.text?.suffix((searchBar.text?.count)!-(range.length + range.location))
                searchText = String(subStartStr! + subEndStr!) + text
            }else{
                searchText = text
            }
            
            print(searchText)
        }else
        {
            searchText = searchBar.text!
            searchText.append(text)
            print(searchText)
        }
        if searchText.count == 0 {
            self.searchDataList = self.dataList
        }else
        {
            self.startSearchInfo(searchText:searchText)
        }
        self.tableView .reloadData()
        return true
    }
    
    func startSearchInfo(searchText:String) {
//        let searchContent = searchText.replacingOccurrences(of: " ", with: "")
        //去掉输入中文时，拼音中的空格，用上面注释的方法没有效果，要用下面的
        let searchContent = searchText.components(separatedBy: NSCharacterSet.whitespaces).joined(separator:"")
        if self.isIncludeChineseIn(string: String(searchContent.prefix(1)))
        {
            var searchHeadstr = String()
            var index:NSInteger = 0
            for itemStr in searchContent
            {
                if self.isIncludeChineseIn(string:String(itemStr))
                {
                    searchHeadstr.append(itemStr)
                }else
                {
                    break;
                }
                index = index + 1
            }
            let searchSXStr = String(searchContent.suffix(searchContent.count - index))
            self.searchDataList.removeAll()
            for cityDetailModel in self.dataList
            {
                if (cityDetailModel.name?.hasPrefix(searchHeadstr))!
                {
                    let SXStr = cityDetailModel.name?.suffix(((cityDetailModel ).name?.count)! - searchHeadstr.count)
                    let SXSpytr = self.transformToPinYin(searchString: String(SXStr!))
                    if(SXSpytr.hasPrefix(searchSXStr))
                    {
                        self.searchDataList.append(cityDetailModel)
                    }
                    
                }
                
            }
            
        }else
        {
            self.searchDataList.removeAll()
            for cityDetailModel in self.dataList
            {
                if (cityDetailModel.spell?.hasPrefix(searchContent))!
                {
                    self.searchDataList.append(cityDetailModel )
                }
                
            }
            
        }
    }
    
//MARK:- 判断字符串是否包含中文
    func isIncludeChineseIn(string:String) -> Bool {
        
        for (_, value) in string.enumerated() {
            
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
    
//MARK:- 把汉字转为拼音
    func transformToPinYin(searchString:String) -> String {
        
        let mutableString = NSMutableString(string: searchString)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        
        let string = String(mutableString)
        //去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
}

