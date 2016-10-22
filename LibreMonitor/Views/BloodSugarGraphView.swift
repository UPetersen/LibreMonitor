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

class BloodSugarGraphView: LineChartView {

    var trendMeasurements: [Measurement]?
    var historyMeasurements: [Measurement]?
    
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
    func setGlucoseCharts(_ trendMeasurements: [Measurement]?, historyMeasurements: [Measurement]?) {
        
        self.noDataText = "No blood sugar data available"
        
        guard let trendMeasurements = trendMeasurements, let historyMeasurements = historyMeasurements else {return}
        
        // Trend data set (data needs to be ordered from lowest x-value to highest x-value)
        var trendEntries = [ChartDataEntry]()
        trendMeasurements.reversed().forEach{
            let timeIntervall = $0.date.timeIntervalSince1970
            trendEntries.append(ChartDataEntry(x: timeIntervall, y: $0.glucose))
        }
        let trendLineChartDataSet = LineChartDataSet(values: trendEntries, label: "Trend")

        // History data set (data needs to be ordered from lowest x-value to highest x-value)
        var historyEntries = [ChartDataEntry]()
        historyMeasurements.reversed().forEach{
            let timeIntervall = $0.date.timeIntervalSince1970
            historyEntries.append(ChartDataEntry(x: timeIntervall, y: $0.glucose))
        }
        let historyLineChartDataSet = LineChartDataSet(values: historyEntries, label: "History")
        
        // format data sets and create line chart with the data sets
        formatLineChartDataSet(historyLineChartDataSet)
        formatLineChartDataSet(trendLineChartDataSet)
        let lineChartData = LineChartData(dataSets: [historyLineChartDataSet, trendLineChartDataSet])
        print(lineChartData.debugDescription)
        
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
        self.xAxis.axisMaximum = Date().timeIntervalSince1970 // set maximum to current date

        
        // Adjust zoom and x-offset
        if self.xAxis.axisMaximum - highestXValue > 10.0 * 60.0 {
            // if last sample was more than 10 minutes ago, zoom out such that all the last 8 hours are displayed. The rest of the data can be displayed e.g. by paning
            self.fitScreen()
            let xTimeRange = self.xAxis.axisMaximum - self.xAxis.axisMinimum
            let eightHours = 8.0 * 3600.0
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
        lineChartDataSet.lineWidth = lineChartDataSet.lineWidth * CGFloat(3.0)
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
