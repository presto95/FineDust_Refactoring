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
  
  func observatory() -> Single<Result<String, Error>> {
    return .create { observer in
      let task = self.provider.request(.observatory) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIObservatoryResponse.self)
            let observatory = decoded.observatory ?? ""
            observer(.success(.success(observatory)))
          } catch {
            observer(.success(.failure(error)))
          }
        case let .failure(error):
          observer(.success(.failure(error)))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
  
  func recentTimeInfo() -> Single<Result<RecentDustInfo, Error>> {
    return .create { observer in
      let task = self.provider.request(.recentTimeInfo) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIInfoResponse.self)
            guard let recentResponse = decoded.items.first else { return }
            let dustInfo = RecentDustInfo(
              dustValue: .init(
                fineDust: recentResponse.fineDustValue,
                ultraFineDust: recentResponse.ultraFineDustValue
              ),
              dustGrade: .init(
                fineDust: DustGrade(rawValue: recentResponse.fineDustGrade) ?? .default,
                ultraFineDust: DustGrade(rawValue: recentResponse.ultraFineDustGrade) ?? .default
              ),
              updatedTime: DateFormatter.dateTime.date(from: recentResponse.dataTime) ?? Date()
            )
            observer(.success(.success(dustInfo)))
          } catch {
            observer(.success(.failure(error)))
          }
        case let .failure(error):
          observer(.success(.failure(error)))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
  
  func dayInfo() -> Single<Result<DustPair<[Hour: Int]>, Error>> {
    return .create { observer in
      let task = self.provider.request(.dayInfo) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIInfoResponse.self)
            let items = decoded.items
            var hourlyFineDustIntake: [Hour: Int] = [:]
            var hourlyUltraFineDustIntake: [Hour: Int] = [:]
            for item in items {
              let (hour, isMidnight) = self.hourInDustDate(item.dataTime)
              hourlyFineDustIntake[hour] = item.fineDustValue
              hourlyUltraFineDustIntake[hour] = item.ultraFineDustValue
              if isMidnight { break }
            }
            hourlyFineDustIntake.padIfHourIsNotFilled()
            hourlyUltraFineDustIntake.padIfHourIsNotFilled()
            let dustPair = DustPair<[Hour: Int]>(fineDust: hourlyFineDustIntake,
                                                 ultraFineDust: hourlyUltraFineDustIntake)
            observer(.success(.success(dustPair)))
          } catch {
            observer(.success(.failure(error)))
          }
        case let .failure(error):
          observer(.success(.failure(error)))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
  
  func dayInfo(from startDate: Date, to endDate: Date) -> Single<Result<DustPair<[Date: [Hour: Int]]>, Error>> {
    return .create { observer in
      let task = self.provider.request(.daysInfo(startDate: startDate, endDate: endDate)) { result in
        switch result {
        case let .success(response):
          do {
            let decoded = try self.validate(response, to: DustAPIInfoResponse.self)
            let items = decoded.items
            var hourlyFineDustIntakePerDate: [Date: [Hour: Int]] = [:]
            var hourlyUltraFineDustIntakePerDate: [Date: [Hour: Int]] = [:]
            for item in items {
              let (hour, _) = self.hourInDustDate(item.dataTime)
              let currentReferenceDate = self.referenceDate(item.dataTime)
              if !(startDate.start...endDate.start).contains(currentReferenceDate) { continue }
              if startDate.before(days: 1).start == currentReferenceDate { break }
              hourlyFineDustIntakePerDate.padIntakeOrEmpty(
                date: currentReferenceDate,
                hour: hour,
                intake: item.fineDustValue
              )
              hourlyUltraFineDustIntakePerDate.padIntakeOrEmpty(
                date: currentReferenceDate,
                hour: hour,
                intake: item.ultraFineDustValue
              )
            }
            let dustPair
              = DustPair<[Date: [Hour: Int]]>(fineDust: hourlyFineDustIntakePerDate,
                                              ultraFineDust: hourlyUltraFineDustIntakePerDate)
            observer(.success(.success(dustPair)))
          } catch {
            observer(.success(.failure(error)))
          }
        case let .failure(error):
          observer(.success(.failure(error)))
        }
      }
      return Disposables.create { task.cancel() }
    }
  }
}

// MARK: - Private Method

private extension DustAPIService {
  
  func validate<T>(_ response: Response,
                   to type: T.Type) throws -> T where T: XMLIndexerDeserializable {
    if response.statusCode == 200 {
      do {
        return try xmlParser.decodeData(response.data, to: T.self)
      } catch {
        throw error
      }
    } else {
      throw MoyaError.statusCode(response)
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
