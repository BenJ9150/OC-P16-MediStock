//
//  ProcessInfo+IsPreview.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import Foundation

#if DEBUG

extension ProcessInfo {

    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

#endif
