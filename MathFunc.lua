--[[
	This file contains a couple of useful mathematical functions.
--]]
local MathFunc = {}

-- Gives the distance between two points
-- The distance is defined by sqrt( (bx-ax)^2 + (by-ay)^2 )
-- in: a = the first point
-- in: b = the second point
-- out: the distance between a and b
local function distance (a, b)
	local dx = b.x - a.x
	local dy = b.y - a.y
	return math.sqrt(dx*dx + dy*dy)
end
MathFunc.distance = distance

-- Finds the barycenter of a triangle using the coordinates of the vertices
-- in: a, b, c = the vertices
-- out: the coordinates of the barycenter
local function barycenter (a, b, c)
	local x = (a.x + b.x + c.x)/3
	local y = (a.y + b.y + c.y)/3
	return math.floor(x), math.floor(y)
end
MathFunc.barycenter = barycenter

-- Finds the Steiner Point of a triangle
-- in: a, b, c = the vertices of the triangle
-- out: the coordinates of the Steiner Point
local function findSteinerPoint (a, b, c)
	local ab = distance(a, b)
	local ac = distance(a, c)
	local bc = distance(b, c)
	local angleA = math.acos((-bc*bc + ab*ab + ac*ac) / (2 * ab * ac))
	local angleB = math.acos((-ac*ac + ab*ab + bc*bc) / (2 * ab * bc))
	local angleC = math.acos((-ab*ab + ac*ac + bc*bc) / (2 * ac * bc))

	local part1X = bc / (math.sin(angleA + math.pi/3)) * a.x
	part1X = part1X + ab / (math.sin(angleB + math.pi/3)) * b.x
	part1X = part1X + ac / (math.sin(angleC + math.pi/3)) * c.x

	local part1Y = bc / (math.sin(angleA + math.pi/3)) * a.y
	part1Y = part1Y + ab / (math.sin(angleB + math.pi/3)) * b.y
	part1Y = part1Y + ac / (math.sin(angleC + math.pi/3)) * c.y

	local part2 = bc / (math.sin(angleA + math.pi/3))
	part2 = part2 + ab / (math.sin(angleB + math.pi/3))
	part2 = part2 + ac / (math.sin(angleC + math.pi/3))

	local x = part1X / part2
	local y = part1Y / part2

	return math.floor(x), math.floor(y)
end
MathFunc.findSteinerPoint = findSteinerPoint

return MathFunc
