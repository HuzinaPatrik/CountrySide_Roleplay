white = "#ffffff"

fuelObjectId = 3400
fuelPistolObjectId = 3401

pistolSides = 8
maxDistance = 30

minPetrolPrice = 1
maxPetrolPrice = 5

minDieselPrice = 1
maxDieselPrice = 3

availableFuelTypes = {1, 2, 3, 4}
fuelTypes = { -- ids are based on the server-side fuelPrices table
    [1] = {name = "Premium Petrol", id = 1, defaultValue = "petrol"},
    [2] = {name = "Petrol", id = 1, defaultValue = "petrol"},
    [3] = {name = "Premium Diesel", id = 2, defaultValue = "diesel"},
    [4] = {name = "Diesel", id = 2, defaultValue = "diesel"}
}

wheelSides = {
    bottomLeft = "wheel_lb_dummy",
    bottomRight = "wheel_rb_dummy",
    topLeft = "wheel_lf_dummy",
    topRight = "wheel_rf_dummy",

    bikes = {
        center = "chassis"
    }
}

function rotateAround(angle, x, y, x2, y2)
    local targetX = x2 or 0
    local targetY = y2 or 0
    local centerX = x
    local centerY = y

    local radians = math.rad(angle)
    local rotatedX = targetX + (centerX - targetX) * math.cos(radians) - (centerY - targetY) * math.sin(radians)
    local rotatedY = targetY + (centerX - targetX) * math.sin(radians) + (centerY - targetY) * math.cos(radians)

    return rotatedX, rotatedY
end

function createSpline(points, steps)
    if #points < 3 then
        return points
    end

    local spline = {}

    do
        steps = steps or 3
        steps = 1 / steps

        local count = #points - 1
        local p0, p1, p2, p3, x, y, z

        for i = 1, count do
            if i == 1 then
                p0, p1, p2, p3 = points[i], points[i], points[i + 1], points[i + 2]
            elseif i == count then
                p0, p1, p2, p3 = points[#points - 2], points[#points - 1], points[#points], points[#points]
            else
                p0, p1, p2, p3 = points[i - 1], points[i], points[i + 1], points[i + 2]
            end

            for t = 0, 1, steps do
                x = (1 * ((2 * p1[1]) + (p2[1] - p0[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t * t + (3 * p1[1] - p0[1] - 3 * p2[1] + p3[1]) * t * t * t)) * 0.5
                y = (1 * ((2 * p1[2]) + (p2[2] - p0[2]) * t + (2 * p0[2] - 5 * p1[2] + 4 * p2[2] - p3[2]) * t * t + (3 * p1[2] - p0[2] - 3 * p2[2] + p3[2]) * t * t * t)) * 0.5
                z = (1 * ((2 * p1[3]) + (p2[3] - p0[3]) * t + (2 * p0[3] - 5 * p1[3] + 4 * p2[3] - p3[3]) * t * t + (3 * p1[3] - p0[3] - 3 * p2[3] + p3[3]) * t * t * t)) * 0.5

                local splineId = #spline

                if not (splineId > 0 and spline[splineId][1] == x and spline[splineId][2] == y and spline[splineId][3] == z) then
                    spline[splineId + 1] = {x, y, z}
                end
            end
        end
    end

    return spline
end

function getPositionFromElementOffset(element, offX, offY, offZ)
	if element and isElement(element) then
		local m = getElementMatrix(element)

		local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
		local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
		local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]

		return x, y, z
	end
end