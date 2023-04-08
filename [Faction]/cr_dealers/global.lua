cinematicConversations = {
    {
        {
            text = "Szevasz te senkiházi köcsög, gondolom nem véletlen vagy itt.",
            conversationTime = 250,
            whoIsTalking = "Dealer",
            promptType = "default",
            selectedPrompt = 1,
            finished = false
        },

        {
            text = "Jelenleg van nálam némi @A, érdekel?",
            conversationTime = 250,
            whoIsTalking = "Dealer",
            promptType = "default",
            selectedPrompt = 1,
            finished = false
        },

        {
            text = "Na, hány darabra gondoltál?",
            conversationTime = 250,
            promptType = {"counting", "slider"},
            selectedPrompt = 1,
            whoIsTalking = "Dealer",
            finished = false
        },

        {
            text = "Szóval @B db @A... milyen árban gondolkoztál?",
            conversationTime = 2000,
            promptType = {"counting", "slider"},
            selectedPrompt = 1,
            selectPrice = true,
            whoIsTalking = "Dealer",
            finished = false
        },

        {
            text = "Akkor meg is volnánk, @B db @A, @C dollár fejében.",
            conversationTime = 2000,
            promptType = false,
            selectedPrompt = 1,
            lastDialog = true,
            whoIsTalking = "Dealer",
            finished = false
        },

        {
            text = "És mivel akarsz fizetni? Takarodj el innen minél előbb.",
            conversationTime = 2000,
            promptType = false,
            selectedPrompt = 1,
            noMoneyDialog = true,
            whoIsTalking = "Dealer",
            finished = false
        },
    }
}

function getConversationIndex(cinematicId, k)
    local result = false

    for i = 1, #cinematicConversations[cinematicId] do 
        local v = cinematicConversations[cinematicId][i]

        if v[k] then 
            result = i
            break
        end
    end

    return result
end

randomLocations = {
    {
        x = 799.56341552734,
        y = -639.6796875,
        z = 16.3359375,

        skinId = 21,
        rotZ = 180,
        id = 1,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = 798.94519042969,
            y = -644.14178466797,
            z = 17.605899810791,
            x2 = 799.08929443359,
            y2 = -643.17114257812,
            z2 = 17.413368225098
        },

        name = exports.cr_core:createRandomMaleName()
    },

    {
        x = 2321.8337402344,
        y = -3.9017753601074,
        z = 26.484375,

        skinId = 20,
        rotZ = 0,
        id = 2,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = 2321.580078125,
            y = -1.0153000354767,
            z = 27.460800170898,
            x2 = 2321.6750488281,
            y2 = -1.9896168708801,
            z2 = 27.25665473938  
        },

        name = exports.cr_core:createRandomFemaleName()
    },

    {
        x = 1341.0278320312,
        y = 286.78955078125,
        z = 12.270609855652,

        skinId = 22,
        rotZ = 210,
        id = 3,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = 1342.0590820312,
            y = 283.54681396484,
            z = 13.559100151062,
            x2 = 1341.8211669922,
            y2 = 284.47799682617,
            z2 = 13.282836914062  
        },

        name = exports.cr_core:createRandomMaleName()
    },

    {
        x = 18.55459022522,
        y = -330.06478881836,
        z = 2.5360660552979,

        skinId = 23,
        rotZ = 210,
        id = 4,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = 19.307399749756,
            y = -334.30178833008,
            z = 3.9489998817444,
            x2 = 19.195308685303,
            y2 = -333.3376159668,
            z2 = 3.7086296081543  
        },

        name = exports.cr_core:createRandomMaleName()
    },

    {
        x = 1416.6375732422,
        y = 214.18240356445,
        z = 19.5546875,

        skinId = 24,
        rotZ = 290,
        id = 5,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = 1420.4279785156,
            y = 215.64309692383,
            z = 20.844200134277,
            x2 = 1419.5122070312,
            y2 = 215.30863952637,
            z2 = 20.621904373169 
        },

        name = exports.cr_core:createRandomMaleName()
    },

    {
        x = -34.830799102783,
        y = -170.00825500488,
        z = 2.9581933021545,

        skinId = 25,
        rotZ = 32,
        id = 6,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = -37.600498199463,
            y = -167.01930236816,
            z = 4.2919001579285,
            x2 = -36.938491821289,
            y2 = -167.73472595215,
            z2 = 4.0684723854065 
        },

        name = exports.cr_core:createRandomMaleName()
    },

    {
        x = 523.29406738281,
        y = -222.93342590332,
        z = 15.529938697815,

        skinId = 55,
        rotZ = 310,
        id = 7,

        interior = 0,
        dimension = 0,

        cameraMatrix = {
            x = 526.93420410156,
            y = -220.4035949707,
            z = 17.024000167847,
            x2 = 526.13220214844,
            y2 = -220.94793701172,
            z2 = 16.777997970581 
        },

        name = exports.cr_core:createRandomFemaleName()
    }
}

maxDealer = 5

availableDrugs = {184, 185, 186}
drugData = {
    [184] = {minPrice = 10000, maxPrice = 100000, minCount = 1, maxCount = 10},
    [185] = {minPrice = 5000, maxPrice = 50000, minCount = 1, maxCount = 10},
    [186] = {minPrice = 2000, maxPrice = 20000, minCount = 1, maxCount = 10},
}

cinematicAnimHeight = 200