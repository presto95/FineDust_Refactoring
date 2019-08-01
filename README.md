# FineDust_Refactoring

**Boostcamp 3기 프로젝트 [내안의먼지](https://github.com/boostcamp3-iOS/team-c2) 리팩토링**

🔥🔥🔥진행중🔥🔥🔥

## 목적

- MVVM 아키텍처 패턴 및 Rx 적용
- 전체적인 리팩토링

## 라이브러리

### Reactive Extensions

- RxSwift
- RxCocoa
- RxRelay
- RxDataSources
- RxCoreLocation
- RxOptional

### Network

- Moya

### Persistence

- RealmSwift

### UI

- SnapKit
- SVProgressHUD
- NotificationBannerSwift

### Misc.

- Then
- SWXMLHash

## 1차 리팩토링

**빌드 가능한 코드 작성**

### MVC -> MVVM

가장 가시적인 차이는 MVC의 Controller에 위치한 비즈니스 로직을 MVVM의 ViewModel로 옮기는 것이라고 할 수 있을 것이다. 

ViewController에 있던 코드 중 UI와 관련된 것 (레이어 생성, 그래프 애니메이션 등) 은 ViewController에 남겨두고, 비즈니스 로직과 관련된 것은 ViewModel로 옮겼다. 또한 ViewController에 프로퍼티의 형태로 존재했던 상태값도 Relay를 사용하여 ViewModel로 옮겼다.

그래프를 나타내는 View의 경우 Delegate Pattern을 사용하여 값을 전달받고 화면에 나타냈는데, 이것 대신 Reactive를 확장하여 리액티브하게 값을 받을 수 있도록 하였다. 이 값은 ViewModel의 Input으로 들어가고 Relay에 accept되며, ViewModel에서 적절하게 처리한 후 View가 이 값을 감지하여 처리할 수 있도록 하였다.

```swift
// Before
protocol ValueGraphViewDataSource: class {
  
  var intakes: [Int] { get }
}
// After
extension Reactive where Base: ValueGraphView {
  
  var intakes: Binder<[Int]> {
    return .init(base) { target, intakes in
      target.viewModel.setIntakes(intakes)
    }
  }
}
```

ViewModel의 구조는 kickstarter/ios-oss를 참고하였다. ViewModel의 Input과 Output의 명세를 정의한 프로토콜을 정의하며, 익스텐션을 통해 이를 구현한다.

```swift
protocol StickGraphViewModelInputs {
  
  func setIntakes(_ intakes: [Int])
}

protocol StickGraphViewModelOutputs {
  
  var weekIntake: Observable<[Int]> { get }
  
  var maxIntake: Observable<Int> { get }
}

final class StickGraphViewModel {
  
  private let intakesRelay = PublishRelay<[Int]>()
}

extension StickGraphViewModel: StickGraphViewModelInputs {
  
  func setIntakes(_ intakes: [Int]) {
    intakesRelay.accept(intakes)
  }
}

extension StickGraphViewModel: StickGraphViewModelOutputs {
  
  var weekIntake: Observable<[Int]> {
    return intakesRelay.asObservable()
  }
  
  var maxIntake: Observable<Int> {
    return weekIntake
      .map { $0.max() ?? 1 }
  }
}
```

Driver를 적극 활용하였다. 애초에 Relay도 에러를 받을 수 없으므로, 이것에서 비롯된 Observable을 Driver로 변환하여 사용하는 것은 문제가 없을 것이라 생각하였다.

```swift
func bindViewModel() {
  viewModel.pieGraphViewDataSource.asDriver(onErrorJustReturn: (0, 0))
    .drive(ratioPieGraphView.rx.dataSource)
    .disposed(by: disposeBag)
  
  viewModel.stickGraphViewDataSource.asDriver(onErrorJustReturn: (0, 0))
    .drive(ratioStickGraphView.rx.dataSource)
    .disposed(by: disposeBag)
}
```

### Service? Manager? DI와 DIP를 다시 이해하기

부스트캠프 과정에서 DI를 공부했지만 제대로 이해하지 못하고 그냥 어떤 구체 클래스에 대하여 이것의 명세를 정의하는 프로토콜을 정의하고, 이 프로토콜을 준수하는 구체 클래스 인스턴스를 주입받게 하여 코드의 결합도를 낮춘다고 외우다시피 했다.

또한 Service와 Manager라는 용어에 대해서 서로 계층적 차이가 있으며, Service의 계층은 Manager의 그것보다 높은 것이라고 이해하고 프로젝트를 진행했다.

하지만 지금에 와서 이를 다시 생각해봤을 때 잘못 이해하고 프로젝트를 진행했다는 생각밖에 들지 않았다.

---

먼저 Service와 Manager. 이 둘은 아무런 관계도 없다. 단어 뜻 그대로, Service는 어떠한 기능을 제공하므로 공통된 비즈니스 로직을 모아두어 다른 곳에서 사용할 수 있는 것이 되겠고, Manager는 어떠한 것을 관리하므로 로직을 제공한다기보다는 특정 객체를 관리하는 역할을 맡게 된다.

그리고 DI (의존성 주입) 과 SOLID의 DIP (의존성 역전 원칙) 에 대하여 다시 한번 생각해볼 수 있었다. DIP에 따라 모듈은 구체 구현에 의존하지 않고 그것의 추상화에 의존해야 한다는 것에 따라, 습관적으로 구체 클래스에 대한 프로토콜을 정의하여 사용하는 것은 잘못된 것이 아니라고 생각했다.

하지만 각 화면 (Storyboard Scene) 에 대한 서비스, 말하자면 `FeedbackService` 와 같은 것은 Service의 역할과는 어울리지 않다고 생각했다. 이것이 여러 화면에서 사용된다면 따로 분리되어야 하겠지만, 특정 화면에서만 사용하는 것이라면 굳이 Service로 분리하지 않고 해당 화면의 ViewModel에서 private method로 정의하여 사용해도 되겠다는 생각을 했다.

 이에 따라 `FeedbackService` , `JSONManager` 를 삭제하고 해당 클래스에 위치했던 로직을 그것을 사용하는 화면에 대한 비즈니스 로직을 정의하는 클래스에 private method로 정의하여 사용하였다.

### Singleton Pattern의 남용

기존에 `NetworkManager` , `CoreDataManager` , `GeocodeManager` , `LocationManager` , `XMLDecoder` 등 비즈니스 로직을 분리한 대부분의 클래스를 싱글턴 패턴을 사용하여 인스턴스를 생성하도록 하였다. 이들은 대부분 비즈니스 로직 상에서 최하위 계층에 위치하며, 상위 비즈니스 로직을 담은 클래스가 이 클래스의 싱글턴 객체를 사용하는 방식으로 구현되어 있었다.

하지만 리팩토링 과정에서 이들의 구현을 바라봤을 때, 이것이 싱글턴 패턴이 의도하는 것인가? 이러한 클래스가 앱 전체에서 하나의 인스턴스만 존재한다는 것을 보장해야 할 필요가 있는가? 하는 생각을 하지 않을 수 없었다. 싱글턴 패턴을 사용하여 이들을 구현한 것은 단지 편의를 위해서였지, 디자인 패턴이 의도하는 것을 실현하기 위해서가 아니었다. 말하자면, 앱 전체에서 하나의 인스턴스만이 존재해야 할 필요가 없었다는 것이다.

---

결과적으로 `LocationManager` 이외의 서비스 클래스들은 모두 싱글턴 패턴을 쓰지 않는 형태로 리팩토링되었다. `LocationManager` 의 경우 앱 전체에서 하나의 `CLLocationManager` 가 위치 관련 작업을 관리해야 하기 때문에 싱글턴 패턴을 사용하여 구현하였다.

### Network Layer

부스트캠프 과정에서는 라이브러리를 사용할 수 없었으므로 URLSession을 사용하여 요청하고 `Data` 를 받아아오는 `NetworkManager` , 이를 사용하여 미세먼지 공공 API에 접근하는 `DustObservatoryManager` , `DustInfoManager` , `DustInfoService` 를 정의하여 미세먼지 정보를 받아오기 위한 네트워크 요청 작업을 수행했다.

하지만 이는 위에서 언급한 Service와 Manager에 대한 잘못된 이해와, 책임 분리가 잘 되지 않은 잘못된 설계라는 생각을 하게 되었다.

먼저 `DustInfoManager` 의 경우 특정 엔드포인트에 요청을 보내어 파싱된 응답을 받아오고, `DustInfoService` 에서 이를 사용해서 앱에서 실제로 사용하는 데이터의 형태로 변환하는데, 이 경우 `DustInfoManager` 에 위치한 로직은 `DustInfoService` 의 private method로 존재하면 그만이다.

또한 Moya의 도움을 받아 Network Layer를 쉽게 구성했다. 하지만 이는 Swift의 열거형의 이점을 이용하여 타입 안전을 누리기 위해 설계되었고, 엔드포인트 개수가 많아지는 경우 흔한 OCP 위반 위험을 안게 된다.

이러한 경우까지 생각한 코드를 작성하지는 않았지만, 열거형 대신 각각의 엔드포인트 당 `TargetType` 를 준수하는 각 구조체를 정의하면 OCP 위반 위험을 없앨 수 있을 것이다.

### 특정 주제와 연관된 값 처리

일반적으로 미세먼지 관련 값과 초미세먼지 관련 값은 쌍을 이루어 함께 넘겨진다.

해당 수치와 관련된 값의 타입은 `Int`, `[Int]`, `[Hour: Int]` , `[Date: [Hour: Int]]` 등으로 다양하며, `function(fineDustIntake:ultraFineDustIntake:)`  처럼 따로 넘겨졌다.

이렇게 값을 따로 넘겨주니 처리하는 로직에 대한 가독성이 좋지 않았다.

---

이를 해결하기 위해 미세먼지 관련 값과 초미세먼지 관련 값을 담을 수 있는 구조체를 하나 정의하였다.

```swift
struct DustPair<Value> {
  
  let fineDust: Value
  
  let ultraFineDust: Value
}
```

'관련 값' 이라는 개념을 제네릭으로 구현하였다. 

이를 사용하여 `(Int, Int)` 는 `DustPair<Int>` , `([Hour: Int], [Hour: Int])` 는 `DustPair<[Hour: Int]>` 로 대체할 수 있었다.

미세먼지 및 초미세먼지 관련 값을 한 곳에서 관리할 수 있게 되었으며, 처리하는 로직에 대한 가독성을 높일 수 있었다.

아래는 이를 사용하여 리팩토링된 코드의 예시이다.

```swift
// Before
func requestTodayIntake(completion: @escaping (Int?, Int?, Error?) -> Void) { ... }
// After
func todayIntake() -> Observable<DustPair<Int>> { ... }

// Before
func totalHourlyIntake(_ hourlyFineDustIntake: [Hour: Int], 
                       _ hourlyUltraFineDustIntake: [Hour: Int],
                       _ hourlyDistance: [Hour: Int]) -> (Int, Int) { ... }
// After
func totalHourlyIntake(_ hourlyIntake: DustPair<[Hour: Int]>,
                       _ hourlyDistance: [Hour: Int]) -> DustPair<Int> { ... }
```

### 프로젝트 디렉토리 구조

아래는 기존 프로젝트의 디렉토리 구조이다.

앱의 기능을 기준으로 분류하여 디렉토리 구조를 구성했는데, 프로젝트의 크기가 커지면 기능도 많아질 것이고, 결국 이러한 구조는 효율적이지 않을 것이라 생각하였다.

```text
FineDust
|-- Common
|-- Core Data
|-- Dust
|-- Extension
|-- Feedback
|-- HealthKit
|-- Intake
|-- JSON
|-- Main
|-- Model
|-- Response
|-- SWXMLHash
|-- Statistics
|-- Supporting Files
|-- SwiftGen
|-- XML
```

아래는 리팩토링한 프로젝트의 디렉토리 구조이다.

파일에 담겨 있는 소스 코드를 기준으로 분류하여 디렉토리를 구성하였다. 기본적으로 MVVM의 각 요소에 해당하는 폴더와, 스토리보드, 서비스, 익스텐션 등을 기준으로 분류하였다.

이렇게 하면 프로젝트의 크기가 커졌을 때도 전체적인 구조에는 변함이 적을 것이다.

```text
FineDust
|-- Resources
|-- Sources
|   |-- Commons
|   |-- Errors
|   |-- Extensions
|   |-- Models
|   |-- Services
|   |-- Storyboards
|   |-- ViewControllers
|   |-- ViewModels
|   |-- Views
|-- Supports
```

## 2차 리팩토링 + 테스트

**테스트를 통해 효율적으로 동작하는 코드 작성**