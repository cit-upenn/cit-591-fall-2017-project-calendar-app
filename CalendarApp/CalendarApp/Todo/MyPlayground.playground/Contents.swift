import UIKit

var str = "Hello, playground"
print(str)

func plusTen(input: Double) -> Double {
    return input + 10
}

print(plusTen(input: 2.0))


class StepCounter {
    var totalSteps: Int = 0 {
        willSet(newSteps) {
            print("about to set total steps to \(newSteps)")
        }
        didSet{
            if totalSteps > oldValue {
                print("Added \(totalSteps - oldValue) Steps")
            }
        }
    }
    static var good = "Step counter is awesome!"
    static var notSoGood: String {
        return "step counter not good"
    }
}

let stepCounter = StepCounter()
stepCounter.totalSteps = 10
stepCounter.totalSteps = 100
stepCounter.totalSteps = 200
print(StepCounter.good)
print(StepCounter.notSoGood)

