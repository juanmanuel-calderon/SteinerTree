--[[
	Contains the Incremental Optimization Algorithm approach for the Steiner Tree Problem.
	The algorithm is:

	1. Order the fixed points by the distance from their mean, the first being
	closest to it. (This ordering step greatly reduces the dependency of the
	final tree on the initial ordering of the points, although there can still
	be ties.)
	2. Insert a Steiner point between the first three fixed points, connect it
	to each, and locally optimize to obtain the Steiner tree for those three
	points. Call it the current tree.
	3. FOR k = 4; : : : ; n DO
		(a) Save the current tree as oldtree and set besttree to an artificial
		tree with length 1.
		(b) FOR each edge (a; b) of the current tree DO
			i. Place a Steiner point s on the edge (a; b).
			ii. Remove the edge (a; b).
			iii. Add the edges (tk; s), (a; s), (b; s).
			iv. Run the local optimization routine.
			v. If the resulting tree is shorter than besttree, then set besttree
			to this new tree.
			vi. Set the current tree to oldtree.
		(c) Set the current tree to besttree.
	4. Set the final tree to the current tree.

	(from Derek R. Dreyer, Michael L. Overton - Two Heuristics for the Euclidean Steiner Tree Problem)
--]]
local Steiner = {}
local Utility = require("Utility")
local MathFunc = require("MathFunc")
local PointStructure = require("PointStructure")

-- Finds the nearest point to a in the structure
-- in: a = the current point
-- in: points: the available points
-- out: the index of the next point
local function findNextTSP (a, points)
	local minD = 100000000 -- arbitrary, I suppose it is big enough
	local minIndex = -1
	for index, b in pairs(points) do
		local d = MathFunc.distance(a, b.Point)
		if(d < minD) then
			minD = d
			minIndex = index
		end
	end
	return minIndex
end
Steiner.findNextTSP = findNextTSP

-- Gives a solution to the Steiner Tree Problem using the Traveling Salesman Approach
-- in: points = the structure defined in PointStructure.lua
-- in: start = the starting point for the TSP
-- out: the new structure with the transitions
local function TSP_Solution (points, start)
	math.randomseed(os.time())
	local result = PointStructure.clone(points)
	local copy = PointStructure.clone(points)
	local currentIndex = start
	local currentPoint = copy[currentIndex].Point
	copy[currentIndex] = nil

	while(Utility.tlength(copy) > 0) do
		local nextIndex = findNextTSP(currentPoint, copy)
		table.insert(result[currentIndex].Transition, nextIndex)
		currentIndex = nextIndex
		currentPoint = copy[currentIndex].Point
		copy[currentIndex] = nil
	end

	return result
end
Steiner.TSP_Solution = TSP_Solution

-- Construcs the initial graph for the Steiner algorithm
-- This graph is composed by the three first points of the structure + a Steiner point
-- The structure used is a solution of the problem by a TSP algorithm
-- in: points = the structure
-- in: index = the index of the first point
-- out: a new structure for the new graph
local function constructInitialSteiner (points, index)
	local new = {}
	new[1] = {}
	new[1].Point = points[index].Point
	new[1].Transition = {}
	new[1].Transition[1] = 4
	index = points[index].Transition[1]
	new[2] = {}
	new[2].Point = points[index].Point
	new[2].Point = points[index].Point
	new[2].Transition = {}
	index = points[index].Transition[1]
	new[3] = {}
	new[3].Point = points[index].Point
	new[3].Transition = {}

	new[4] = {}
	new[4].Point = {}
	new[4].Point.x, new[4].Point.y = MathFunc.findSteinerPoint(new[1].Point, new[2].Point, new[3].Point)
	new[4].Transition = {}
	new[4].Transition[1] = 2
	new[4].Transition[2] = 3

	return new
end

-- Tests if the new score is better than the current best
-- Return the structure and the new best score
-- in: bestStruct = the current best structure
-- in: best = the current best score
-- in: newStruct = the structure to test
-- out: the best structure and score
local function testScore (bestStruct, bestScore, newStruct)
	local newScore = PointStructure.score(newStruct)
	if (newScore < bestScore) then
		return PointStructure.clone(newStruct), newScore
	else
		return bestStruct, bestScore
	end
end

-- Attemps to find a solution to the Steiner Tree Problem with an Incremental Optimization Approach
-- in: points = the point structure
-- in: start = the starting point for the TSP algorithm
-- out: a structure with a solution
local function steiner (points, start)
	local TSP = TSP_Solution(points, start)
	local best = constructInitialSteiner(TSP, start)
	local nextIndex = TSP[start].Transition[1]
	local sc

	while(nextIndex ~= nil) do -- in the TSP solution, all points have a transition except the last one
		local bestScore = 1000000
		local current = PointStructure.clone(best)
		local n = Utility.tlength(best) + 1 -- the next index for the best solution


		-- add next point
		current[n] = {}
		current[n].Point = TSP[nextIndex].Point
		current[n].Transition = {}
		n = n + 1

		for p = 1, (n-2) do
			local nextTrSpot = Utility.tlength(current[p].Transition) + 1
			current[p].Transition[nextTrSpot] = (n-1)
			best, bestScore = testScore(best, bestScore, current)

			current[p].Transition[nextTrSpot] = nil
		end

		-- steiner point
		current[n] = {}
		current[n].Point = {}
		current[n].Transition = {}
		current[n].Transition[2] = (n-1) -- one of the transitions of the new point will be the destination

		for p = 1, (n-2) do

			local firstPoint = current[p].Point
			for tr, destination in pairs(current[p].Transition) do
				local secondPoint = current[destination].Point

				current[n].Point.x = math.floor((firstPoint.x + secondPoint.x) / 2)
				current[n].Point.y = math.floor((firstPoint.y + secondPoint.y) / 2)

				current[n].Transition[1] = destination
				current[p].Transition[tr] = n
				best, bestScore = testScore(best, bestScore, current)

				current[n].Point.x, current[n].Point.y = MathFunc.findSteinerPoint(firstPoint, secondPoint, current[n-1].Point)

				best, bestScore = testScore(best, bestScore, current)

				current[p].Transition[tr] = destination
				current[n].Transition[1] = nil
			end
		end
		n = n + 1
		nextIndex = TSP[nextIndex].Transition[1]
	end

	return best, 1
end
Steiner.steiner = steiner

-- Optimizes the current Steiner tree
-- Takes three points and if the Steiner Point optimizes the tree, adds it
-- in: points
local function optimization3Point (points)
	local nbPoints = Utility.tlength(points)
	for p = 1, nbPoints do
		local father = points[p]
		local currentTransition = 1

		while (father.Transition[currentTransition] ~= nil) do
			nbPoints = Utility.tlength(points)
			local childIdx = father.Transition[currentTransition]
			local child = points[childIdx]
			local currentTransitionChild = 1

			while (child.Transition[currentTransitionChild] ~= nil) do
				nbPoints = Utility.tlength(points)
				local grandchildIdx = child.Transition[currentTransitionChild]
				local grandchild = points[grandchildIdx]

				local pre = PointStructure.score(points)
				local steinerPoint = {}
				steinerPoint.Point = {}
				steinerPoint.Transition = {}
				steinerPoint.Point.x, steinerPoint.Point.y = MathFunc.findSteinerPoint(father.Point, child.Point, grandchild.Point)

				points[nbPoints + 1] = steinerPoint
				father.Transition[currentTransition] = nbPoints + 1
				steinerPoint.Transition[1] = childIdx
				steinerPoint.Transition[2] = grandchildIdx
				Utility.shift1Left(child.Transition, currentTransitionChild)
				currentTransitionChild = currentTransitionChild - 1

				if(pre <= PointStructure.score(points)) then
					points[nbPoints + 1] = nil
					father.Transition[currentTransition] = childIdx
					currentTransitionChild = currentTransitionChild + 1
					Utility.shift1Right(child.Transition, currentTransitionChild)
					child.Transition[currentTransitionChild] = grandchildIdx
				else
					break
				end
				currentTransitionChild =  currentTransitionChild + 1
			end

			currentTransition = currentTransition + 1
		end
	end
end
Steiner.optimization3Point = optimization3Point

return Steiner
