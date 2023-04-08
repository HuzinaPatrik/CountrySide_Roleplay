local cameraInteraction

local Viewer = {
	cam = {
		distance = 5,
		maxDistance = 10,
		minDistance = 3,
		move = {
			cursor = Vector2(0, 0),
		},
		matrix = {
			start = {
				position = Vector3(0, 0, 0),
				lookAt = Vector3(0, 0, 0),
			},
			previous = {
				position = Vector3(0, 0, 0),
				lookAt = Vector3(0, 0, 0),
			},
			position = Vector3(0, 0, 0),
			lookAt = Vector3(0, 0, 0),
			center = Matrix(0, 0, 0, 0, 0, 0),
			centerNew = Matrix(0, 0, 0, 0, 0, 0),
		},
	},
	scr = Vector2(guiGetScreenSize()),
	place = Vector3(0, 0, 0),
};

function setupViewer(vehicle)
	local desiredRelativePosition = Vector3(-3, -4, 1)
	local matrix = vehicle.matrix
	local newPosition = matrix:transformPosition(desiredRelativePosition)
	Viewer.cam.matrix.start = {
		position = newPosition,
		lookAt = vehicle.position,
	}
	Viewer.cam.matrix.previous = Viewer.cam.matrix.start
	Viewer.cam.matrix.position = Viewer.cam.matrix.start.position
	Viewer.cam.matrix.lookAt = Viewer.cam.matrix.start.lookAt
	Viewer.cam.matrix.center = Matrix(Viewer.cam.matrix.start.lookAt, Vector3(20, 30, 45))
	Viewer.cam.matrix.centerNew = Matrix(Viewer.cam.matrix.start.lookAt, Vector3(20, 30, 45))
	Viewer.cam.distance = 5
	Viewer.place = vehicle.position
end

function updateCameraMatrix()
	local x, y, z, lx, ly, lz = getCameraMatrix()
	Viewer.cam.matrix.position = Vector3(x, y, z)
	Viewer.cam.matrix.lookAt = Vector3(lx, ly, lz)
	setCameraMatrix(Viewer.cam.matrix.position, Viewer.cam.matrix.lookAtt)
end

function changeCameraMatrix(position_change, lookAt_change)
	updateCameraMatrix()
	setCameraMatrix(position_change, lookAt_change)
	updateCameraMatrix()
end

local dfX, dfY = 0, 0;
isCameraHandler = false;
function cameraMoveHandler()
    if not isCursorShowing() or isCursorInPanel then 
        isCameraHandler = false
        Viewer.cam.matrix.center = Viewer.cam.matrix.centerNew
        removeEventHandler("onClientRender", root, cameraMoveHandler)
        return 
    end 

	local cx, cy = exports['cr_core']:getCursorPosition()
	if(cx and cy) then
		local x, y, z = getCameraMatrix()

		local nfX, nfY = Viewer.cam.move.cursor.x-cx, Viewer.cam.move.cursor.y-cy
		local distance = math.min(Viewer.cam.maxDistance, math.max(Viewer.cam.minDistance, Viewer.cam.distance))
		local centerPosition = Matrix(Viewer.cam.matrix.center:getPosition(), Viewer.cam.matrix.center:getRotation()+Vector3(-(nfY/4), 0, (nfX/4)))
		local position = centerPosition:transformPosition(0, Viewer.cam.distance, 0)		

		if isLineOfSightClear(x,y,z, position) then 
			dfX, dfY = nfX, nfY
			Viewer.cam.matrix.centerNew = centerPosition

			changeCameraMatrix(position, Viewer.cam.matrix.previous.lookAt)
		end 
	end

	if(not getKeyState("mouse1") and not cameraInteraction) then
		isCameraHandler = false
		Viewer.cam.matrix.center = Viewer.cam.matrix.centerNew
		removeEventHandler("onClientRender", root, cameraMoveHandler)
	end
end

isCameraAdjusting = false;
function cameraMoveStart(b, state, x, y)
	if(not isCameraAdjusting and cameraInteraction) then
		if(b == "left" and state == "down") then
			if not isCameraHandler then 
				isCameraHandler = true
				Viewer.cam.move.cursor = Vector2(x, y)
				updateCameraMatrix()
				Viewer.cam.matrix.previous.position = Viewer.cam.matrix.position 
				Viewer.cam.matrix.previous.lookAt = Viewer.cam.matrix.lookAt
				addEventHandler("onClientRender", root, cameraMoveHandler)
			end
		elseif(b == "left" and state == "up") then
			isCameraHandler = false
			Viewer.cam.matrix.center = Viewer.cam.matrix.centerNew
			removeEventHandler("onClientRender", root, cameraMoveHandler)
		end
	end
end


function moveCameraVerticalUp()
	local z = math.min(Viewer.place.z+1.8, math.max(Viewer.place.z+0.05, Viewer.cam.matrix.lookAt.z+0.01))
	changeCameraMatrix(Viewer.cam.matrix.position, Vector3(Viewer.cam.matrix.lookAt.x, Viewer.cam.matrix.lookAt.y, z))
end

function moveCameraVerticalDown()
	local z = math.min(Viewer.place.z+1.8, math.max(Viewer.place.z+0.05, Viewer.cam.matrix.lookAt.z-0.01))
	changeCameraMatrix(Viewer.cam.matrix.position, Vector3(Viewer.cam.matrix.lookAt.x, Viewer.cam.matrix.lookAt.y, z))
end

function cameraMoveZoom(b, state)
	if(cameraInteraction) then
		if(b == "mouse_wheel_up" and state and not isCameraHandler) then
			local x, y, z = getCameraMatrix()
			local nowDistance = math.min(Viewer.cam.maxDistance, math.max(Viewer.cam.minDistance, Viewer.cam.distance-0.2))
			local position = Viewer.cam.matrix.center:transformPosition(0, Viewer.cam.distance, 0)		

			if isLineOfSightClear(x,y,z, position) then 
				Viewer.cam.distance = nowDistance
				changeCameraMatrix(position, Viewer.cam.matrix.lookAt)
			end 
		elseif(b == "mouse_wheel_down" and state and not isCameraHandler) then
			local x, y, z = getCameraMatrix()
			local nowDistance = math.min(Viewer.cam.maxDistance, math.max(Viewer.cam.minDistance, Viewer.cam.distance+0.2))
			local position = Viewer.cam.matrix.center:transformPosition(0, Viewer.cam.distance, 0)		

			if isLineOfSightClear(x,y,z, position) then 
				Viewer.cam.distance = nowDistance
				changeCameraMatrix(position, Viewer.cam.matrix.lookAt)
			end 
		elseif(b == "w" and state and not isCameraHandler) then
			addEventHandler("onClientRender", root, moveCameraVerticalUp)
			isCameraAdjusting = true
		elseif(b == "w" and not state and not isCameraHandler) then
			removeEventHandler("onClientRender", root, moveCameraVerticalUp)
			isCameraAdjusting = false
		elseif(b == "s" and state and not isCameraHandler) then
			addEventHandler("onClientRender", root, moveCameraVerticalDown)
			isCameraAdjusting = true
		elseif(b == "s" and not state and not isCameraHandler) then
			removeEventHandler("onClientRender", root, moveCameraVerticalDown)
			isCameraAdjusting = false
		end
	end
end

function cameraInit(state)
    cameraInteraction = state
	if(state) then
		Camera.setMatrix(Viewer.cam.matrix.start.position, Viewer.cam.matrix.start.lookAt)
		addEventHandler("onClientClick", root, cameraMoveStart)
		addEventHandler("onClientKey", root, cameraMoveZoom)
	else
		removeEventHandler("onClientClick", root, cameraMoveStart)
		removeEventHandler("onClientKey", root, cameraMoveZoom)
		setCameraTarget(localPlayer)
	end
end