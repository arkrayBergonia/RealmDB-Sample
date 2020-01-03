//
//  MemoData.swift
//  SaveLoadImage
//
//  Created by Francis Jemuel Bergonia on 1/3/20.
//  Copyright © 2020 Arkray PHM. All rights reserved.
//

import Foundation
import RealmSwift

class MemoData: Object {
    @objc dynamic var memoText: String = ""
    @objc dynamic var memoImage: Data? = nil
}
