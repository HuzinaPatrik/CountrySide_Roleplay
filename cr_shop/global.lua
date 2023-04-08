global = {
	skin = 1,
	basket = 1885,
	object = {
		7597, -- globalid = 1
	},
	objectMatrices = {
		[7597] = {["values"] = {2.175-0.15, 0.67, 1, --[[ ROT ]] 0, 0, 90, 0, 0, -90}, ["ascending"] = 0.4,},
	},
	radius = 15,
	basketInHand = 324,
	maxWeightInHand = 3,
	maxWeightInBasket = 15,
	maxItemsInHand = 5,
	maxItemsInBasket = 10,
};

preLoadedShelves = {
	[1] = {
		
	},
};

function getElementColShape(e)
	for i, v in pairs(getElementsByType("colshape", resourceRoot)) do
		if(isElementWithinColShape(e, v)) then
			return v
		end
	end
	return false
end

-- {s = matrixLeft:transformPosition(Vector3(2.175-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-0.4-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-0.4-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-0.8-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-0.8-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-1.2-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-1.2-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-1.6-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-1.6-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-2-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-2-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-2.4-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-2.4-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-2.8-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-2.8-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-3.2-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-3.2-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-3.6-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-3.6-0.15, 1.75, 1))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-4-0.15, 0.67, 1)), f = matrixLeft:transformPosition(Vector3(2.175-4-0.15, 1.75, 1))},
										
										-- {s = matrixLeft:transformPosition(Vector3(2.175-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-0.4-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-0.4-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-0.8-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-0.8-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-1.2-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-1.2-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-1.6-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-1.6-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-2-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-2-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-2.4-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-2.4-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-2.8-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-2.8-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-3.2-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-3.2-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-3.6-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-3.6-0.15, 1.75, 1-0.4))},
										-- {s = matrixLeft:transformPosition(Vector3(2.175-4-0.15, 0.67, 1-0.4)), f = matrixLeft:transformPosition(Vector3(2.175-4-0.15, 1.75, 1-0.4))},

-- {s = matrixRight:transformPosition(Vector3(2.175-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-0.4-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-0.4-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-0.8-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-0.8-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-1.2-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-1.2-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-1.6-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-1.6-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-2-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-2-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-2.4-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-2.4-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-2.8-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-2.8-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-3.2-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-3.2-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-3.6-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-3.6-0.15, 1.75, 1))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-4-0.15, 0.67, 1)), f = matrixRight:transformPosition(Vector3(2.175-4-0.15, 1.75, 1))},
										
										-- {s = matrixRight:transformPosition(Vector3(2.175-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-0.4-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-0.4-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-0.8-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-0.8-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-1.2-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-1.2-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-1.6-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-1.6-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-2-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-2-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-2.4-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-2.4-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-2.8-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-2.8-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-3.2-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-3.2-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-3.6-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-3.6-0.15, 1.75, 1-0.4))},
										-- {s = matrixRight:transformPosition(Vector3(2.175-4-0.15, 0.67, 1-0.4)), f = matrixRight:transformPosition(Vector3(2.175-4-0.15, 1.75, 1-0.4))},