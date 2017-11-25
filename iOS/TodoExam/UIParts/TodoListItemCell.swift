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

class TodoListItemCell: UITableViewCell {
    private let completeSubject = PublishSubject<IndexPath>()
    var completeEvent: Observable<IndexPath> { return completeSubject }
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
                            self.completeSubject.onNext(self.indexPath!)
                        case .error(let error):
                            self.completeSubject.onError(error)
                        }
                    }).disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
    }
}

