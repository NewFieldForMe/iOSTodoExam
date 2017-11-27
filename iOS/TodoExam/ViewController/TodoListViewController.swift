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

/*
 * Todo一覧画面
 */
class TodoListViewController: UIViewController {
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    var disposeBag = DisposeBag()
    var api: APIService?
    var datasource: TodoDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let backImage = UIImage(named: "plus_button")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        addButton.setImage(backImage!, for: UIControlState.normal)
        addButton.tintColor = UIColor.orange
        
        self.navigationItem.title = "Todo List"
        
        /* TableViewをRxデータバインド */
        datasource = TodoDataSource(api: api)
        
        // TableViewとデータソースのバインド
        TodoModel(api: api!).getList()
            .bind(to: todoTableView.rx.items(dataSource: datasource!))
            .disposed(by: self.disposeBag)
        
        // セルがセレクトされた場合は、編集画面に突入する
        todoTableView.rx.modelSelected(TodoModel.self)
            .subscribe(onNext: { [weak self](todo) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier:  TodoItemViewController.controllerIdentifer) as! TodoItemViewController
                controller.modifyTodo = todo
                self?.navigationController?.pushViewController(controller, animated: true)
            }).disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datasource?.refreshTodoList(tableView: self.todoTableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class TodoDataSource:NSObject, UITableViewDataSource, RxTableViewDataSourceType, SectionedViewDataSourceType {
    typealias Element = [TodoModel]
    var _todoModels: Element = []
    var api: APIService?
    var disposeBag = DisposeBag()
    
    init(api: APIService?) {
        self.api = api
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _todoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListItemCell.reuseIdentifier) as! TodoListItemCell
        
        cell.setup(model: _todoModels[indexPath.row], indexPath: indexPath)
        cell.completeEvent.subscribe(
            {[weak self] (index) in
                self?.refreshTodoList(tableView: tableView)
        }).disposed(by: cell.disposeBag)
        
        return cell
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<[TodoModel]>) {
        Binder(self) { [weak self](dataSource, element) in
                self?.refreshTodoList(tableView: tableView)
            }
            .on(observedEvent)
    }
    
    func model(at indexPath: IndexPath) throws -> Any {
        return _todoModels[indexPath.row]
    }
    
    func refreshTodoList(tableView: UITableView) {
        guard let api = self.api else {
            fatalError("api service isn't regist DI container.")
        }
        TodoModel(api: api).getList()
            .subscribe(onNext: {[weak self] (items) in
                self?._todoModels = items
                tableView.reloadData()
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
}
