--[[
	Contains different approaches to solve the Steiner Tree Problem.
--]]
local Algorithm = {}
local Utility = require("Utility")
local PointStructure = require("PointStructure")

-- Finds the nearest point to a
-- in: a = the current point
-- in: points: the available points
-- out: the index of the next point
local function findNextTSP (a, points)
	local minD = 100000000 -- arbitrary, I suppose it is big enough
	local minIndex = -1
	for index, b in pairs(points) do
		local d = Utility.distance(a, b.Point)
		if(d < minD) then
			minD = d
			minIndex = index
		end
	end
	return minIndex
end

-- Gives a solution to the Steiner Tree Problem using the Traveling Salesman Approach
-- in: points = the structure defined in PointStructure.lua
-- out: the index of the starting point of the salesman
-- out: internally, modifies the structure adding the transitions
local function TSP_Solution (points)
	local copy = PointStructure.clone(points)
	local firstIndex = math.random(Utility.tlength(copy))
	local currentIndex = firstIndex
	local currentPoint = copy[currentIndex].Point
	copy[currentIndex] = nil

	while(Utility.tlength(copy) > 0) do
		local nextIndex = findNextTSP(currentPoint, copy)
		table.insert(points[currentIndex].Transition, nextIndex)
		currentIndex = nextIndex
		currentPoint = copy[currentIndex].Point
		copy[currentIndex] = nil
	end

	return firstIndex
end
Algorithm.TSP_Solution = TSP_Solution

return Algorithm