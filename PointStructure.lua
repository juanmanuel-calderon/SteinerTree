--[[
	Defines a structure to represent a graph, which includes points and its transitions
	The structure is represented by a list of all the points, containing two fields
		- Point: contains the coordinate X and Y of the point
		- Transition: contains a list of all the other points connected to this point

	For example, the graph
		1 ---> 2 ---> 4
		^      ^
		|      |
		3 <--- 5

	is represented by the structure
			Point	Transition
		1	0 0		2
		2	0 1		4
		3 	1 0		1
		4	2 0
		5	1 1		2 3
	(the coordinates of the points are equal to their position in the diagram)
]]--
local PointStructure = {}
local Utility = require("Utility")
local MathFunc = require("MathFunc")

-- 	Generates the point structure from a string describing the coordinates of the points
--	There are no transitions initially
-- 	in: pointString = a string with the list of points in the form "X Y"
-- 	out: a new structure
local function create (pointString)
	local structure = {}
	local pointList = Utility.splitString(pointString, "\n")
	for index, point in pairs(pointList) do
		local coords = Utility.splitString(point, " ")
		local p = {}
		local structureField = {}
		p.x = coords[1]
		p.y = coords[2]
		structureField["Point"] = p
		structureField["Transition"] = {}
		table.insert(structure, structureField)
	end

	return structure
end
PointStructure.create = create

-- Exports the structure to a text file
-- in: points = the structure
-- in: filename = the name of the file where the structure will be exported
local function export (points, start, filename)
	local f = assert(io.open(filename, "w"))
	f:write(Utility.tlength(points) .. "\n")
	f:write(start .. "\n")

	for _, value in pairs(points) do
		local p = value.Point
		f:write(p.x .. "\t" ..  p.y .. "\n")
	end
	for index, value in pairs(points) do
		local transitions = value.Transition
		for _, value in pairs(transitions) do
			f:write(value .. "\t")
		end
		f:write("\n")
	end

	f:close()
end
PointStructure.export = export

-- Clones the structure
-- in: points = the structure to copy
-- out: a copy of the structure
local function clone (points)
	local inputType = type(points)
	local copy
	if inputType == "table" then	-- a node of the graph
		copy = {}
		for key, value in next, points, nil do
			copy[clone(key)] = clone(value)
		end
	else							-- a coordinate or a destination
		copy = points
	end
	return copy
end
PointStructure.clone = clone

-- Finds the parents of a given point p
-- in: points = the structure
-- in: p = the point to find the parents
-- out: a table with the indexes of the parents of p
local function findParents (points, p)
	local parents = {}
	for i = 1, Utility.tlength(points) do
		for _, child in pairs(points[i].Transition) do
			if(child == p) then
				table.insert(parents, i)
			end
		end
	end

	return parents
end
PointStructure.findParents = findParents

-- Finds the orphan points (the ones without parents)
-- in: points = the structure
-- out: a table with the indexes of the orphan points
local function findOrphans (points)
	local result = {}
	for k, v in pairs(points) do
		if(Utility.tlength(findParents(points, k)) == 0 and (Utility.tlength(v.Transition) > 0)) then
			table.insert(result, k)
		end
	end

	return result
end
PointStructure.findOrphans = findOrphans

-- Finds the points with no childs
-- in: points
-- out: a table with indexes of the points with no child
local function findNoChild (points)
	local result = {}
	for k, v in pairs(points) do
		if(Utility.tlength(v.Transition) == 0) then
			table.insert(result, k)
		end
	end

	return result
end
PointStructure.findNoChild = findNoChild

-- Swaps a transition a->b to b->a
-- in: a, b = the points whose transition we need to swap
-- in: idxA = the index of A
local function swapTransition (a, b, idxA)
	Utility.shift1 (a.Transition)
	local nbTransition = Utility.tlength(b.Transition)
	b.Transition[nbTransition + 1] = idxA
end
PointStructure.swapTransition = swapTransition

-- Prints the structure
-- in: points = the structure
local function toString (points)
	for i, point in pairs(points) do
		print(i, point.Point.x, point.Point.y)
		for j, transition in pairs(point.Transition) do
			print(transition)
		end
	end
	print("")
end
PointStructure.toString = toString

-- Gives a score to the current structure
-- The score is defined by the sum of the length of all the transitions
-- in: points = the point structure
-- out: the score for this structure
local function score (points)
	local score = 0
	for _, p in pairs(points) do
		local startPoint = p.Point
		for _, t in pairs(p.Transition) do
			local endPoint = points[t].Point
			score = score + MathFunc.distance(startPoint, endPoint)
		end
	end
	return score
end
PointStructure.score = score

return PointStructure
