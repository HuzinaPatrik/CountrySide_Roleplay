function toggleControl(element, controlName, value, priority, reload, byResource)
	if sourceResource then
		byResource = getResourceName(sourceResource)
	end

    if byResource then 
        triggerLatentClientEvent(element, "toggleControl", 50000, false, element, controlName, value, priority, reload, byResource)
    end 
end

function toggleAllControls(element, value, priority, byResource)
	if sourceResource then
		byResource = getResourceName(sourceResource)
    end

    if byResource then 
        triggerLatentClientEvent(element, "toggleAllControls", 50000, false, element, value, priority, byResource)
    end 
end 