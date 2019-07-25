//
//  DustAPIService.swift
//  FineDust
//
//  Created by Presto on 23/07/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Moya
import RxSwift
import SWXMLHash

final class DustAPIService: DustAPIServiceType {
  
  private let provider = MoyaProvider<DustAPI>()
  
  private let xmlParser: XMLParserType
  
  init(xmlParser: XMLParserType = XMLParser()) {
    self.xmlParser = xmlParser
  }
  
  func observatory() -> Observable<String> {
    return .create { observer in
      self.provider.request(.observatory) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIObservatoryResponse.self)
            let observatory = decoded.observatory ?? ""
            observer.onNext(observatory)
            observer.onCompleted()
          } catch {
            observer.onError(error)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func recentTimeInfo() -> Observable<RecentDustInfo> {
    return .create { observer in
      self.provider.request(.recentTimeInfo) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIInfoResponse.self)
            guard let recentResponse = decoded.items.first else { return }
            let dustInfo = RecentDustInfo(
              fineDustValue: recentResponse.fineDustValue,
              ultraFineDustValue: recentResponse.ultrafineDustValue,
              fineDustGrade: DustGrade(rawValue: recentResponse.fineDustGrade) ?? .default,
              ultraFineDustGrade: DustGrade(rawValue: recentResponse.ultrafineDustGrade) ?? .default,
              updatedTime: DateFormatter
                .dateTime.date(from: recentResponse.dataTime) ?? Date()
            )
            observer.onNext(dustInfo)
            observer.onCompleted()
          } catch {
            observer.onError(error)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func dayInfo() -> Observable<(HourIntakePair, HourIntakePair)> {
    return .create { observer in
      self.provider.request(.dayInfo) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIInfoResponse.self)
            let items = decoded.items
            var hourlyFineDustIntake: HourIntakePair = [:]
            var hourlyUltraFineDustIntake: HourIntakePair = [:]
            for item in items {
              let (hour, isMidnight) = self.hourInDustDate(item.dataTime)
              hourlyFineDustIntake[hour] = item.fineDustValue
              hourlyUltraFineDustIntake[hour] = item.ultrafineDustValue
              if isMidnight { break }
            }
            hourlyFineDustIntake.padIfHourIsNotFilled()
            hourlyUltraFineDustIntake.padIfHourIsNotFilled()
            observer.onNext((hourlyFineDustIntake, hourlyUltraFineDustIntake))
            observer.onCompleted()
          } catch {
            observer.onError(error)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func dayInfo(from startDate: Date, to endDate: Date) -> Observable<(DateHourIntakePair, DateHourIntakePair)> {
    return .create { observer in
      self.provider.request(.daysInfo(startDate: startDate, endDate: endDate)) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIInfoResponse.self)
            let items = decoded.items
            var hourlyFineDustIntakePerDate: DateHourIntakePair = [:]
            var hourlyUltraFineDustIntakePerDate: DateHourIntakePair = [:]
            for item in items {
              let (hour, _) = self.hourInDustDate(item.dataTime)
              let currentReferenceDate = self.referenceDate(item.dataTime)
              // 구간 내에 포함되지 않는다면 해당 데이터는 필요 없으므로 컨티뉴
              if !(startDate.start...endDate.start).contains(currentReferenceDate) { continue }
              // 시작 날짜의 전날 시작 날짜와 현재 요소의 시작 날짜가 같으면 필요한 처리를 다 한 것이므로 브레이크
              if startDate.before(days: 1).start == currentReferenceDate { break }
              hourlyFineDustIntakePerDate
                .padIntakeOrEmpty(date: currentReferenceDate,
                                  hour: hour,
                                  intake: item.fineDustValue)
              hourlyUltraFineDustIntakePerDate
                .padIntakeOrEmpty(date: currentReferenceDate,
                                  hour: hour,
                                  intake: item.ultrafineDustValue)
            }
            observer.onNext((hourlyFineDustIntakePerDate, hourlyUltraFineDustIntakePerDate))
          } catch {
            observer.onError(error)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
}

// MARK: - Private Method

private extension DustAPIService {
  
  func validate<T>(_ response: Response, to type: T.Type) throws -> T where T: XMLIndexerDeserializable {
    let statusCode = response.statusCode
    if statusCode == 200 {
      let data = response.data
      do {
        let decoded = try xmlParser.decodeData(data, to: T.self)
        return decoded
      } catch {
        throw error
      }
    } else {
      throw NSError(domain: "", code: 0, userInfo: nil)
    }
  }
  
  func hourInDustDate(_ dateString: String) -> (hour: Hour, isMidnight: Bool) {
    if let dataTimeToDate = DateFormatter.dateTime.date(from: dateString) {
      let hourToString = DateFormatter.hour.string(from: dataTimeToDate)
      let hourToInt = Int(hourToString) ?? 0
      return (Hour(rawValue: hourToInt) ?? .default, false)
    } else {
      return (Hour(rawValue: 0) ?? .default, true)
    }
  }
  
  func referenceDate(_ dateString: String) -> Date {
    if let dateTimeToDate = DateFormatter.dateTime.date(from: dateString) {
      return dateTimeToDate.start
    } else {
      let halfDataTime = dateString.components(separatedBy: " ").first ?? ""
      let halfDataTimeToDate = DateFormatter.date.date(from: halfDataTime)
      let nextHalfDataTime = halfDataTimeToDate?.after(days: 1)
      return nextHalfDataTime?.start ?? Date()
    }
  }
}
