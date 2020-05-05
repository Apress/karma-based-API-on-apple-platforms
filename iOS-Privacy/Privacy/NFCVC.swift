//
//  NFCVC.swift
//  Privacy
//
//  Created by StuFF mc on 25.05.18.
//  Copyright © 2018 Pomcast.biz. All rights reserved.
//
import CoreNFC

class NFVC: PrivacyVC { //}, NFCNDEFReaderSessionDelegate { // NFCReaderSessionDelegate {
    
//    var session: NFCNDEFReaderSession?
//    var isoSession: NFCISO15693ReaderSession?
//
//
//    func readerSessionDidBecomeActive(_ session: NFCReaderSession) {
//        print("active")
//    }
//
//    func readerSession(_ session: NFCReaderSession, didDetect tags: [NFCTag]) {
//        print(tags)
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        // print(String(data:messages.first!.records.last!.payload, encoding:String.Encoding.ascii))
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        print(error)
//    }

    
    //    func readerSession(_ session: NFCReaderSession, didInvalidateWithError error: Error) {
    //        print(error)
    //    }
    
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
    //            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
    //            session?.begin()
    //            print(NFCISO15693ReaderSession.readingAvailable)
    ////            isoSession = NFCISO15693ReaderSession(delegate: self, queue: nil)
    ////            isoSession?.restartPolling()
    ////            isoSession?.begin()
    //        }
    //    }
    
}
