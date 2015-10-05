# SteinerTree
The project approaches the Steiner Tree Problem and a "budget" version of it.
According to Wikipedia, the Steiner Tree Problem is a problem in combinatorial optimization with the common part being that it is required to find the shortest interconnect for a given set of objects.
Given an arbitrary cloud of points, the idea is to find the minimum spanning tree, but with the possibility of adding intermediate vertices and edges to reduce the total size of the tree.
This project tries the Kruskal algorithm (https://en.wikipedia.org/wiki/Kruskal's_algorithm) in Kruskal.lua and an incremental algorithm (https://www.mpi-sws.org/~dreyer/papers/steiner/steiner.pdf) in Steiner.lua.

The Steiner "budget" problem retakes the principle of the STP. Given a cloud of points, a point P from the cloud and a budget B, we try to find the Steiner Tree including reaching the maximum number of points where the total size is smaller than B.
A couple of solution are given in SteinerBudget.lua.
Note: algorithms 2bis and 3bis are only useful for the file input.points that is in the project as it adds specific edges. For the more general solutions see algorithms 2 and 3.

Usage:
  lua main.lua input (budget house)
  
where,
  input is the file defining the points (one point each line, two coordinates par point separated by a space)
  budget (optional) is the maximum budget for the second problem (if now specified, the budget solutions won't be calculated)
  house (optional, only if budget is present) the number of the point used as house for the budget problem. 
