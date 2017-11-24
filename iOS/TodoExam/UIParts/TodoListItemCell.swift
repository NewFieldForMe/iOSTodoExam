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
    func didDeleteTodoItem(index: IndexPath)
}

class TodoListItemCell: UITableViewCell {
    private let completeSubject = PublishSubject<IndexPath>()
    var completeEvent: Observable<IndexPath> { return completeSubject }
    var delegate: TodoListItemProtocol?
    var disposeBag = DisposeBag()
    var indexPath: IndexPath?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup(model: TodoModel, indexPath: IndexPath){
        self.todo = model
        self.indexPath = indexPath
        self.titleLabel.text = self.todo?.title
        self.disposeBag = DisposeBag()
        
        completeButton.rx.tap.subscribe(
            onNext: { (sender) in
                self.todo!.delete()
                    .subscribe({ (result: CompletableEvent) in
                        switch result {
                        case .completed:
                            self.delegate?.didDeleteTodoItem(index: self.indexPath!)
                            self.completeSubject.onNext(self.indexPath!)
                            self.completeSubject.onCompleted()
                        case .error(let error):
                            self.completeSubject.onError(error)
                        }
                    }).disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
    }
}

