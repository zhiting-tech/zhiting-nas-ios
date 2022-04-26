//
//  StoragePoolViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/6/30.
//

import UIKit

class StoragePoolViewController: BaseViewController {
    
    var currentStoragePoolName = ""
    var currentStoragePoolModel = StoragePoolModel()
    
    private lazy var headerView = StoragePoolHeadView(model: currentStoragePoolModel).then {
        $0.backgroundColor = .custom(.blue_427aed)
    }

    private lazy var collectionView = StoragePoolCollectionView(model: currentStoragePoolModel).then {
        $0.backgroundColor = .clear
    }

    private lazy var reSetNameView = SetNameAlertView(setNameType: .resetStoragePoolName, currentName: currentStoragePoolName)

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        getDatas()
    }
    
    override func setupViews() {
        view.addSubview(headerView)
        view.addSubview(collectionView)
        headerView.actionCallback = {[weak self] action in
            guard let self = self else {
                return
            }
            switch action {
            case 0:
                self.navigationController?.popViewController(animated: true)
            case 1:
                print("删除")
                self.deletePool()
            case 2:
                print("重命名")
                self.reSetNameView = SetNameAlertView(setNameType: .resetStoragePoolName, currentName: self.currentStoragePoolName)
                
                //重命名callBack
                self.reSetNameView.setNameCallback = { [weak self] name in
                    guard let self = self else {
                        return
                    }
                    LoadingView.show()
                    NetworkManager.shared.editStoragePool(name: self.currentStoragePoolName, new_name: name) {[weak self] response in
                        guard let self = self else {
                            return
                        }
                        LoadingView.hide()
                        self.reSetNameView.removeFromSuperview()
                        self.currentStoragePoolName = name
                        self.getDatas()
                        
                    } failureCallback: {[weak self] code, err in
                        guard let self = self else {
                            return
                        }
                        LoadingView.hide()
                        self.showToast(err)
                    }
                }
                
                SceneDelegate.shared.window?.addSubview(self.reSetNameView)
            case 3:
                print("硬盘数量")
                let alert = HardDisksInfoAlert(hardDisks: self.currentStoragePoolModel.pv)
                SceneDelegate.shared.window?.addSubview(alert)

            default:
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        


        
        collectionView.actionCallback = {[weak self] action,index in
            guard let self = self else {
                return
            }
            switch action {
            case 1:
                print("添加分区")
                let addPartitionController = AddPartitionController()
                addPartitionController.currentType = .add
                addPartitionController.currentStoragePoolName = self.currentStoragePoolName
                self.navigationController?.pushViewController(addPartitionController, animated: true)
            case 2:
                let model = self.currentStoragePoolModel.lv[index]
                let addPartitionController = AddPartitionController()
                addPartitionController.currentType = .edit
                addPartitionController.currentModel = model
                addPartitionController.currentStoragePoolName = self.currentStoragePoolName
                self.navigationController?.pushViewController(addPartitionController, animated: true)
                
            default:
                self.getDatas()
                print("区域外")
            }
            
        }
        
    }

    override func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(270))
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(-ZTScaleValue(20))
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(20))
        }
    }

    private func getDatas(){
        LoadingView.show()
        NetworkManager.shared.storagePoolDetail(name: currentStoragePoolName) { [weak self] response in
            guard let self = self else {return}
            LoadingView.hide()
            self.currentStoragePoolModel = response
            self.collectionView.setModel(model: self.currentStoragePoolModel)
            self.headerView.setModel(model: self.currentStoragePoolModel)
        } failureCallback: { [weak self] code, err in
            LoadingView.hide()
            self?.showToast(err)
        }

    }
}


extension StoragePoolViewController {
    private func deletePool(){
        let tipsAlert = TipsAlertView(title: "删除确认", detail: "确认删除该存储池吗？删除需要一些时间处理，且删除后，该存储池下的所有分区及其文件夹/文件都全部删除", warning: "操作不可撤销，请谨慎操作！", sureBtnTitle: "确定删除")
        tipsAlert.sureCallback = { [weak self] in
            guard let self = self else { return }

            tipsAlert.sureBtn.buttonState = .waiting
            NetworkManager.shared.deleteStoragePool(name: self.currentStoragePoolName) {[weak self] response in
                guard let self = self else { return }
                tipsAlert.removeFromSuperview()
                //弹框提示后台处理
                let singleTipsAlert = SingleTipsAlertView(detail: "正在删除存储池，已为您后台运行，可返回列表刷新查看。", detailColor: .custom(.black_3f4663), sureBtnTitle: "确定")
                singleTipsAlert.sureCallback = { [weak self] in
                    guard let self = self else { return }
                    singleTipsAlert.removeFromSuperview()
                    self.navigationController?.popViewController(animated: true)
                }
                SceneDelegate.shared.window?.addSubview(singleTipsAlert)

//                self.showToast("删除成功")
//                self.navigationController?.popViewController(animated: true)
            } failureCallback: { [weak self] code, err in
                guard let self = self else { return }
                self.showToast(err)
                tipsAlert.sureBtn.buttonState = .normal
            }

        }
        
        SceneDelegate.shared.window?.addSubview(tipsAlert)
    }
    
}
