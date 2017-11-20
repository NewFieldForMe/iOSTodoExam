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

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var todoList: UITableView!
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        todoList.delegate = self
        todoList.dataSource = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItemCell") as! TodoListItemCell

        cell.titleLabel.text = "hogehoge"

        return cell
    }
}
