//
//  BloodSugarGraphView.swift
//
//  Created by Uwe Petersen on 23.03.16.
//
//  Blood sugar data ranges from time of last scan to approx 8 hours before. This data shall be plotted completeley. 
//  But the inital x-range of the graph shall be from the current time/date to 8 hours backwards. 
//  The user might pan and zoom to see other parts of the data.

import Foundation
import UIKit
import Charts

final class BloodSugarGraphView: LineChartView {

    var trendMeasurements: [Measurement]?
    var historyMeasurements: [Measurement]?
    var oopCurrentValue: OOPCurrentValue?
    
    lazy var dateValueFormatter: DateValueFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return DateValueFormatter(dateFormatter: dateFormatter)
    }()

    
    // Just the outlets are needed here, for these UI elements to be accessible from the corresponding parent table view controller
    // target action and that stuff is then all handled from within the table view controller
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Draws a line chart with glucose over time for trend and history measurments.
    ///
    /// - parameter trendMeasurements:   trend measurement data (16 values for now and last 15 minutes)
    /// - parameter historyMeasurements: history measurement data (32 values for last eight hours, each beeing 15 minutes apart)
    func setGlucoseCharts(trendMeasurements: [Measurement]?, historyMeasurements: [Measurement]?, oopCurrentValue: OOPCurrentValue?, fetchedGlucoses: [BloodGlucose]?) {
        
        self.noDataText = "No blood sugar data available"
        
        guard let trendMeasurements = trendMeasurements, let historyMeasurements = historyMeasurements, trendMeasurements.count == 16, historyMeasurements.count == 32 else {
            return
        }
        
        
        // Trend data set (data needs to be ordered from lowest x-value to highest x-value)
        let trendLineChartDataSet = trendLineChartData(trendMeasurements: trendMeasurements)
        // History data set (data needs to be ordered from lowest x-value to highest x-value)
        let historyLineChartDataSet = historyLineChartData(historyMeasurements: historyMeasurements)
        let oopHistoryLineChartDataSet = oopHistoryLineChartData(oopCurrentValue: oopCurrentValue, trendMeasurements: trendMeasurements)
        // new surrogate algo data set trend values and history values
        let newTrendLineChartDataSet = newTrendLineChartData(trendMeasurements: trendMeasurements)
        let newHistoryLineChartDataSet = newHistoryLineChartData(historyMeasurements: historyMeasurements)
        let testLineChartDataSet = testLineChartData(trendMeasurements: trendMeasurements)
        let fetchedGlucosesLineChartDataSet = fetchedGlucosesLineChartData(fetchedGlucoses: fetchedGlucoses)
        
        // format data sets and create line chart with the data sets
        formatLineChartDataSet(historyLineChartDataSet)
        formatLineChartDataSet(trendLineChartDataSet)
//        formatLineChartDataSet(oopHistoryLineChartDataSet)

        // Create the line chart
        var lineChartData = LineChartData()
//        lineChartData = LineChartData(dataSets: [fetchedGlucosesLineChartDataSet, oopHistoryLineChartDataSet, newTrendLineChartDataSet, newHistoryLineChartDataSet, testLineChartDataSet])
        lineChartData = LineChartData(dataSets: [trendLineChartDataSet, historyLineChartDataSet, oopHistoryLineChartDataSet, newTrendLineChartDataSet, newHistoryLineChartDataSet, testLineChartDataSet, fetchedGlucosesLineChartDataSet])
        lineChartData.setValueFont(NSUIFont.systemFont(ofSize: CGFloat(9.0)))
        
        
        
        // Line for upper and lower threshold of ideal glucose values
        let lowerLimitLine = ChartLimitLine(limit: 70.0)
        let upperLimitLine = ChartLimitLine(limit: 100.0)
        self.rightAxis.addLimitLine(lowerLimitLine)
        self.rightAxis.addLimitLine(upperLimitLine)
        self.rightAxis.drawLimitLinesBehindDataEnabled = true
        
        // the blood sugar graph
        self.data = lineChartData
        self.chartDescription?.text = "LibreMonitor"
        self.chartDescription?.font = NSUIFont.systemFont(ofSize: CGFloat(4))
        
        self.xAxis.valueFormatter = dateValueFormatter

        // Display the last 8 hours (no matter of the date range of the data to be plotted)

        let oldXAxisMaximum = self.xAxis.axisMaximum          // i.e. date when the chart was refreshed last time
        let highestXValue = lineChartData.xMax                // i.e. date of last scan (or sample)
        self.xAxis.axisMaximum = Date().addingTimeInterval(10.0 * 60.0).timeIntervalSince1970 // set maximum to current date
//        self.xAxis.axisMaximum = Date().timeIntervalSince1970 // set maximum to current date

        
        // Adjust zoom and x-offset
        if self.xAxis.axisMaximum - highestXValue > 10.0 * 60.0 {
            // if last sample was more than 10 minutes ago, zoom out such that all the last 8 hours are displayed. The rest of the data can be displayed e.g. by paning
            self.fitScreen()
            let xTimeRange = self.xAxis.axisMaximum - self.xAxis.axisMinimum
//            let eightHours = 8.0 * 3600.0
            let eightHours = 8.0 * 3600.0 + 10.0 * 60.0 // 8 hours plus 10 minutes
            let scaleX = xTimeRange / eightHours
            let xOffset = xTimeRange - eightHours
            self.zoom(scaleX: CGFloat(scaleX), scaleY: 1, x: CGFloat(xOffset), y: 0)
        } else {
            // otherwise keep zoom ratio but shift line to the left about the amount of time since the last date the chart was refresehd
            let offsetXMaximum = self.xAxis.axisMaximum - oldXAxisMaximum
            self.zoom(scaleX: 1, scaleY: 1, x: CGFloat(offsetXMaximum), y: 0)
        }
        
        self.notifyDataSetChanged()
    }
    
    
    /// Formats the line and the data points.
    ///
    /// Formatted are circle radius, line width and line mode (cubic)
    ///
    /// - parameter lineChartDataSet: lineChartDataSet to be formatted
    func formatLineChartDataSet (_ lineChartDataSet: LineChartDataSet) {
        lineChartDataSet.circleRadius = CGFloat(3.0)
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.cubicIntensity = 0.05
        lineChartDataSet.lineWidth = lineChartDataSet.lineWidth * CGFloat(2.0)
    }
    
    
    // MARK: - Functions for line chart data
    
    func trendLineChartData(trendMeasurements: [Measurement]) -> LineChartDataSet {
        // Trend data set (data needs to be ordered from lowest x-value to highest x-value)
        var trendEntries = [ChartDataEntry]()
        trendMeasurements.reversed().forEach{
            let timeIntervall = $0.date.timeIntervalSince1970
            trendEntries.append(ChartDataEntry(x: timeIntervall, y: $0.glucose))
        }
        let trendLineChartDataSet = LineChartDataSet(entries: trendEntries, label: "Trend")
        trendLineChartDataSet.drawValuesEnabled = false
        return trendLineChartDataSet
    }
    
    func historyLineChartData(historyMeasurements: [Measurement]) -> LineChartDataSet {
        // History data set (data needs to be ordered from lowest x-value to highest x-value)
        var historyEntries = [ChartDataEntry]()
        historyMeasurements.reversed().forEach{
            let timeIntervall = $0.date.timeIntervalSince1970
            historyEntries.append(ChartDataEntry(x: timeIntervall, y: $0.glucose))
        }
        let historyLineChartDataSet = LineChartDataSet(entries: historyEntries, label: "History")
        historyLineChartDataSet.setColor(NSUIColor.blue, alpha: CGFloat(1.0))
        historyLineChartDataSet.setCircleColor(NSUIColor.blue)
        return historyLineChartDataSet
    }
    
    func oopHistoryLineChartData(oopCurrentValue: OOPCurrentValue?, trendMeasurements: [Measurement]) -> LineChartDataSet {
        var oopHistoryEntries = [ChartDataEntry]()
        if let oopCurrentValue = oopCurrentValue {
            if let trendMeasurmentMostRecentValue = trendMeasurements.first {
                oopCurrentValue.historyValues.map{$0}.forEach{
                    if $0.bg > 0 {
                        let timeIntervall = trendMeasurmentMostRecentValue.date.timeIntervalSince1970 - TimeInterval((oopCurrentValue.currentTime - $0.time) * 60)
                        oopHistoryEntries.append(ChartDataEntry(x: timeIntervall, y: $0.bg))
                    }
                }
                let timeIntervall = trendMeasurmentMostRecentValue.date.timeIntervalSince1970 + TimeInterval(8 * 60) // newest date plus 10 minutes
                oopHistoryEntries.append(ChartDataEntry(x: timeIntervall, y: oopCurrentValue.currentBg))
            }
        }
        let oopHistoryLineChartDataSet = LineChartDataSet(entries: oopHistoryEntries, label: "OOP")
        oopHistoryLineChartDataSet.setColor(NSUIColor.red, alpha: CGFloat(1.0))
        oopHistoryLineChartDataSet.setCircleColor(NSUIColor.red)
        oopHistoryLineChartDataSet.circleRadius = 3.0
        oopHistoryLineChartDataSet.lineWidth =  CGFloat(1.5)

        return oopHistoryLineChartDataSet
    }
    
    func newTrendLineChartData(trendMeasurements: [Measurement]) -> LineChartDataSet {
        
        // new surrogate algo data set trend values and history values
        var newTrendEntries = [ChartDataEntry]()
        trendMeasurements.reversed().forEach{
            let timeIntervall = $0.date.timeIntervalSince1970
            newTrendEntries.append(ChartDataEntry(x: timeIntervall, y: $0.temperatureAlgorithmGlucose))
        }
        let newTrendLineChartDataSet = LineChartDataSet(entries: newTrendEntries, label: "New Trend")
        newTrendLineChartDataSet.setColor(NSUIColor.darkGray, alpha: CGFloat(1.0))
        newTrendLineChartDataSet.setCircleColor(NSUIColor.darkGray)
        newTrendLineChartDataSet.circleRadius = 3.0
        newTrendLineChartDataSet.drawValuesEnabled = false
        return newTrendLineChartDataSet
    }
    
    func newHistoryLineChartData(historyMeasurements: [Measurement]) -> LineChartDataSet {
        var newHistoryEntries = [ChartDataEntry]()
        historyMeasurements.reversed().forEach{
            let timeIntervall = $0.date.timeIntervalSince1970 // Test - TimeInterval(60*5)
            newHistoryEntries.append(ChartDataEntry(x: timeIntervall, y: $0.temperatureAlgorithmGlucose))
        }
        let newHistoryLineChartDataSet = LineChartDataSet(entries: newHistoryEntries, label: "New History")
        newHistoryLineChartDataSet.setColor(NSUIColor.darkGray, alpha: CGFloat(1.0))
        newHistoryLineChartDataSet.setCircleColor(NSUIColor.darkGray)
        newHistoryLineChartDataSet.circleRadius = 3.0
        newHistoryLineChartDataSet.mode = .cubicBezier
        newHistoryLineChartDataSet.cubicIntensity = 0.1

        //        print("newHistoryLineChartDataSet:")
        //        print(newHistoryLineChartDataSet.debugDescription)
        return newHistoryLineChartDataSet
    }
    
    func testLineChartData(trendMeasurements: [Measurement]) -> LineChartDataSet {
        // Test for current glucose
        let p1 = Double(trendMeasurements[10...14].map{$0.temperatureAlgorithmGlucose}.reduce(0.0, + )) / 5.0
        let p2 = Double(trendMeasurements[5...9].map{$0.temperatureAlgorithmGlucose}.reduce(0.0, + )) / 5.0
        let p3 = Double(trendMeasurements[0...4].map{$0.temperatureAlgorithmGlucose}.reduce(0.0, + )) / 5.0
        var testEntries = [ChartDataEntry]()
        testEntries.append(ChartDataEntry(x: trendMeasurements[12].date.timeIntervalSince1970, y: p1))
        testEntries.append(ChartDataEntry(x: trendMeasurements[7].date.timeIntervalSince1970, y: p2))
        testEntries.append(ChartDataEntry(x: trendMeasurements[2].date.timeIntervalSince1970, y: p3))
        let p4 = p3 + 0.65 * (p3 - p1) + 0.2 * (p3 - p2)
        let t4 = trendMeasurements[2].date.timeIntervalSince1970 + 0.8 * (trendMeasurements[2].date.timeIntervalSince1970 - trendMeasurements[12].date.timeIntervalSince1970)
        testEntries.append(ChartDataEntry(x: t4, y: p4))
        let testLineChartDataSet = LineChartDataSet(entries: testEntries, label: "Test")
        testLineChartDataSet.setColor(NSUIColor.brown, alpha: CGFloat(1.0))
        testLineChartDataSet.setCircleColor(NSUIColor.brown)
        testLineChartDataSet.circleRadius = 3.0
     
        return testLineChartDataSet
    }
    
    
    func fetchedGlucosesLineChartData(fetchedGlucoses: [BloodGlucose]?) -> LineChartDataSet {
        // array of oop glucose that was retreived from core data.
        var fetchedGlucosesEntries = [ChartDataEntry]()
        if let fetchedGlucoses = fetchedGlucoses {
            fetchedGlucoses.reversed().forEach{
                if let timeIntervall = $0.date?.timeIntervalSince1970 {
                    fetchedGlucosesEntries.append(ChartDataEntry(x: timeIntervall, y: $0.value))
                }
            }
        }
        let fetchedGlucosesLineChartDataSet = LineChartDataSet(entries: fetchedGlucosesEntries, label: "current")
        fetchedGlucosesLineChartDataSet.setColor(NSUIColor.brown, alpha: CGFloat(1.0))
        fetchedGlucosesLineChartDataSet.setCircleColor(NSUIColor.brown)
        fetchedGlucosesLineChartDataSet.circleRadius = 3.0
        fetchedGlucosesLineChartDataSet.lineWidth = fetchedGlucosesLineChartDataSet.lineWidth * CGFloat(2.0)
        fetchedGlucosesLineChartDataSet.drawValuesEnabled = false
        //        print("fetchedGlucosesLineChartDataSet:")
        //        print(fetchedGlucosesLineChartDataSet.debugDescription)
        return fetchedGlucosesLineChartDataSet
    }

    
}


/// Formatter class for time values (x-axis) of blood sugar graph.
///
/// The x-axis ticks are shown as time of day in "HH:mm"-format.
class DateValueFormatter: NSObject, IAxisValueFormatter {
    var dateFormatter = DateFormatter()
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
//        self.dateFormatter.dateFormat = "HH:mm"
        
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
