//
//  unusedCode.swift
//  Complete
//
//  Created by Chuck Dibilio on 12/10/18.
//  Copyright © 2018 Chuck Dibilio. All rights reserved.
//

import Foundation



// --- Set up login screen when user was not logged in in app delegate ---
//            window?.makeKeyAndVisible()
//            window?.rootViewController?.present(logInVC, animated: true, completion: nil)





// --- Long Gesture to move cells ---
//// Set up long press gesture recognizer for drag and drop feature
//let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(longPress:)))
//self.taskTblView.addGestureRecognizer(longPress)
//// Action method for gesture recognizer
//@objc func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
//    let state = longPress.state
//    let location = longPress.location(in: taskTblView)
//    guard let indexPath = taskTblView.indexPathForRow(at: location) else {
//        cleanUp()
//        return
//        
//    }
//    
//    switch state {
//    case .began:
//        sourceIndexPath = indexPath
//        guard let cell = taskTblView.cellForRow(at: indexPath) else {return}
//        
//        // Take a snapshot of the selected row using helper method.  See below method
//        snapshot = self.customSnapshotFromView(inputView: cell)
//        guard let snapshot = self.snapshot else {return}
//        var center = cell.center
//        snapshot.center = center
//        snapshot.alpha = 0.0
//        
//        taskTblView.addSubview(snapshot)
//        
//        UIView.animate(withDuration: 0.25, animations: {
//            center.y = location.y
//            snapshot.center = center
//            snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//            snapshot.alpha = 0.98
//            cell.alpha = 0.0
//        }, completion: { (finished) in
//            cell.isHidden = true
//            
//        })
//        break
//        
//    case .changed:
//        guard let snapshot = self.snapshot else {return}
//        var center = snapshot.center
//        center.y = location.y
//        snapshot.center = center
//        guard let sourceIndexPath = self.sourceIndexPath else {return}
//        
//        if indexPath != sourceIndexPath {
//            // *Trial run*
//            if indexPath.section == sourceIndexPath.section {
//                
//                // Update Data structures
//                var taskArray = allTasks[categories[indexPath.section]]
//                taskArray!.swapAt(indexPath.row, sourceIndexPath.row)
//                allTasks[categories[indexPath.section]] = taskArray
//                
//                // TODO: Update in database
//                
//                // Update UI
//                taskTblView.moveRow(at: sourceIndexPath, to: indexPath)
//                self.sourceIndexPath = indexPath
//            }
//                
//                // Changed Sections
//            else {
//                debugPrint(indexPath.section)
//                // Get Categories Arrays
//                var indexTaskArray = allTasks[categories[indexPath.section]]
//                var sourceTaskArray = allTasks[categories[sourceIndexPath.section]]
//                
//                var task = indexTaskArray![indexPath.row]
//                
//                // Update Data Structure
//                // Remove
//                
//                sourceTaskArray!.remove(at: sourceIndexPath.row)
//                allTasks[categories[sourceIndexPath.section]] = sourceTaskArray!
//                
//                debugPrint(allTasks)
//                // Insert
//                indexTaskArray!.insert(task, at: indexPath.row)
//                allTasks[categories[indexPath.section]] = indexTaskArray!
//                debugPrint(allTasks)
//                updateTaskTableWithoutReloading()
//                
//                // Update Table
//                // remove
//                taskTblView.beginUpdates()
//                debugPrint("above remove from table")
//                var deleteIndexPathArray = [IndexPath]()
//                deleteIndexPathArray.append(sourceIndexPath)
//                taskTblView.deleteRows(at: deleteIndexPathArray, with: .fade)
//                debugPrint("below remove from table")
//                
//                // Insert
//                var addIndexPathArray = [IndexPath]()
//                addIndexPathArray.append(indexPath)
//                taskTblView.insertRows(at: addIndexPathArray, with: .fade)
//                taskTblView.endUpdates()
//                
//                // Update Gesture Variables
//                self.sourceIndexPath = indexPath
//            }
//        }
//        break
//        
//    // Clean Up
//    default:
//        guard let cell = taskTblView.cellForRow(at: indexPath) else {return}
//        guard let snapshot = self.snapshot else {return}
//        cell.isHidden = false
//        cell.alpha = 0.0
//        UIView.animate(withDuration: 0.25, animations: {
//            snapshot.center = cell.center
//            snapshot.transform = CGAffineTransform.identity
//            snapshot.alpha = 0
//            cell.alpha = 1
//        }) { (finsihed) in
//            self.cleanUp()
//        }
//        break
//    }
//}
//
//// Helper method of gesture recognizer for snapshot
//private func customSnapshotFromView(inputView: UIView) -> UIView? {
//    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
//    if let CurrentContext = UIGraphicsGetCurrentContext() {
//        inputView.layer.render(in: CurrentContext)
//    }
//    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//        UIGraphicsEndImageContext()
//        return nil
//    }
//    UIGraphicsEndImageContext()
//    let snapshot = UIImageView(image: image)
//    snapshot.layer.masksToBounds = false
//    snapshot.layer.cornerRadius = 0
//    snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
//    snapshot.layer.shadowRadius = 5
//    snapshot.layer.shadowOpacity = 0.4
//    return snapshot
//}
//
//// Cleaner Method Clean Up
//private func cleanUp() {
//    self.sourceIndexPath = nil
//    snapshot?.removeFromSuperview()
//    self.snapshot = nil
//}


//// Testing for delete tasks
//var count = 0
//var ranks = [Int]()
//let total = 88
//count = count + 1
//for (_, taskArray) in self.allTasks {
//    for t in taskArray {
//        if t._rank == currentTask._rank {
//            debugPrint("duplicate: \(t._id) , \(currentTask._id)")
//        }
//        if t._rank > total {
//            debugPrint("Rank Too High: \(t._rank)")
//        }
//    }
//}
//
//for (_, taskArray) in self.allTasks {
//    for t in taskArray {
//        if !ranks.contains(t._rank) {
//            ranks.append(t._rank)
//            ranks.sort()
//        }
//    }
//}
//
//
//if count == total {
//    debugPrint("in skips")
//    for i in 0...ranks.count {
//        if i == ranks.count - 1 || i == ranks.count {
//            var nothing = 0
//        }
//        else {
//            if ranks[i] != ranks[i+1] - 1 {
//                debugPrint("Skip: \(ranks[i]) , \(ranks[i+1])")
//                debugPrint()
//            }
//        }
//    }
//}
