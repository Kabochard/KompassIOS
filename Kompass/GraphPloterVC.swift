//
//  GraphPloterVC.swift
//  Kompass
//
//  Created by Tim Consigny on 05/11/2015.
//  Copyright © 2015 Rsx. All rights reserved.
//

import Foundation
import CorePlot

class GraphPloterVC: UIViewController {
    
    var KompassManager: KompassMngr!
    var plotSpace: CPTXYPlotSpace!
    var graph : CPTXYGraph!
    var scatterPlot : CPTScatterPlot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KompassManager = KompassMngr()
        KompassManager.graphVC = self
        
        var relad = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        relad.backgroundColor = UIColor.blueColor()
        
        relad.addTarget(self, action: "reload", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(relad)
        
        let frame = self.view.frame
        //add graph
        graph = CPTXYGraph(frame: CGRect(x: 0, y: 50, width: frame.width, height: frame.height - 250))
        graph.paddingBottom = 10
        graph.paddingLeft = 10
        graph.paddingRight = 10
        graph.paddingTop = 10
        graph.title = "Scatter Plot"
        
        //hostView
        var hostView = CPTGraphHostingView(frame: graph.frame)
        self.view.addSubview(hostView)
        
        //add scatter plot and plot space
         scatterPlot = CPTScatterPlot()
        scatterPlot = CPTScatterPlot(frame: hostView.frame)
        //scatterPlot.delegate = self
        scatterPlot.dataSource = KompassManager!
        
        plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction =  false//true
        plotSpace.xRange = CPTPlotRange(location: -5000, length: 10000)
        plotSpace.yRange = CPTPlotRange(location: -5000, length: 10000)
        
        
        
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill = CPTFill(color: CPTColor.blueColor())
        plotSymbol.size = CGSizeMake(10,10)
        plotSymbol.lineStyle = nil
        
        scatterPlot.plotSymbol = plotSymbol
        
        scatterPlot.dataLineStyle = nil //hide line
        
        //scatterPlot.
        
        
        graph.addPlot(scatterPlot)
        
        //set axis
        let axes: CPTXYAxisSet = CPTXYAxisSet(layer: graph.axisSet!); let x = axes.xAxis; let y = axes.yAxis
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 2
        x!.axisLineStyle = lineStyle; y!.axisLineStyle = lineStyle
        x!.title = "X"; y!.title = "Y"
        x!.orthogonalPosition = 0; y!.orthogonalPosition = 0
        x!.majorIntervalLength = 1000; y!.majorIntervalLength = 1000
        x!.minorTickLength = 500; y!.minorTickLength = 500
        
        
         let lineStyle2 = CPTMutableLineStyle()
        lineStyle2.lineWidth = 1;
        lineStyle2.lineColor = CPTColor.lightGrayColor()
        x!.majorGridLineStyle = lineStyle2
        y!.majorGridLineStyle = lineStyle2
        
        let lineStyle3 = CPTMutableLineStyle()
        lineStyle3.lineWidth = 0.5;
        lineStyle3.lineColor = CPTColor.lightGrayColor()
        x!.minorGridLineStyle = lineStyle2
        y!.minorGridLineStyle = lineStyle2
        
        
        
        hostView.hostedGraph = graph
        
        hostView.allowPinchScaling = false
    
    }
    
    
    func reload()
    {
        
//        plotSpace.xRange = CPTPlotRange(location: KompassManager.magXreagings.minElement()!, length:  KompassManager.magXreagings.maxElement()! -  KompassManager.magXreagings.minElement()!)
//        plotSpace.yRange =  CPTPlotRange(location: KompassManager.magYreadings.minElement()!, length:  KompassManager.magYreadings.maxElement()! -  KompassManager.magXreagings.minElement()!)
//        
        scatterPlot.reloadData()

        
    }
    
    
      
//    func dataLabelForPlot(plot: CPTPlot, recordIndex idx: UInt) -> CPTLayer? {
//        let test = CPTLayer()
//        test.backgroundColor = UIColor.blackColor().CGColor
//        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
//        plotSymbol.fill = CPTFill(color: CPTColor.blueColor())
//        plotSymbol.size = CGSizeMake(10,10)
//        plotSymbol.lineStyle = nil
//        
//        [plotSymbol setSize:CGSizeMake(10, 10)];
//        [plotSymbol setFill:[CPTFill fillWithColor:[CPTColor blueColor]]];
//        [plotSymbol setLineStyle:nil];
//        [aPlot setPlotSymbol:plotSymbol];
//        
//    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}