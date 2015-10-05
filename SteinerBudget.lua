local SteinerBudget = {}
local Utility = require("Utility")
local MathFunc = require("MathFunc")
local PointStructure = require("PointStructure")
local Steiner = require("Steiner")
local Kruskal = require("Kruskal")

-- First algorithm: a simple TSP until we run out of budget
-- in: points
-- in: budget = the maximum budget
-- in: start = the "house"
-- out: a point structure with a solution
local function steinerBudget (points, budget, start)
	local currentBudget = 0
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)

	local currentIndex = start
	copy[currentIndex] = nil
	local nextIndex
	local stillInBudget = true

	local i = 0
	while(stillInBudget) do
		nextIndex = Steiner.findNextTSP(result[currentIndex].Point, copy)

		-- if the point we are going to add doesn't go over our budget
		if(currentBudget + MathFunc.distance(result[currentIndex].Point, result[nextIndex].Point) < budget) then
			table.insert(result[currentIndex].Transition, nextIndex)
			currentBudget = PointStructure.score(result)
			currentIndex = nextIndex
			copy[currentIndex] = nil
			i = i + 1
		else
			stillInBudget = false
		end
	end

	print(i .. " points attained.") -- number of points attained

	return result
end
SteinerBudget.steinerBudget = steinerBudget

-- Gives a list of all the points and their distance from a given point
-- in: a, idxA = the given point and its index
-- in: points
-- out: a list of the points by the distance from a
-- Each entry of the table has this form:	idxA, idxB, distance(a, b)
local function pointsByDistanceFromA (a, idxA, points)
	local edges = {}
	for i, v in pairs(points) do
		local d = MathFunc.distance(v.Point, a)
		if (d > 0) then
			local slot = {}
			slot.from = idxA
			slot.to = i
			slot.dist = d
			table.insert(edges, slot)
		end
	end

	return edges
end

-- Algorithm 1.1:
-- We run the three point optimization (see Steiner) every time we add a point, to see if we still have a budget
-- in: points
-- in: budget = the maximum budget
-- in: start = the "house"
-- out: a point structure with a solution
local function steinerBudgetOptimized (points, budget, start)
	local currentBudget = 0
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)

	local currentIndex = start
	copy[currentIndex] = nil
	local nextIndex
	local stillInBudget = true

	local i = 1
	while(stillInBudget) do
		nextIndex = Steiner.findNextTSP(result[currentIndex].Point, copy)
		table.insert(result[currentIndex].Transition, nextIndex)

		local backup = PointStructure.clone(result)
		Steiner.optimization3Point(backup)
		if(PointStructure.score(backup) > budget) then
			result[currentIndex].Transition[Utility.tlength(result[currentIndex].Transition)] = nil
			stillInBudget = false
		else
			currentBudget = PointStructure.score(result)
			currentIndex = nextIndex
			copy[currentIndex] = nil
			i = i + 1
		end
	end
	print(i .. " points attained.")

	return result
end
SteinerBudget.steinerBudgetOptimized = steinerBudgetOptimized

-- Algorithm number 2:
-- Instead of using only the last point added, we use every point we have used when searching for the next point
-- in: points
-- in: budget = the maximum budget
-- in: start = the "house"
-- out: a point structure with a solution
local function steinerBudgetDoubleSearch (points, budget, start)
	local currentBudget = 0
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)

	local currentIndex = start
	copy[currentIndex] = nil
	local availableTransitions = pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy)

	local nextIndex
	local stillInBudget = true

	local i = 1
	while(stillInBudget) do
		local idx
		idx, currentIndex, nextIndex = Kruskal.findMin(availableTransitions)
		availableTransitions[idx] = nil

		if(Kruskal.detectCycle(result, currentIndex, nextIndex)) then
		else
			-- if the point we are going to add doesn't go over our budget
			if(currentBudget + MathFunc.distance(result[currentIndex].Point, result[nextIndex].Point) < budget) then
				table.insert(result[currentIndex].Transition, nextIndex)
				currentBudget = PointStructure.score(result)
				currentIndex = nextIndex
				copy[currentIndex] = nil
				Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
				i = i + 1
			else
				stillInBudget = false
			end
		end
	end
	print(i .. " points attained.")

	return result
end
SteinerBudget.steinerBudgetDoubleSearch = steinerBudgetDoubleSearch

-- Algorithm number 2bis:
-- As we know the points given for the exercise, we manually add two really useful transitions
-- This code does not work for a general solution (use 2 instead)
-- in: points
-- in: budget = the maximum budget
-- in: start = the "house"
-- out: a point structure with a solution
local function steinerBudgetDoubleSearchWithPoints (points, budget, start)
	local currentBudget = 0
	local i = 1
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)

	local currentIndex = start
	copy[currentIndex] = nil
	local availableTransitions = pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy)

	local nextIndex
	local stillInBudget = true

	table.insert(result[currentIndex].Transition, 53)
	currentBudget = PointStructure.score(result)
	currentIndex = 53
	copy[currentIndex] = nil
	Utility.merge(availableTransitions, pointsByDistanceFromA(result[53].Point, 53, copy))
	i = i + 1

	table.insert(result[currentIndex].Transition, 13)
	currentBudget = PointStructure.score(result)
	currentIndex = 13
	copy[currentIndex] = nil
	Utility.merge(availableTransitions, pointsByDistanceFromA(result[13].Point, 13, copy))
	i = i + 1

	while(stillInBudget) do
		local idx
		idx, currentIndex, nextIndex = Kruskal.findMin(availableTransitions)
		availableTransitions[idx] = nil

		if(Kruskal.detectCycle(result, currentIndex, nextIndex)) then
		-- if the point we are going to add dsn't go over our budget
		else
			table.insert(result[currentIndex].Transition, nextIndex)
			local backup = PointStructure.clone(result)
			Steiner.optimization3Point(backup)
			if(PointStructure.score(backup) > budget) then
				result[currentIndex].Transition[Utility.tlength(result[currentIndex].Transition)] = nil
				stillInBudget = false
			else
				currentBudget = PointStructure.score(result)
				currentIndex = nextIndex
				copy[currentIndex] = nil
				Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
				i = i + 1
			end
		end
	end
	print(i .. " points attained.")

	return result
end
SteinerBudget.steinerBudgetDoubleSearchWithPoints = steinerBudgetDoubleSearchWithPoints

-- Algorithm number 3:
-- This algorithm applies algorithm number 2, but at the end checks if we can replace an outer transition with an available one
-- With that, we can gain some budget to maybe add another point
-- in: points
-- in: budget = the maximum budget
-- in: start = the "house"
-- out: a point structure with a solution
local function steinerBudgetReorganizing (points, budget, start)
	local currentBudget = 0
	local i = 1
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)

	local currentIndex = start
	copy[currentIndex] = nil
	local availableTransitions = pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy)

	local nextIndex
	local stillInBudget = true

	while(stillInBudget) do
		local idx
		idx, currentIndex, nextIndex = Kruskal.findMin(availableTransitions)
		availableTransitions[idx] = nil

		if(Kruskal.detectCycle(result, currentIndex, nextIndex)) then
		-- if the point we are going to add doesn't go over our budget
		else
			table.insert(result[currentIndex].Transition, nextIndex)
			local backup = PointStructure.clone(result)
			Steiner.optimization3Point(backup)
			if(PointStructure.score(backup) > budget) then
				result[currentIndex].Transition[Utility.tlength(result[currentIndex].Transition)] = nil
				stillInBudget = false
			else
				currentBudget = PointStructure.score(result)
				currentIndex = nextIndex
				copy[currentIndex] = nil
				Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
				i = i + 1
			end
		end
	end

	currentBudget = currentBudget - 1

	while(currentBudget ~= PointStructure.score(result)) do
		currentBudget = PointStructure.score(result)
		local dNext = MathFunc.distance(result[currentIndex].Point, result[nextIndex].Point)
		local change = false

		for _, nochild in pairs(PointStructure.findNoChild(result)) do
			local parent = PointStructure.findParents(result, nochild)[1] -- if the point is in the extremum, it has then only one parent

			if(parent ~= nil) then
				local dNoChild = MathFunc.distance(result[nochild].Point, result[parent].Point)

				if(dNoChild > dNext and nochild ~= currentIndex) then
					change = true
					local slot = {}
					slot.from = parent ; slot.to = nochild ; slot.dist = dNoChild
					table.insert(availableTransitions, slot)

					-- Remove the transition made
					for k, v in pairs(result[parent].Transition) do
						if v == nochild then
							result[parent].Transition[k] = nil
						end
					end

					break
				end
			end
		end

		if(change) then
			copy[currentIndex] = nil
			table.insert(result[currentIndex].Transition, nextIndex)
			currentIndex = nextIndex
			Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
		end

		if(not change) then
			table.insert(result[currentIndex].Transition, nextIndex)
			local myBudget = PointStructure.score(result)
			if(myBudget > budget) then currentBudget = myBudget end
			currentIndex = nextIndex
			copy[currentIndex] = nil
			Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
			i = i + 1
		end

		while(Kruskal.detectCycle(result, currentIndex, nextIndex) and Utility.tlength(availableTransitions) > 0) do
			local idx
			idx, currentIndex, nextIndex = Kruskal.findMin(availableTransitions)
			availableTransitions[idx] = nil
		end
	end

	print(i .. " points attained.")
	return result
end
SteinerBudget.steinerBudgetReorganizing = steinerBudgetReorganizing

-- Algorithm number 3bis:
-- Same as number 2bis, but with algorithm number 3
-- This algorithm does not work in a general case
-- in: points
-- in: budget = the maximum budget
-- in: start = the "house"
-- out: a point structure with a solution
local function steinerBudgetReorganizingWithPoints (points, budget, start)
	local currentBudget = 0
	local i = 1
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)

	local currentIndex = start
	copy[currentIndex] = nil
	local availableTransitions = pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy)

	local nextIndex
	local stillInBudget = true

	table.insert(result[currentIndex].Transition, 53)
	currentBudget = PointStructure.score(result)
	currentIndex = 53
	copy[currentIndex] = nil
	Utility.merge(availableTransitions, pointsByDistanceFromA(result[53].Point, 53, copy))
	i = i + 1

	table.insert(result[currentIndex].Transition, 13)
	currentBudget = PointStructure.score(result)
	currentIndex = 13
	copy[currentIndex] = nil
	Utility.merge(availableTransitions, pointsByDistanceFromA(result[13].Point, 13, copy))
	i = i + 1

	while(stillInBudget) do
		local idx
		idx, currentIndex, nextIndex = Kruskal.findMin(availableTransitions)
		availableTransitions[idx] = nil

		if(Kruskal.detectCycle(result, currentIndex, nextIndex)) then
		-- if the point we are going to add doesn't go over our budget
		else
			table.insert(result[currentIndex].Transition, nextIndex)
			local backup = PointStructure.clone(result)
			Steiner.optimization3Point(backup)
			if(PointStructure.score(backup) > budget) then
				result[currentIndex].Transition[Utility.tlength(result[currentIndex].Transition)] = nil
				stillInBudget = false
			else
				currentBudget = PointStructure.score(result)
				currentIndex = nextIndex
				copy[currentIndex] = nil
				Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
				i = i + 1
			end
		end
	end

	currentBudget = currentBudget - 1

	while(currentBudget ~= PointStructure.score(result)) do
		currentBudget = PointStructure.score(result)
		local dNext = MathFunc.distance(result[currentIndex].Point, result[nextIndex].Point)
		local change = false

		for _, nochild in pairs(PointStructure.findNoChild(result)) do
			local parent = PointStructure.findParents(result, nochild)[1] -- if the point is in the extremum, it has then only one parent

			if(parent ~= nil) then
				local dNoChild = MathFunc.distance(result[nochild].Point, result[parent].Point)

				if(dNoChild > dNext and nochild ~= currentIndex) then
					change = true
					local slot = {}
					slot.from = parent ; slot.to = nochild ; slot.dist = dNoChild
					table.insert(availableTransitions, slot)

					-- Remove the transition made
					for k, v in pairs(result[parent].Transition) do
						if v == nochild then
							result[parent].Transition[k] = nil
						end
					end

					break
				end
			end
		end

		if(change) then
			copy[currentIndex] = nil
			table.insert(result[currentIndex].Transition, nextIndex)
			currentIndex = nextIndex
			Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
		end

		if(not change) then
			table.insert(result[currentIndex].Transition, nextIndex)
			local myBudget = PointStructure.score(result)
			if(myBudget > budget) then currentBudget = myBudget end
			currentIndex = nextIndex
			copy[currentIndex] = nil
			Utility.merge(availableTransitions, pointsByDistanceFromA(result[currentIndex].Point, currentIndex, copy))
			i = i + 1
		end

		while(Kruskal.detectCycle(result, currentIndex, nextIndex) and Utility.tlength(availableTransitions) > 0) do
			local idx
			idx, currentIndex, nextIndex = Kruskal.findMin(availableTransitions)
			availableTransitions[idx] = nil
		end
	end

	print(i .. " points attained.")
	return result
end
SteinerBudget.steinerBudgetReorganizingWithPoints = steinerBudgetReorganizingWithPoints

return SteinerBudget
