//
//  DustObservatoryTarget.swift
//  FineDust
//
//  Created by Presto on 23/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Moya

enum DustAPI {
  
  case observatory
  
  case recentTimeInfo
  
  case dayInfo
  
  case daysInfo(startDate: Date, endDate: Date)
}

extension DustAPI: TargetType {
  
  var baseURL: URL {
    guard let url = URL(string: "http://openapi.airkorea.or.kr/openapi/services/rest") else {
      fatalError("invalid url")
    }
    return url
  }
  
  var path: String {
    switch self {
    case .observatory:
      return "/MsrstnInfoInqireSvc/getNearbyMsrstnList"
        .appending("?tmX=\(SharedInfo.shared.x)")
        .appending("&tmY=\(SharedInfo.shared.y)")
        .appending("&numOfRows=1")
        .appending("&pageNo=1")
        .appending("&serviceKey=\(serviceKey)")
    case .recentTimeInfo:
      let observatory = SharedInfo.shared.observatory.percentEncoded
      return "/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        .appending("?stationName=\(observatory)")
        .appending("&dataTerm=daily")
        .appending("&pageNo=1")
        .appending("&numOfRows=1")
        .appending("&serviceKey=\(serviceKey)")
        .appending("&ver=1.1")
    case .dayInfo:
      let observatory = SharedInfo.shared.observatory.percentEncoded
      return "/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        .appending("?stationName=\(observatory)")
        .appending("&dataTerm=daily")
        .appending("&pageNo=1")
        .appending("&numOfRows=24")
        .appending("&serviceKey=\(serviceKey)")
        .appending("&ver=1.1")
    case let .daysInfo(startDate, endDate):
      let observatory = SharedInfo.shared.observatory.percentEncoded
      let daysBetweenDates = Calendar.current
        .dateComponents([.day], from: startDate.start, to: endDate.start).day ?? 0
      return "/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        .appending("?stationName=\(observatory)")
        .appending("&dataTerm=daily")
        .appending("&pageNo=1")
        .appending("&numOfRows=\((daysBetweenDates + 2) * 24)")
        .appending("&serviceKey=\(serviceKey)")
        .appending("&ver=1.1")
    }
  }
  
  var method: Method {
    return .get
  }
  
  var sampleData: Data {
    return .init()
  }
  
  var task: Task {
    return .requestPlain
  }
  
  var headers: [String: String]? {
    return nil
  }
}

extension DustAPI {
  
  private var serviceKey: String {
    return "BfJjA4%2BuaBHhfAzyF2Ni6xoVDaf%2FhsZylifmFKdW3kyaZECH6c2Lua05fV%2F%2BYgbzPBaSl0YLZwI%2BW%2FK2xzO7sw%3D%3D"
  }
}
