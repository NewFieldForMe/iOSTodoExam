//
//  TodoListItemCell.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/20.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift

protocol TodoListItemProtocol {
    // デリゲートメソッド定義
    func didDeleteItem(index: IndexPath)
}

class TodoListItemCell: UITableViewCell {
    
    var delegate: TodoListItemProtocol?
    var disposeBag = DisposeBag()
    var indexPath: IndexPath?

    @IBOutlet weak var titleLabel: UILabel!
    static let reuseIdentifier = "TodoListItemCell"
    var todo: TodoModel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        todo = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(model: TodoModel){
        self.init(style: .default, reuseIdentifier: nil)
        todo = model
    }
    
    func setup(model: TodoModel, indexPath: IndexPath){
        self.todo = model
        self.indexPath = indexPath
        self.titleLabel.text = self.todo?.title
    }
    
    @IBAction func complete(sender: AnyObject) {
        guard let index = self.indexPath else {
            return
        }
        let service = APIService()
//        service.postTodo(parameters: (todo?.toJSON())!)
        service.deleteTodo(id: todo!.id.description)
        .subscribe({ (result: CompletableEvent) in
            switch result {
            case .completed:
                self.delegate?.didDeleteItem(index: index)
            case .error(let value):
                print("error: \(value)")
            }
        }).disposed(by: disposeBag)
    }
}

