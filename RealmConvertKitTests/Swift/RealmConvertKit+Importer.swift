////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import XCTest
import Realm
import RealmSwift
import RealmConvertKit
import PathKit

@testable import RealmConvertKit

class RealmConvertKit_Importer: XCTestCase {
    
    let outputTestFolderName = "io.realm.test-output"
    let inputTestFolderName = "io.realm.test-input"
    
    var outputTestFolderPath:String {
        var path = Path(NSTemporaryDirectory())
        path = path + Path(self.outputTestFolderName)
        return String(path)
    }
    
    var inputTestFolderPath:String {
        var path = Path(NSTemporaryDirectory())
        path = path + Path(self.inputTestFolderName)
        return String(path)
    }
    
    let testRealmFileName = "businesses.realm"
    let csvAssetNames = ["businesses"]
    
    override func setUp() {
        super.setUp()
        
        // Create the input and output folders
        for path in [self.inputTestFolderPath, self.outputTestFolderName] {
            try! NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Copy our CSV test data to the input folder
        for fileName in self.csvAssetNames {
            let filePath = NSBundle(forClass: self.dynamicType).pathForResource(fileName, ofType: "csv")
            let destinationPath = Path(self.inputTestFolderPath) + Path(filePath!).lastComponent
            try! NSFileManager.defaultManager().copyItemAtPath(filePath!, toPath: String(destinationPath))
        }
    }
    
    override func tearDown() {
        // Create the input and output folders
        for path in [self.inputTestFolderPath, self.outputTestFolderName] {
            try! NSFileManager.defaultManager().removeItemAtPath(path)
        }
        
        super.tearDown()
    }
    
    func testCSVImport() {
        var filePaths = [String]()
        
        let folderContents = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.inputTestFolderPath)
        for file in folderContents {
            let filePath = Path(self.inputTestFolderPath) + Path(file)
            filePaths.append(String(filePath))
        }
        
        let generator = JSONTableSchemaGenerator(files: filePaths, output: "")
        let schema = try! generator.generate("csv")
        
        let destinationRealmPath = Path(self.outputTestFolderName) + Path(self.testRealmFileName)
        let dataImporter = DataImporter(files: filePaths, output: String(destinationRealmPath))
        try! dataImporter.`import`(schema)
        
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(String(destinationRealmPath)))
    }
    
}
