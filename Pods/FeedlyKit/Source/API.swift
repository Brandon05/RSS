//
//  API.swift
//  FeedlyKit
//
//  Created by Hiroki Kumamoto on 3/10/16.
//  Copyright © 2016 Hiroki Kumamoto. All rights reserved.
//

import Alamofire

public protocol API {
    var url:        String               { get }
    var method:     Alamofire.HTTPMethod { get }
    func asURLRequest() throws -> URLRequest
}
