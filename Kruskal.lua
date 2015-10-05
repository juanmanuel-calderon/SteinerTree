--[[
	Contains the Kruskal approach to solve the Steiner Tree Problem.
	The algorithm is:

	KRUSKAL(G):
	1 A = Ø
	2 foreach v ? G.V:
	3    MAKE-SET(v)
	4 foreach (u, v) ordered by weight(u, v), increasing:
	5    if FIND-SET(u) ? FIND-SET(v):
	6       A = A ? {(u, v)}
	7       UNION(u, v)
	8 return A

	(from https://en.wikipedia.org/wiki/Kruskal's_algorithm)
--]]

local Kruskal = {}
local Utility = require("Utility")
local MathFunc = require("MathFunc")
local PointStructure = require("PointStructure")

-- Finds the shortest available edge
-- in: edges = the list of edges
-- out: the index of the transition, the origin and the destination
local function findMin (edges)
	local idx = 0
	local minD = 1000000
	local from
	local to

	for index, slot in pairs(edges) do
		if(slot.dist < minD and slot.dist > 0) then
			minD = slot.dist
			idx = index
			from = slot.from
			to = slot.to
		end
	end

	return idx, from, to
end
Kruskal.findMin = findMin

-- Determines if there were to be a cycle if the transition from->to is added
-- in: points = the structure
-- in: from, to = the origin and destination
-- out: true if there were to be a cycle
local function detectCycle (points, from, to)
	-- destination has a child?
	for i, childTo in pairs(points[to].Transition) do

		-- Case 1: a->b->c->a
		for j, grandchildTo in pairs(points[childTo].Transition) do
			if(grandchildTo == from) then
				return true
			end
		end

		-- Case 2: a->c<-b<-a
		for j, childFrom in pairs(points[from].Transition) do
			if(childTo == childFrom) then
				return true
			end
		end

		-- Recursive call needed if the number of points is greater than 3
		points[to].Transition[i] = nil
		local cycle  = detectCycle(points, from, childTo)
		points[to].Transition[i] = childTo
		if(cycle) then
			return true
		end
	end

	-- destination is a child?
	local parents = PointStructure.findParents(points, to)
	for i, parent in pairs(parents) do
		local fromIdx
		for j, brother in pairs(points[parent].Transition) do

			if(brother == to) then
				fromIdx = j
			end

			-- Case 1: c->b<-a<-c
			if(brother == from) then
				return true
			end

			-- Case 2: a->b<-c<-a
			for j, childFrom in pairs(points[from].Transition) do
				if(brother == childFrom) then
					return true
				end
			end
		end

		-- Recursive call needed if the number of points is greater than 3
		points[parent].Transition[fromIdx] = nil
		local cycle  = detectCycle(points, from, parent)
		points[parent].Transition[fromIdx] = to
		if(cycle) then
			return true
		end
	end

	return false
end
Kruskal.detectCycle = detectCycle

-- Reorganizes the structure to leave only one orphan
-- in: points = the structure
-- out: the only orphan
local function findFirst (points)
	local first

	-- While there is more than one orphan, swap the transitions
	while(Utility.tlength(PointStructure.findOrphans(points)) > 1) do
		local idxA = PointStructure.findOrphans(points)[1]
		local orphan = points[idxA]
		local child = points[orphan.Transition[1]]
		PointStructure.swapTransition(orphan, child, idxA)
	end

	return PointStructure.findOrphans(points)[1]
end
Kruskal.findFirst = findFirst

-- Applies the Kruskal algorithm to find the Steiner Tree
-- in: points
-- out: a solution
local function kruskal (points)
	local edges = {}
	local length = Utility.tlength(points)
	local first

	-- Finds all the possible edges
	for i = 1, length do
		for j = i+1, length do
			local d = MathFunc.distance(points[i].Point, points[j].Point)
			local slot = {}
			slot.from = i
			slot.to = j
			slot.dist = d
			table.insert(edges, slot)
		end
	end

	local result = PointStructure.clone(points)
	local i = 1
	while i < length do -- There are (points-1) transitions
		local from
		local to
		local idx
		idx, from, to = findMin(edges)
		edges[idx].dist = -1

		if(detectCycle(result, from, to)) then
		else
			i = i + 1
			local nbTransition = Utility.tlength(result[from].Transition)
			result[from].Transition[nbTransition + 1] = to
		end
	end
	return result
end
Kruskal.kruskal = kruskal

return Kruskal
