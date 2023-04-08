addEvent("executeCommand", true)
addEventHandler("executeCommand", root,
    function(a, a2)
        executeCommandHandler(a, source, a2)
    end
)