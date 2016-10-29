//
//  HealthManager.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 29.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import HealthKit
import CoreData



class HealthManager {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {

        // 1. and 2. Set the types you want to share and read from HK Store
        let healthKitSampleTypesToShare = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal)
            ]
            .flatMap{$0 as HKSampleType?}
        
        let healthKitObjectTypesToRead = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCarbohydrates),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryProtein),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryFatTotal)
            ]
            .flatMap{$0 as HKObjectType?}
        
        let healthKitTypesToShare: Set? = Set<HKSampleType>(healthKitSampleTypesToShare)
        let healthKitTypesToRead: Set?  = Set<HKObjectType>(healthKitObjectTypesToRead)
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable(){
            let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil ){
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToShare, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if( completion != nil ){
                completion(success:success,error:error)
            }
        }
    }
    
    
    //    func requestAuthorizationToShareTypes(_ typesToShare: Set<HKSampleType>?,
    //        readTypes typesToRead: Set<HKObjectType>?,
    //        completion completion: (Bool,
    //        NSError?) -> Void)
    
    //    func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?) {
    //        var error:NSError?
    //        var age:Int?
    //
    //        // 1. Request birthday and calculate age
    //        if let birthDay = healthKitStore.dateOfBirthWithError(&error) {
    //            let today = NSDate()
    //            let calendar = NSCalendar.currentCalendar()
    //            let differenceComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: birthDay, toDate: today, options: NSCalendarOptions(0) )
    //            age = differenceComponents.year
    //        }
    //        if error != nil {
    //            println("Error reading Birthday: \(error)")
    //        }
    //
    //        // 2. Read biological sex
    //        var biologicalSex:HKBiologicalSexObject? = healthKitStore.biologicalSexWithError(&error);
    //        if error != nil {
    //            println("Error reading Biological Sex: \(error)")
    //        }
    //        // 3. Read blood type
    //        var bloodType:HKBloodTypeObject? = healthKitStore.bloodTypeWithError(&error);
    //        if error != nil {
    //            println("Error reading Blood Type: \(error)")
    //        }
    //
    //        // 4. Return the information read in a tuple
    //        return (age, biologicalSex, bloodType)
    //    }
    //
    //    func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!) {
    //        // 1. Build the Predicate
    //        let past = NSDate.distantPast() as! NSDate
    //        let now   = NSDate()
    //        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)
    //
    //        // 2. Build the sort descriptor to return the samples in descending order
    //        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    //        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
    //        let limit = 1
    //
    //        // 4. Build samples query
    //        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
    //
    //            if let queryError = error {
    //                completion(nil,error)
    //                return;
    //            }
    //
    //            // Get the first sample
    //            let mostRecentSample = results.first as? HKQuantitySample
    //
    //            // Execute the completion closure
    //            if completion != nil {
    //                completion(mostRecentSample,nil)
    //            }
    //        }
    //        // 5. Execute the Query
    //        self.healthKitStore.executeQuery(sampleQuery)
    //    }
    //
    //
    //    func saveBMISample(bmi:Double, date:NSDate) {
    //
    //        // 1. Create a BMI Sample
    //        let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
    //        let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
    //        let bmiSample = HKQuantitySample(type: bmiType, quantity: bmiQuantity, startDate: date, endDate: date)
    //
    //        // 2. Save the sample in the store
    //        healthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
    //            if( error != nil ) {
    //                println("Error saving BMI sample: \(error.localizedDescription)")
    //            } else {
    //                println("BMI sample saved successfully!")
    //            }
    //        })
    //    }
    //
    //
    //
    //    func saveRunningWorkout(startDate:NSDate , endDate:NSDate , distance:Double, distanceUnit:HKUnit , kiloCalories:Double,
    //        completion: ( (Bool, NSError!) -> Void)!) {
    //
    //            // 1. Create quantities for the distance and energy burned
    //            let distanceQuantity = HKQuantity(unit: distanceUnit, doubleValue: distance)
    //            let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: kiloCalories)
    //
    //            // 2. Save Running Workout
    //            let workout = HKWorkout(activityType: HKWorkoutActivityType.Running, startDate: startDate, endDate: endDate, duration: abs(endDate.timeIntervalSinceDate(startDate)), totalEnergyBurned: caloriesQuantity, totalDistance: distanceQuantity, metadata: nil)
    //            healthKitStore.saveObject(workout, withCompletion: { (success, error) -> Void in
    //                if( error != nil  ) {
    //                    // Error saving the workout
    //                    completion(success,error)
    //                }
    //                else {
    //                    // Workout saved
    //                    // if success, then save the associated samples so that they appear in the Health Store
    //                    let distanceSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning), quantity: distanceQuantity, startDate: startDate, endDate: endDate)
    //                    let caloriesSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned), quantity: caloriesQuantity, startDate: startDate, endDate: endDate)
    //
    //                    self.healthKitStore.addSamples([distanceSample,caloriesSample], toWorkout: workout, completion: { (success, error ) -> Void in
    //                        completion(success, error)
    //                    })
    //                }
    //            })
    //    }
    //
    //    func readRunningWorkOuts(completion: (([AnyObject]!, NSError!) -> Void)!) {
    //
    //        // 1. Predicate to read only running workouts
    //        let predicate =  HKQuery.predicateForWorkoutsWithWorkoutActivityType(HKWorkoutActivityType.Running)
    //        // 2. Order the workouts by date
    //        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    //        // 3. Create the query
    //        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
    //
    //            if let queryError = error {
    //                println( "There was an error while reading the samples: \(queryError.localizedDescription)")
    //            }
    //            completion(results,error)
    //        }
    //        // 4. Execute the query
    //        healthKitStore.executeQuery(sampleQuery)
    //    }
    
    func syncMealToHealth(meal: Meal) {
        deleteMeal(meal)
        saveMeal(meal)
    }
    
    func saveMeal(meal: Meal) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available in this Device")
            //            let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            return;
        }
        
        print("About to save the object with id: \(meal.objectID)")
        
        let managedObjectContext = meal.managedObjectContext
        let mealMetaData = ["comment": meal.comment ?? "", "CoreDataObjectIDAsURIString": meal.objectID.URIRepresentation().absoluteString ?? ""]
        
        //        let quantityTypeIdentifiers = [HKQuantityTypeIdentifierDietaryEnergyConsumed, HKQuantityTypeIdentifierDietaryCarbohydrates, HKQuantityTypeIdentifierDietaryProtein, HKQuantityTypeIdentifierDietaryFatTotal]
        
        let identifiers = [
            ("totalEnergyCals", HKQuantityTypeIdentifierDietaryEnergyConsumed),
            ("totalCarb",       HKQuantityTypeIdentifierDietaryCarbohydrates),
            ("totalProtein",    HKQuantityTypeIdentifierDietaryProtein),
            ("totalFat",        HKQuantityTypeIdentifierDietaryFatTotal)]
        
        var samplesSet = Set<HKQuantitySample>()
        
        for identifierTuple in identifiers {
            if let type = HKQuantityType.quantityTypeForIdentifier(identifierTuple.1),
                let nutrient = Nutrient.nutrientForKey(identifierTuple.0, inManagedObjectContext: managedObjectContext!) {
                let quantity = HKQuantity(unit: nutrient.hkUnit, doubleValue: meal.doubleForNutrient(nutrient) ?? 0.0)
                samplesSet.insert(HKQuantitySample(type: type, quantity: quantity, startDate: meal.dateOfCreation, endDate: meal.dateOfCreation, metadata: mealMetaData))
            }
        }

        //
        // Combine nutritional data into a food correlation
        //
        
        guard let correlationType = HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood) else {
            print("Food correlation type not available")
            return
        }
        let mealCorrelation = HKCorrelation(type: correlationType, startDate: meal.dateOfCreation, endDate: meal.dateOfCreation, objects: samplesSet, metadata: mealMetaData)
        
        // 2. Save the sample in the store
        healthKitStore.saveObject(mealCorrelation, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print("Error saving carb sample: \(error!.localizedDescription)")
            } else {
                print("Saved food correlation successfully!")
            }
        })
    }
    
    
    func deleteMeal(meal: Meal) {
        
        if !HKHealthStore.isHealthDataAvailable(){
            //            let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            print("HealthKit is not available in this Device")
            return;
        }
        
        print("About to delete the meal with object ID: \(meal.objectID)")
        
        
        let predicate = HKQuery.predicateForObjectsWithMetadataKey("CoreDataObjectIDAsURIString", allowedValues: [meal.objectID.URIRepresentation().absoluteString])
        
        if let sampleType = HKSampleType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood) {
            let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler:
                { (sampleQuery, results, error ) -> Void in
                    
                    if let results = results {
                        
                        let foodCorrelations = results
                            .flatMap{$0 as? HKCorrelation}
                            .filter {$0.correlationType == HKCorrelationType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood)! as HKCorrelationType}
                        
                        // for each food correlation delete its objects
                        for foodCorrelation in foodCorrelations {
                            for object in foodCorrelation.objects {
                                //                                if let object = object as? HKSample {
                                self.healthKitStore.deleteObject(object, withCompletion:{(success, error) -> Void in
                                    if success {
                                        //                                    println("Deleted an object of a food correlation.")
                                        return
                                    }
                                    print("Error. Could not delete an object of food correlation.")
                                })
                            }
                            
                            // delete the food correlation object itself
                            self.healthKitStore.deleteObject(foodCorrelation, withCompletion:{(success, error) -> Void in
                                if success {
                                    print("Deleted a food correlation.")
                                    return
                                }
                                print("Error. Could not delete a food correlation.")
                            })
                        }
                    }
                    

            })
            // 5. Execute the Query
            self.healthKitStore.executeQuery(sampleQuery)
            
        }
        

    }
    
    
    func readNutrientData (date: NSDate, completion: ((HKCorrelation!, NSError!) -> Void)!) {
        
        if !HKHealthStore.isHealthDataAvailable(){
            //            let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            print("HealthKit is not available in this Device")
            return;
        }
        
        guard let sampleType = HKSampleType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood) else {
            fatalError("Wrong identifier for food correlation")
        }
        //        let sampleType = HKSampleType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood)
        let options = HKQueryOptions.None
        
        let startDate = NSDate(timeInterval: -60, sinceDate: date)
        let endDate = NSDate(timeInterval: 60, sinceDate: date)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: options)
        
        // query with completion handler (wherein another completion handler is called
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler:
            {(sampleQuery, results, error ) -> Void in
                //                { [unowned self] (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    print( "There was an error while reading the samples: \(queryError.localizedDescription)")
                    completion(nil, error)
                }
                
                if let results = results {
                    let foodCorrelations = results
                        .flatMap{$0 as? HKCorrelation}
                        .filter {$0.correlationType == HKCorrelationType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood)! as HKCorrelationType}
                    
                    if foodCorrelations.count > 1 {
                        print("Number of food correlation objects is \(foodCorrelations.count), which is greater than one, which should not happen.")
                        print("Aborting program. Please check and correct your database, Uwe.")
                        abort()
                    }
                    
                    for foodCorrelation in foodCorrelations {
                        print("About to call completion")
                        
                        completion(foodCorrelation, nil)
                        print("... done with call to completion")
                    }
                }

        })
        // 5. Execute the Query
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    
}
