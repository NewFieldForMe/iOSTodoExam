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

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    var disposeBag = DisposeBag()
    var todoItemList: [TodoModel] = []
    var api: APIService?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backImage = UIImage(named: "plus_button")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        addButton.setImage(backImage!, for: UIControlState.normal)
        addButton.tintColor = UIColor.orange
        
        todoTableView.delegate = self
        todoTableView.dataSource = self
        self.navigationItem.title = "Todo List"
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
        refreshTodoList()
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
        cell.completeEvent.subscribe(
            onNext: {(index) in
                self.refreshTodoList()
        }).disposed(by: cell.disposeBag)

        return cell
    }
    
    func refreshTodoList() {
        guard let api = self.api else {
            fatalError("api service isn't regist DI container.")
        }
        TodoModel(api: api).getList()
            .subscribe(onNext: { (items) in
                self.todoItemList = items
                self.todoTableView.reloadData()
            }, onError: { (error) in
                print(error)
            }, onCompleted: {
            }).disposed(by: disposeBag)
    }
}

