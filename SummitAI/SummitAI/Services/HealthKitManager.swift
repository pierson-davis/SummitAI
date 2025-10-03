import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var todayElevation: Double = 0
    @Published var todayWorkouts: [HKWorkout] = []
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // HealthKit types we want to read
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.workoutType()
    ]
    
    init() {
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }
    }
    
    func requestHealthKitPermissions() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "HealthKit authorization failed: \(error.localizedDescription)"
                    self?.isAuthorized = false
                    return
                }
                
                self?.isAuthorized = success
                if success {
                    self?.fetchTodayData()
                    self?.startObservingHealthData()
                }
            }
        }
    }
    
    private func startObservingHealthData() {
        guard isAuthorized else { return }
        
        // Observe step count changes
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            let stepQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Step count observation error: \(error.localizedDescription)"
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.fetchTodayData()
                }
            }
            
            healthStore.execute(stepQuery)
        }
        
        // Observe workout changes
        let workoutQuery = HKObserverQuery(sampleType: HKObjectType.workoutType(), predicate: nil) { [weak self] _, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Workout observation error: \(error.localizedDescription)"
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchTodayData()
            }
        }
        
        healthStore.execute(workoutQuery)
    }
    
    func fetchTodayData() {
        guard isAuthorized else { return }
        
        fetchTodaySteps()
        fetchTodayElevation()
        fetchTodayWorkouts()
    }
    
    private func fetchTodaySteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch steps: \(error.localizedDescription)"
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    self?.todaySteps = Int(sum.doubleValue(for: HKUnit.count()))
                } else {
                    self?.todaySteps = 0
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchTodayElevation() {
        guard let elevationType = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: elevationType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch elevation: \(error.localizedDescription)"
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    // Convert flights to meters (assuming 10 feet per flight, 1 foot = 0.3048 meters)
                    let flights = sum.doubleValue(for: HKUnit.count())
                    self?.todayElevation = flights * 10 * 0.3048
                } else {
                    self?.todayElevation = 0
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchTodayWorkouts() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch workouts: \(error.localizedDescription)"
                    return
                }
                
                if let workouts = samples as? [HKWorkout] {
                    self?.todayWorkouts = workouts
                } else {
                    self?.todayWorkouts = []
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchStepsForDateRange(startDate: Date, endDate: Date, completion: @escaping (Int) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch steps for date range: \(error.localizedDescription)"
                    completion(0)
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    completion(Int(sum.doubleValue(for: HKUnit.count())))
                } else {
                    completion(0)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchElevationForDateRange(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {
        guard let elevationType = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: elevationType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch elevation for date range: \(error.localizedDescription)"
                    completion(0)
                    return
                }
                
                if let result = result, let sum = result.sumQuantity() {
                    let flights = sum.doubleValue(for: HKUnit.count())
                    completion(flights * 10 * 0.3048) // Convert to meters
                } else {
                    completion(0)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWorkoutsForDateRange(startDate: Date, endDate: Date, completion: @escaping ([HKWorkout]) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch workouts for date range: \(error.localizedDescription)"
                    completion([])
                    return
                }
                
                if let workouts = samples as? [HKWorkout] {
                    completion(workouts)
                } else {
                    completion([])
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // Convert HKWorkout to our WorkoutData model
    func convertHKWorkoutToWorkoutData(_ hkWorkout: HKWorkout) -> WorkoutData {
        let workoutType: WorkoutData.WorkoutType
        
        switch hkWorkout.workoutActivityType {
        case .walking:
            workoutType = .walking
        case .running:
            workoutType = .running
        case .cycling:
            workoutType = .cycling
        case .hiking:
            workoutType = .hiking
        case .climbing:
            workoutType = .climbing
        default:
            workoutType = .other
        }
        
        return WorkoutData(
            type: workoutType,
            duration: hkWorkout.duration,
            distance: hkWorkout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? nil,
            elevation: nil, // Would need to fetch separately
            calories: hkWorkout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? nil,
            timestamp: hkWorkout.startDate
        )
    }
}
