
//
//  PhoneZoneCodeView.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/26.
//

import Foundation
import UIKit



class PhoneZoneCodeView: UIView {
    lazy var label = UILabel().then {
        $0.text = "+86"
        $0.textAlignment = .center
        $0.font = .font(size: 12, type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_dddddd)
    }
    
    lazy var arrow = ImageView().then {
        $0.image = .assets(.arrow_down_regular)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(arrow)
        addSubview(line)
        
        label.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(45)
        }
        
        arrow.snp.makeConstraints {
            $0.height.equalTo(6.5)
            $0.width.equalTo(10.5)
            $0.centerY.equalToSuperview()
            $0.left.equalTo(label.snp.right)
        }
        
        line.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(13)
            $0.width.equalTo(0.5)
            $0.left.equalTo(arrow.snp.right).offset(5)
            $0.right.equalToSuperview().offset(-10)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class PhoneZoneCodeViewAlert: UIView {
    var selectCallback: ((_ zone: ZoneItem) -> ())?
    var dismissCallback: (() -> ())?
    
    var zones = [ZoneItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedZone = ZoneItem(cn: "中国", en: "China", code: "86")
    
    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(PhoneZoneCodeViewAlertCell.self, forCellReuseIdentifier: PhoneZoneCodeViewAlertCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(tableView)
        
        zones = getZones()
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(47)
            $0.right.equalToSuperview().offset(-47)
            $0.height.equalTo(300)
        }
        
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    func setAssociateFrame(frame: CGRect) {
        let height = Screen.screenHeight - frame.maxY < 300 ? Screen.screenHeight - frame.maxY : 300
        containerView.snp.remakeConstraints {
            $0.left.equalToSuperview().offset(frame.minX)
            $0.right.equalToSuperview().offset(-(Screen.screenWidth - frame.minX - frame.width))
            $0.top.equalToSuperview().offset(frame.maxY)
            $0.height.equalTo(height)
        }
        
    }
    
    @objc private func close() {
        removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 1
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        dismissCallback?()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.alpha = 0
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
    
    
    func getZones() -> [ZoneItem] {
        do {
            return try JSONDecoder().decode([ZoneItem].self, from: zoneJsons.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").data(using: .utf8) ?? Data())
        } catch let error {
            print(error.localizedDescription)
            return [ZoneItem(cn: "中国", en: "China", code: "86")]
        }
    }
}

extension PhoneZoneCodeViewAlert: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhoneZoneCodeViewAlertCell.reusableIdentifier, for: indexPath) as! PhoneZoneCodeViewAlertCell
        let zone = zones[indexPath.row]
        cell.titleLabel.text = "\(zone)"
        cell.titleLabel.textColor = selectedZone.code == zone.code ? .custom(.blue_2da3f6) : .custom(.black_3f4663)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if zones[indexPath.row].code != "86" {
            SceneDelegate.shared.window?.makeToast("该区域暂不支持".localizedString)
            return
        }
        selectedZone = zones[indexPath.row]
        tableView.reloadData()
        selectCallback?(zones[indexPath.row])
        removeFromSuperview()
    }
    
}



// MARK: - SwtichAreaViewCell
extension PhoneZoneCodeViewAlert {
    class PhoneZoneCodeViewAlertCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var titleLabel = UILabel().then {
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.black_3f4663)
            $0.text = "中国 +86"
        }
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(titleLabel)
            contentView.addSubview(line)
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(18)
                $0.left.equalToSuperview().offset(18)
            }
            
            
            line.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(18)
                $0.right.equalToSuperview()
                $0.left.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension PhoneZoneCodeViewAlert {
    struct ZoneItem: Codable, CustomStringConvertible {
        let cn: String
        let en: String
        let code: String
        
        var name: String {
            if getCurrentLanguage() == .chinese {
                return cn
            } else {
                return en
            }
        }
        
        var description: String {
            "\(name)   +\(code)"
        }
        
    }
}

extension PhoneZoneCodeViewAlert {
    var zoneJsons: String {
"""
 [
    {"cn":"中国","en":"China","code":"86"},
             {"cn":"中国香港","en":"Hong Kong","code":"852"},
             {"cn":"中国台湾","en":"Taiwan","code":"886"},
             {"cn":"阿富汗","en":"Afghanistan","code":"93"},
             {"cn":"阿尔巴尼亚","en":"Albania","code":"355"},
             {"cn":"阿尔及利亚","en":"Algeria","code":"213"},
             {"cn":"美属萨摩亚","en":"American Samoa","code":"684"},
             {"cn":"安道尔","en":"Andorra","code":"376"},
             {"cn":"安哥拉","en":"Angola","code":"244"},
             {"cn":"安圭拉","en":"Anguilla","code":"1264"},
             {"cn":"南极洲","en":"Antarctica","code":"672"},
             {"cn":"安提瓜和巴布达","en":"Antigua and Barbuda","code":"1268"},
             {"cn":"阿根廷","en":"Argentina","code":"54"},
             {"cn":"亚美尼亚","en":"Armenia","code":"374"},
             {"cn":"阿鲁巴","en":"Aruba","code":"297"},
             {"cn":"澳大利亚","en":"Australia","code":"61"},
             {"cn":"奥地利","en":"Austria","code":"43"},
             {"cn":"阿塞拜疆","en":"Azerbaijan","code":"994"},
             {"cn":"巴林","en":"Bahrain","code":"973"},
             {"cn":"孟加拉国","en":"Bangladesh","code":"880"},
             {"cn":"巴巴多斯","en":"Barbados","code":"1246"},
             {"cn":"白俄罗斯","en":"Belarus","code":"375"},
             {"cn":"比利时","en":"Belgium","code":"32"},
             {"cn":"伯利兹","en":"Belize","code":"501"},
             {"cn":"贝宁","en":"Benin","code":"229"},
             {"cn":"百慕大","en":"Bermuda","code":"1441"},
             {"cn":"不丹","en":"Bhutan","code":"975"},
             {"cn":"玻利维亚","en":"Bolivia","code":"591"},
             {"cn":"波黑","en":"Bosnia and Herzegovina","code":"387"},
             {"cn":"博茨瓦纳","en":"Botswana","code":"267"},
             {"cn":"巴西","en":"Brazil","code":"55"},
             {"cn":"英属维尔京群岛","en":"British Virgin Islands","code":"1284"},
             {"cn":"文莱","en":"Brunei Darussalam","code":"673"},
             {"cn":"保加利亚","en":"Bulgaria","code":"359"},
             {"cn":"布基纳法索","en":"Burkina Faso","code":"226"},
             {"cn":"缅甸","en":"Burma","code":"95"},
             {"cn":"布隆迪","en":"Burundi","code":"257"},
             {"cn":"柬埔寨","en":"Cambodia","code":"855"},
             {"cn":"喀麦隆","en":"Cameroon","code":"237"},
             {"cn":"加拿大","en":"Canada","code":"1"},
             {"cn":"佛得角","en":"Cape Verde","code":"238"},
             {"cn":"开曼群岛","en":"Cayman Islands","code":"1345"},
             {"cn":"中非","en":"Central African Republic","code":"236"},
             {"cn":"乍得","en":"Chad","code":"235"},
             {"cn":"智利","en":"Chile","code":"56"},
             {"cn":"圣诞岛","en":"Christmas Island","code":"61"},
             {"cn":"科科斯（基林）群岛","en":"Cocos (Keeling) Islands","code":"61"},
             {"cn":"哥伦比亚","en":"Colombia","code":"57"},
             {"cn":"科摩罗","en":"Comoros","code":"269"},
             {"cn":"刚果（金）","en":"Democratic Republic of the Congo","code":"243"},
             {"cn":"刚果（布）","en":"Republic of the Congo","code":"242"},
             {"cn":"库克群岛","en":"Cook Islands","code":"682"},
             {"cn":"哥斯达黎加","en":"Costa Rica","code":"506"},
             {"cn":"科特迪瓦","en":"Cote d'Ivoire","code":"225"},
             {"cn":"克罗地亚","en":"Croatia","code":"385"},
             {"cn":"古巴","en":"Cuba","code":"53"},
             {"cn":"塞浦路斯","en":"Cyprus","code":"357"},
             {"cn":"捷克","en":"Czech Republic","code":"420"},
             {"cn":"丹麦","en":"Denmark","code":"45"},
             {"cn":"吉布提","en":"Djibouti","code":"253"},
             {"cn":"多米尼克","en":"Dominica","code":"1767"},
             {"cn":"多米尼加","en":"Dominican Republic","code":"1809"},
             {"cn":"厄瓜多尔","en":"Ecuador","code":"593"},
             {"cn":"埃及","en":"Egypt","code":"20"},
             {"cn":"萨尔瓦多","en":"El Salvador","code":"503"},
             {"cn":"赤道几内亚","en":"Equatorial Guinea","code":"240"},
             {"cn":"厄立特里亚","en":"Eritrea","code":"291"},
             {"cn":"爱沙尼亚","en":"Estonia","code":"372"},
             {"cn":"埃塞俄比亚","en":"Ethiopia","code":"251"},
             {"cn":"福克兰群岛","en":"Falkland Islands","code":"500"},
             {"cn":"法罗群岛","en":"Faroe Islands","code":"298"},
             {"cn":"斐济","en":"Fiji","code":"679"},
             {"cn":"芬兰","en":"Finland","code":"358"},
             {"cn":"法国","en":"France","code":"33"},
             {"cn":"法属圭亚那","en":"French Guiana","code":"594"},
             {"cn":"法属波利尼西亚","en":"French Polynesia","code":"689"},
             {"cn":"加蓬","en":"Gabon","code":"241"},
             {"cn":"格鲁吉亚","en":"Georgia","code":"995"},
             {"cn":"德国","en":"Germany","code":"49"},
             {"cn":"加纳","en":"Ghana","code":"233"},
             {"cn":"直布罗陀","en":"Gibraltar","code":"350"},
             {"cn":"希腊","en":"Greece","code":"30"},
             {"cn":"格陵兰","en":"Greenland","code":"299"},
             {"cn":"格林纳达","en":"Grenada","code":"1473"},
             {"cn":"瓜德罗普","en":"Guadeloupe","code":"590"},
             {"cn":"关岛","en":"Guam","code":"1671"},
             {"cn":"危地马拉","en":"Guatemala","code":"502"},
             {"cn":"根西岛","en":"Guernsey","code":"1481"},
             {"cn":"几内亚","en":"Guinea","code":"224"},
             {"cn":"几内亚比绍","en":"Guinea-Bissau","code":"245"},
             {"cn":"圭亚那","en":"Guyana","code":"592"},
             {"cn":"海地","en":"Haiti","code":"509"},
             {"cn":"梵蒂冈","en":"Holy See (Vatican City)","code":"379"},
             {"cn":"洪都拉斯","en":"Honduras","code":"504"},
             {"cn":"匈牙利","en":"Hungary","code":"36"},
             {"cn":"冰岛","en":"Iceland","code":"354"},
             {"cn":"印度","en":"India","code":"91"},
             {"cn":"印度尼西亚","en":"Indonesia","code":"62"},
             {"cn":"伊朗","en":"Iran","code":"98"},
             {"cn":"伊拉克","en":"Iraq","code":"964"},
             {"cn":"爱尔兰","en":"Ireland","code":"353"},
             {"cn":"以色列","en":"Israel","code":"972"},
             {"cn":"意大利","en":"Italy","code":"39"},
             {"cn":"牙买加","en":"Jamaica","code":"1876"},
             {"cn":"日本","en":"Japan","code":"81"},
             {"cn":"约旦","en":"Jordan","code":"962"},
             {"cn":"哈萨克斯坦","en":"Kazakhstan","code":"73"},
             {"cn":"肯尼亚","en":"Kenya","code":"254"},
             {"cn":"基里巴斯","en":"Kiribati","code":"686"},
             {"cn":"朝鲜","en":"North Korea","code":"850"},
             {"cn":"韩国","en":"South Korea","code":"82"},
             {"cn":"科威特","en":"Kuwait","code":"965"},
             {"cn":"吉尔吉斯斯坦","en":"Kyrgyzstan","code":"996"},
             {"cn":"老挝","en":"Laos","code":"856"},
             {"cn":"拉脱维亚","en":"Latvia","code":"371"},
             {"cn":"黎巴嫩","en":"Lebanon","code":"961"},
             {"cn":"莱索托","en":"Lesotho","code":"266"},
             {"cn":"利比里亚","en":"Liberia","code":"231"},
             {"cn":"利比亚","en":"Libya","code":"218"},
             {"cn":"列支敦士登","en":"Liechtenstein","code":"423"},
             {"cn":"立陶宛","en":"Lithuania","code":"370"},
             {"cn":"卢森堡","en":"Luxembourg","code":"352"},
             {"cn":"澳门","en":"Macao","code":"853"},
             {"cn":"前南马其顿","en":"The Former Yugoslav Republic of Macedonia","code":"389"},
             {"cn":"马达加斯加","en":"Madagascar","code":"261"},
             {"cn":"马拉维","en":"Malawi","code":"265"},
             {"cn":"马来西亚","en":"Malaysia","code":"60"},
             {"cn":"马尔代夫","en":"Maldives","code":"960"},
             {"cn":"马里","en":"Mali","code":"223"},
             {"cn":"马耳他","en":"Malta","code":"356"},
             {"cn":"马绍尔群岛","en":"Marshall Islands","code":"692"},
             {"cn":"马提尼克","en":"Martinique","code":"596"},
             {"cn":"毛里塔尼亚","en":"Mauritania","code":"222"},
             {"cn":"毛里求斯","en":"Mauritius","code":"230"},
             {"cn":"马约特","en":"Mayotte","code":"269"},
             {"cn":"墨西哥","en":"Mexico","code":"52"},
             {"cn":"密克罗尼西亚","en":"Federated States of Micronesia","code":"691"},
             {"cn":"摩尔多瓦","en":"Moldova","code":"373"},
             {"cn":"摩纳哥","en":"Monaco","code":"377"},
             {"cn":"蒙古","en":"Mongolia","code":"976"},
             {"cn":"蒙特塞拉特","en":"Montserrat","code":"1664"},
             {"cn":"摩洛哥","en":"Morocco","code":"212"},
             {"cn":"莫桑比克","en":"Mozambique","code":"258"},
             {"cn":"纳米尼亚","en":"Namibia","code":"264"},
             {"cn":"瑙鲁","en":"Nauru","code":"674"},
             {"cn":"尼泊尔","en":"Nepal","code":"977"},
             {"cn":"荷兰","en":"Netherlands","code":"31"},
             {"cn":"荷属安的列斯","en":"Netherlands Antilles","code":"599"},
             {"cn":"新喀里多尼亚","en":"New Caledonia","code":"687"},
             {"cn":"新西兰","en":"New Zealand","code":"64"},
             {"cn":"尼加拉瓜","en":"Nicaragua","code":"505"},
             {"cn":"尼日尔","en":"Niger","code":"227"},
             {"cn":"尼日利亚","en":"Nigeria","code":"234"},
             {"cn":"纽埃","en":"Niue","code":"683"},
             {"cn":"诺福克岛","en":"Norfolk Island","code":"6723"},
             {"cn":"北马里亚纳","en":"Northern Mariana Islands","code":"1"},
             {"cn":"挪威","en":"Norway","code":"47"},
             {"cn":"阿曼","en":"Oman","code":"968"},
             {"cn":"巴基斯坦","en":"Pakistan","code":"92"},
             {"cn":"帕劳","en":"Palau","code":"680"},
             {"cn":"巴拿马","en":"Panama","code":"507"},
             {"cn":"巴布亚新几内亚","en":"Papua New Guinea","code":"675"},
             {"cn":"巴拉圭","en":"Paraguay","code":"595"},
             {"cn":"秘鲁","en":"Peru","code":"51"},
             {"cn":"菲律宾","en":"Philippines","code":"63"},
             {"cn":"波兰","en":"Poland","code":"48"},
             {"cn":"葡萄牙","en":"Portugal","code":"351"},
             {"cn":"波多黎各","en":"Puerto Rico","code":"1809"},
             {"cn":"卡塔尔","en":"Qatar","code":"974"},
             {"cn":"留尼汪","en":"Reunion","code":"262"},
             {"cn":"罗马尼亚","en":"Romania","code":"40"},
             {"cn":"俄罗斯","en":"Russia","code":"7"},
             {"cn":"卢旺达","en":"Rwanda","code":"250"},
             {"cn":"圣赫勒拿","en":"Saint Helena","code":"290"},
             {"cn":"圣基茨和尼维斯","en":"Saint Kitts and Nevis","code":"1869"},
             {"cn":"圣卢西亚","en":"Saint Lucia","code":"1758"},
             {"cn":"圣皮埃尔和密克隆","en":"Saint Pierre and Miquelon","code":"508"},
             {"cn":"圣文森特和格林纳丁斯","en":"Saint Vincent and the Grenadines","code":"1784"},
             {"cn":"萨摩亚","en":"Samoa","code":"685"},
             {"cn":"圣马力诺","en":"San Marino","code":"378"},
             {"cn":"圣多美和普林西比","en":"Sao Tome and Principe","code":"239"},
             {"cn":"沙特阿拉伯","en":"Saudi Arabia","code":"966"},
             {"cn":"塞内加尔","en":"Senegal","code":"221"},
             {"cn":"塞尔维亚和黑山","en":"Serbia and Montenegro","code":"381"},
             {"cn":"塞舌尔","en":"Seychelles","code":"248"},
             {"cn":"塞拉利","en":"Sierra Leone","code":"232"},
             {"cn":"新加坡","en":"Singapore","code":"65"},
             {"cn":"斯洛伐克","en":"Slovakia","code":"421"},
             {"cn":"斯洛文尼亚","en":"Slovenia","code":"386"},
             {"cn":"所罗门群岛","en":"Solomon Islands","code":"677"},
             {"cn":"索马里","en":"Somalia","code":"252"},
             {"cn":"南非","en":"South Africa","code":"27"},
             {"cn":"西班牙","en":"Spain","code":"34"},
             {"cn":"斯里兰卡","en":"Sri Lanka","code":"94"},
             {"cn":"苏丹","en":"Sudan","code":"249"},
             {"cn":"苏里南","en":"Suriname","code":"597"},
             {"cn":"斯瓦尔巴岛和扬马延岛","en":"Svalbard","code":"47"},
             {"cn":"斯威士兰","en":"Swaziland","code":"268"},
             {"cn":"瑞典","en":"Sweden","code":"46"},
             {"cn":"瑞士","en":"Switzerland","code":"41"},
             {"cn":"叙利亚","en":"Syria","code":"963"},
             {"cn":"塔吉克斯坦","en":"Tajikistan","code":"992"},
             {"cn":"坦桑尼亚","en":"Tanzania","code":"255"},
             {"cn":"泰国","en":"Thailand","code":"66"},
             {"cn":"巴哈马","en":"The Bahamas","code":"1242"},
             {"cn":"冈比亚","en":"The Gambia","code":"220"},
             {"cn":"多哥","en":"Togo","code":"228"},
             {"cn":"托克劳","en":"Tokelau","code":"690"},
             {"cn":"汤加","en":"Tonga","code":"676"},
             {"cn":"特立尼达和多巴哥","en":"Trinidad and Tobago","code":"1868"},
             {"cn":"突尼斯","en":"Tunisia","code":"216"},
             {"cn":"土耳其","en":"Turkey","code":"90"},
             {"cn":"土库曼斯坦","en":"Turkmenistan","code":"993"},
             {"cn":"特克斯和凯科斯群岛","en":"Turks and Caicos Islands","code":"1649"},
             {"cn":"图瓦卢","en":"Tuvalu","code":"688"},
             {"cn":"乌干达","en":"Uganda","code":"256"},
             {"cn":"乌克兰","en":"Ukraine","code":"380"},
             {"cn":"阿拉伯联合酋长国","en":"United Arab Emirates","code":"971"},
             {"cn":"英国","en":"United Kingdom","code":"44"},
             {"cn":"美国","en":"United States","code":"1"},
             {"cn":"乌拉圭","en":"Uruguay","code":"598"},
             {"cn":"乌兹别克斯坦","en":"Uzbekistan","code":"998"},
             {"cn":"瓦努阿图","en":"Vanuatu","code":"678"},
             {"cn":"委内瑞拉","en":"Venezuela","code":"58"},
             {"cn":"越南","en":"Vietnam","code":"84"},
             {"cn":"美属维尔京群岛","en":"Virgin Islands","code":"1340"},
             {"cn":"瓦利斯和富图纳","en":"Wallis and Futuna","code":"681"},
             {"cn":"也门","en":"Yemen","code":"967"},
             {"cn":"赞比亚","en":"Zambia","code":"260"},
             {"cn":"津巴布韦","en":"Zimbabwe","code":"263"},
             {"cn":"南苏丹","en":"South Sudan","code":"211"}
    ]
"""
    }
}
