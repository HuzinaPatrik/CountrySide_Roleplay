firstnames = {"Roland", "Frank", "Loth", "Luke", "Paul", "Roy", "Phillip", "Alan", "Jimmy", "Antonio"}
secondsnames = {"Lincoln", "Johns", "Stinson", "Chris", "Craig", "Bryan", "Luis", "Mike", "Lucio", "Benjamin"}

function generateRandomName()
    local theFirstName = firstnames[math.random(1,#firstnames)]
    local theSecondName = secondsnames[math.random(1,#secondsnames)]
    local name = theFirstName .. "_" .. theSecondName
    return name
end 

skinids = {14, 15, 25, 17, 57, 111, 147, 227, 228, 272}

function giveARandomSkin()
    local skinid = skinids[math.random(1,#skinids)]
    return skinid
end