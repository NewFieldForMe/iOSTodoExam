//
//  SwinjectStoryboardExtension.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/24.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import Foundation
import SwinjectStoryboard

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(APIService.self) { _ in API() }
        defaultContainer.register(TodoModel.self) { r in
            TodoModel(api: r.resolve(APIService.self)!)
        }
        defaultContainer.storyboardInitCompleted(TodoListViewController.self) { r, c in
            c.api = r.resolve(APIService.self)
        }
        // ViewControllerに登録する
        defaultContainer.storyboardInitCompleted(TodoListViewController.self) { r, c in
            c.api = r.resolve(APIService.self)
        }
        defaultContainer.storyboardInitCompleted(TodoItemViewController.self) { r, c in
            c.api = r.resolve(APIService.self)
        }
    }
}
