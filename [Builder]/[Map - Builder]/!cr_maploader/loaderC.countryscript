addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setOcclusionsEnabled(false);
        engineSetAsynchronousLoading(true, false);
    end
)

function applyBreakableState()
	for k, obj in pairs(getElementsByType("object", resourceRoot)) do
		local breakable = getElementData(obj, "breakable")
		if breakable then
			setObjectBreakable(obj, true)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, applyBreakableState)