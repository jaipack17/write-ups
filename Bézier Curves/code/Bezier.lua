local Bezier = {}
Bezier.__index = Bezier

function Bezier.new(p0, p2)
	local self = setmetatable({
		p0 = p0,
		p2 = p2,
	}, Bezier)
	
	return self 
end

function Bezier:CalculateQuad(t, p1)
	return (1 - t)^2 * self.p0 + 2 * (1 - t) * t * p1 + t^2 * self.p2
end

function Bezier:CalculateCubic(t, p1, p3)
	return (1 - t)^3 * self.p0 + 3 * (1 - t)^2 * t * p1 + 3 * (1 - t) * t^2 * p3 + t^3 * self.p2
end

function Bezier:Quad(t, p1)
	local points = {}
	
	for i = t, 1.0, .01 do
		local segpoint = self:CalculateQuad(i, p1)
		points[#points + 1] = segpoint
	end
	
	return points
end

function Bezier:Cubic(t, p1, p3)
	local points = {}

	for i = t, 1.0, .01 do
		local segpoint = self:CalculateCubic(i, p1, p3)
		points[#points + 1] = segpoint
	end

	return points
end

return Bezier

