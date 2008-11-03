#!/usr/bin/env jruby

require 'java'
require 'tempfile'

import 'org.jfree.chart.ChartFactory'
import 'org.jfree.chart.ChartUtilities'
import 'org.jfree.chart.JFreeChart'
import 'org.jfree.chart.encoders.ImageFormat'
import 'org.jfree.chart.plot.PlotOrientation'
import 'org.jfree.data.xy.XYSeries'
import 'org.jfree.data.xy.XYSeriesCollection'

def hash_to_xycollection(data)
	collection = XYSeriesCollection.new
	data.each_pair do |name, values|
		series = XYSeries.new(name.to_s)
		values.each { |tuple| series.add tuple[0], tuple[1] }
		collection.addSeries series
	end
	return collection
end

def tempfilename
	t = Tempfile.new('plot')
	path = t.path
	t.close
	return path
end

def plot(data, params={})
	data = {'' => data} if data.kind_of?(Array)
	collection = hash_to_xycollection(data)

	chart = ChartFactory.send "create#{params[:type] || 'ScatterPlot'}",
			params[:title],
			params[:labelx],
			params[:labely],
			collection,
			params[:orientation] || PlotOrientation::VERTICAL,
			params[:legend] || true,
			params[:tooltips] || false,
			params[:urls] || false

	filename = params[:filename] || tempfilename + '.png'

	plot = chart.getPlot
	ChartUtilities.saveChartAsPNG(
		Java::JavaIo::File.new(filename), 
		chart, 
		params[:width] || 640,
		params[:height] || 480, 
		nil)
	
	`#{params[:viewer] || 'eog'} #{filename}` if params[:view]
end

def help_and_exit
	puts "Usage:"
	puts "  #{$0} data params"
	puts 
	puts "  params include :title, :labelx, :labely, :view, :viewer, :type etc."
	puts "    :type can be ScatterPlot, Histogram etc."
	puts
	puts "Example:"
	puts "  #{$0} '{:dsm => [[1,2],[3,4]], :wcc => [[2,4]]}' '{:type => :ScatterPlot, :view => true}'"
	exit 1
end

if __FILE__ == $0
	help_and_exit if ARGV.size < 2
	plot eval(ARGV[0]), eval(ARGV[1])
end
