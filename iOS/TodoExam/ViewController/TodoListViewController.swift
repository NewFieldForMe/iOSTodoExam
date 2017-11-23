//
//  TodoListViewController.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/19.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TodoListItemProtocol {
    @IBOutlet weak var todoTableView: UITableView!
    var disposeBag = DisposeBag()
    var todoItemList: [TodoModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        todoTableView.delegate = self
        todoTableView.dataSource = self
        /* Rxデータバインド */
//        todoList.delegate = nil
//        todoList.dataSource = nil
//        let service = APIService()
//        let items: Observable<[TodoModel]> = service.getTodoList()
//            items.bindTo(self.todoList.rx.items(cellIdentifier: "TodoListItemCell", cellType: TodoListItemCell.self)) { (row, element, cell) in
//                    cell.titleLabel?.text = element.title
//                }
//                .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let service = APIService()
        service.getTodoList().subscribe(onNext: { (items) in
            self.todoItemList = items
            self.todoTableView.reloadData()
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoItemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListItemCell.reuseIdentifier) as! TodoListItemCell

        cell.setup(model: self.todoItemList[indexPath.row], indexPath: indexPath)
        cell.delegate = self

        return cell
    }
    
    func didDeleteItem(index: IndexPath) {
        self.todoTableView.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
//        let service = APIService()
//        service.getTodoList().subscribe(onNext: { (items) in
//            self.todoItemList = items
//            self.todoTableView.reloadData()
//        }, onError: { (error) in
//            print(error)
//        }, onCompleted: {
//
//        }).disposed(by: disposeBag)
    }
}
