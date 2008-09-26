class RAgglomerativeClusterer
	def initialize(items, simfunc)
		@dendogram = []
		@simfunc = simfunc
		createDendogram items
	end

	def createDendogram(items)
		items.each { |e| @dendogram << [e] }

		cluster1 = nil
		cluster2 = nil
		while @dendogram.size > 2
			puts @dendogram.size
			max = -1.0
			newCluster = [nil, nil]
			0.upto(@dendogram.size-1) do |i|
				(i + 1).upto(@dendogram.size-1) do |j|
					cluster1 = @dendogram[i]
					cluster2 = @dendogram[j]
					l1 = cluster1.flatten
					l2 = cluster2.flatten
					similarity = @simfunc.call(l1, l2)
					if similarity > max
						max = similarity
						newCluster = [cluster1, cluster2]
					end
				end
			end
			#p newCluster
			#p newCluster[0]
			#p newCluster[1]
			newCluster.each { |e| @dendogram.delete(e) }
			@dendogram << newCluster
		end
	end

	def createClusters(dendo, height, result)
		if height <= 0
			result << dendo.flatten
		else
			x0 = dendo[0]
			cluster0 = if x0.class == Array then x0 else [x0] end
			createClusters(cluster0, height - 1, result)

			if dendo.size > 1
				x1 = dendo[1]
				cluster1 = if x1.class == Array then x1 else [x1] end
				createClusters(cluster1, height - 1, result)
			end
		end
	end

	def getHeight_aux(dendo, base)
		if dendo.size == 1
			return base
		else
			return [getHeight_aux(dendo[0], base + 1), 
					getHeight_aux(dendo[1], base + 1)].max
		end
	end

	def getHeight
		return getHeight_aux @dendogram, 0
	end

	def getClusters(height)
		result = []
		height = (height * getHeight).to_i if height.class == Float
		createClusters(@dendogram, height, result)
		return result
	end

end
