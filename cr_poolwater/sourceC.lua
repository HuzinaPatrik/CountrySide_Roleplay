local poolPos = {
	-- {x1 = , y1 = , z1 = , x2 = , y2 = , z2 = , x3 = , y3 = , z3 = , x4 = , y4 = , z4 = };
	{x1 = 995.8291015625, y1 = -1022.4086303711, z1 = 41.481872558594, x2 = 1006.8908081055, y2 = -1022.3760986328, z2 = 41.481872558594, x3 = 995.83160400391, y3 = -1002.3001708984, z3 = 41.481872558594, x4 = 1006.8330078125, y4 = -1002.4546508789, z4 = 41.481872558594}; -- w broadwaynél a kék medence
	-- {x1 = 702.3515625, y1 = -1063.0892333984, z1 = 45.5, x2 = 719.71868896484, y2 = -1062.8795166016, z2 = 45.5, x3 = 707.15277099609, y3 = -1055.8933105469, z3 = 45.5, x4 = 715.78198242188, y4 = -1040.6103515625, z4 = 45.5}; -- gazdag negyedben [715.66827392578, -1062.9519042969, 46.673736572266]
	
	
};

function createPoolWaters()
	for k,v in ipairs(poolPos) do
		createWater(v.x1,v.y1,v.z1,v.x2,v.y2,v.z2,v.x3,v.y3,v.z3,v.x4,v.y4,v.z4)
	end
    
end
addEventHandler("onClientResourceStart", resourceRoot, createPoolWaters)