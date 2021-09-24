local Bezier = require(script.Parent.Bezier)
local line = require(script.Parent.Line)

local p0 = canvas.p0.AbsolutePosition + canvas.p0.AbsoluteSize/2 + offset 
local p1 = canvas.p1.AbsolutePosition + canvas.p1.AbsoluteSize/2 + offset 
local p2 = canvas.p2.AbsolutePosition + canvas.p2.AbsoluteSize/2 + offset 
local p3 = canvas.p3.AbsolutePosition + canvas.p3.AbsoluteSize/2 + offset 


local bez = Bezier.new(p0, p2)
local points = QUAD and bez:Quad(0, p1) or bez:Cubic(0, p1, p3)

if QUAD then
  line(p0.x, p0.y, p1.x, p1.y, canvas, 3, Color3.new(1,1,1), l0)
  line(p1.x, p1.y, p2.x, p2.y, canvas, 3, Color3.new(1,1,1), l1)
else
  line(p0.x, p0.y, p1.x, p1.y, canvas, 3, Color3.new(1,1,1), l0)
  line(p1.x, p1.y, p3.x, p3.y, canvas, 3, Color3.new(1,1,1), l1)
  line(p3.x, p3.y, p2.x, p2.y, canvas, 3, Color3.new(1,1,1), l2)
end

for i, p in ipairs(points) do
  local point = game:GetService("ReplicatedStorage").CurvePoint:Clone()
  point.Position = UDim2.new(0, p.x, 0, p.y)
  point.Parent = canvas.Curve

  if points[i - 1] then
    line(points[i - 1].x, points[i - 1].y, p.x, p.y, canvas.Lines, 2, point.BackgroundColor3)
  end
end
