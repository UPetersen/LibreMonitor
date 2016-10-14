//
//  BloodSugarGraphView.swift
//
//  Created by Uwe Petersen on 23.03.16.
//

import Foundation
import UIKit
import Charts

class BloodSugarGraphView: LineChartView {

    var trendMeasurements: [Measurement]?
    var historyMeasurements: [Measurement]?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    
    // Just the outlets are needed here, for these UI elements to be accessible from the corresponding parent table view controller
    // target action and that stuff is then all handled from within the table view controller
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setGlucoseCharts(_ trendMeasurements: [Measurement]?, historyMeasurements: [Measurement]?) {
        
        self.noDataText = "No blood sugar data available"
        
        guard let trendMeasurements = trendMeasurements, let historyMeasurements = historyMeasurements else {return}
        
        // x-values are an array of Strings. Create 500 for the complete chart. This corresponds to going back 500 minutes in time
        let xValues = xlabelsForDate(Date())
        
        let historyLineChartDataSet = lineChartDataSetFor(historyMeasurements, xValuesCount: 500, label: "History")
        let trendLineChartDataSet = lineChartDataSetFor(trendMeasurements, xValuesCount: 500, label: "Trend")
        
        lineChartDataSetSettings(historyLineChartDataSet)
        lineChartDataSetSettings(trendLineChartDataSet)
        
        
        let lineChartData = LineChartData(xVals: xValues, dataSets: [trendLineChartDataSet, historyLineChartDataSet])
        //        print(lineChartData.debugDescription)
        
        lineChartData.setValueFont(NSUIFont.systemFont(ofSize: CGFloat(9.0)))
        
        // Line for upper and lower threshold of ideal glucose values
        let lowerLimitLine = ChartLimitLine(limit: 70.0)
        let upperLimitLine = ChartLimitLine(limit: 100.0)
        self.rightAxis.addLimitLine(lowerLimitLine)
        self.rightAxis.addLimitLine(upperLimitLine)
        self.rightAxis.drawLimitLinesBehindDataEnabled = true
        
        self.data = lineChartData
        self.descriptionText = "LibreMonitor"
        self.descriptionFont = NSUIFont.systemFont(ofSize: CGFloat(4))
    }
    
    
    
    
    /// Create LineChartDataSet for glucoseMeasurements
    /// - returns:   data set for the glucose measurments
    /// - parameter glucoseMeasurements Array of glucose measurements
    /// - parameter xValuesCount number of elements of the corresponding x values (may be more than elements of glucoseMesurements)
    /// - parameter timeOffset   Offset used to adjust the values in x direction
    /// - parameter label       Label used for the data set
    func lineChartDataSetFor(_ measurements: [Measurement], xValuesCount: Int, label: String?) -> LineChartDataSet {
        
        // y-values are of type ChartDataEntry and need only to be filled in at the appropriate indeces, that are already
        // given for each glucoseMeasurment (timeInMinutesSinceMeasurement is used to calculate the appropriate position in the array)
        var chartDataEntries = [ChartDataEntry]()
        
        for measurement in measurements where measurement.glucose > 0  {
            let minutes = Int(measurement.date.timeIntervalSinceNow / 60.0)
            let xIndex =  xValuesCount + minutes

//            print("glucose: \(measurement.glucose), Minutes: \(minutes), date: \(NSDate()), glucoseDate: \(measurement.date)")
            
            // Show only data that is within the time frame to be displayed
            if xIndex >= 0 && xIndex < xValuesCount {
                chartDataEntries.append(ChartDataEntry(value: measurement.glucose, xIndex: xIndex))
            }
        }
        let lineChartDataSet = LineChartDataSet(yVals: chartDataEntries, label: label)
        //        print(lineChartDataSet.debugDescription)
        
        return lineChartDataSet
    }
    
    
    
    /// Create Array of x-labels with 500 values for approx the last eight ours, e.g. ["13:30", "13:31", "13:32", ...]
    /// - returns: array of strings with time
    /// - parameter date Reference date for the most recent time value
    func xlabelsForDate(_ date: Date) -> [String] {
        var xValues = [String]()
        for xValue in (0...500) { // the last 500 minutes until now
            let theDate = Date.init(timeInterval: Double(60 * (-500 + xValue)), since: Date())
//            let theDate = NSDate.init(timeInterval: Double(60 * (-500 + xValue)), sinceDate: date)
            xValues.append(dateFormatter.string(from: theDate))
        }
        return xValues
    }
    

    
    func lineChartDataSetSettings (_ lineChartDataSet: LineChartDataSet) {
        lineChartDataSet.circleRadius = CGFloat(3.0)
        lineChartDataSet.drawCubicEnabled = true
        lineChartDataSet.cubicIntensity = 0.05
        lineChartDataSet.lineWidth = lineChartDataSet.lineWidth * CGFloat(3.0)
    }
    
    
    
    
    //        barChartView.delegate = self
    //
    //        /// Called when a value has been selected inside the chart.
    //        /// - parameter entry: The selected Entry.
    //        /// - parameter dataSetIndex: The index in the datasets array of the data object the Entrys DataSet is in.
    //        func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
    //
    //        }
    //
    //        // Called when nothing has been selected or an "un-select" has been made.
    //        func chartValueNothingSelected(chartView: ChartViewBase) {
    //
    //        }
    //
    //        // Callbacks when the chart is scaled / zoomed via pinch zoom gesture.
    //        func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
    //
    //        }
    //
    //        // Callbacks when the chart is moved / translated via drag gesture.
    //        func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
    //
    //        }
    //

    
}
