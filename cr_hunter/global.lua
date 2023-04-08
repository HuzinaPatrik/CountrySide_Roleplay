animalTypes = {
    --[[
        {modelid, "Name", health, respawnTime, rewardItems {
            {1, 1},
            {1, 2}, {itemid, value, db}
        }}
    ]]
    {318, "Medve", 1000, 10 * 60 * 1000,
        {
            {206, 1, 1},
            {207, 1, 1},
        }
    },
	
	{319, "Hiúz", 800, 8 * 60 * 1000,
        {
            {107, 1, 1},
            {106, 1, 1},
        }
    },
	
	{320, "Őz", 700, 5 * 60 * 1000,
        {
            {208, 1, 1},
            {209, 1, 1},
        }
    },
	
	{321, "Róka", 800, 8 * 60 * 1000,
        {
            {107, 1, 1},
            {106, 1, 1},
        }
    },
	
	{324, "Fekete Párduc", 900, 8 * 60 * 1000,
        {
            {107, 1, 1},
            {106, 1, 1},
        }
    },
	
	{323, "Mosómedve", 600, 3 * 60 * 1000,
        {
            {204, 1, 1},
            {205, 1, 1},
        }
    },
}

animals = {
    --maxDist = spawntól meddig mehet el, damageDist = alapból ha közel mennek hozzá hány métertől támadja meg, ha lövik akkor mindig az legyen az első ne pedig az aki közelebb van
    --{x,y,z,dim,int,rot,name,maxDist,damageDist,type}
	--{-1016.4146728516, -1613.8961181641, 76.3671875, 0, 0, 90, "Hiúz", 75, {28, 16}, 2},
	--{-1049.6561279297, -1636.2894287109, 76.3671875, 0, 0, 90, "Párduc", 95, {28, 16}, 5},
	{798.61090087891, 62.491233825684, 76.330574035645, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{1038.3568115234, -18.133911132812, 87.744361877441, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{1135.6010742188, 28.558109283447, 56.659099578857, 0, 0, 90, "Róka", 15, {28, 25}, 4},
	{891.60528564453, -12.271125793457, 71.889854431152, 0, 0, 90, "Mosómedve", 10, {28, -1}, 6},
	{772.3291015625, -108.77755737305, 22.02799987793, 0, 0, 90, "Őz", 10, {28, -1}, 3},
	{697.68835449219, -303.24258422852, 6.9900646209717, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{572.91558837891, -354.26611328125, 27.865524291992, 0, 0, 90, "Róka", 15, {28, 25}, 4},
	{524.53863525391, -486.24752807617, 41.938571929932, 0, 0, 90, "Róka", 15, {28, 25}, 4},
	{408.4319152832, -839.25225830078, 25.648365020752, 0, 0, 90, "Róka", 15, {28, 25}, 4},
	{496.83578491211, -756.77807617188, 63.52759552002, 0, 0, 90, "Őz", 10, {28, -1}, 3},
	{1127.7673339844, -498.86392211914, 54.336277008057, 0, 0, 90, "Őz", 10, {28, -1}, 3},
	{1174.8200683594, 491.58868408203, 19.002605438232, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{1104.75, 513.92816162109, 21.806016921997, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{1504.9293212891, 293.53314208984, 18.307481765747, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{1521.7231445312, 188.18685913086, 23.28399848938, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{1460.62109375, -176.4061126709, 27.508666992188, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{492.66329956055, 268.29330444336, 12.494661331177, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{-389.52334594727, -106.18539428711, 49.255897521973, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{-384.31460571289, -208.28042602539, 59.425304412842, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	--{-525.27777099609, -211.2615814209, 78.40625, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{-662.69641113281, -196.54429626465, 67.386039733887, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{-871.70318603516, -190.0066986084, 66.109680175781, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{-797.3056640625, 59.135200500488, 37.026859283447, 0, 0, 90, "Róka", 20, {28, 25}, 4},	
	{-650.00408935547, 184.47463989258, 23.948318481445, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{-533.99224853516, 199.6428527832, 12.127807617188, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{-377.69317626953, 222.58988952637, 7.8408203125, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{-325.20126342773, -249.54393005371, 28.129198074341, 0, 0, 90, "Mosómedve", 10, {28, -1}, 6},
	{-987.86102294922, -236.42321777344, 41.880805969238, 0, 0, 90, "Mosómedve", 10, {28, -1}, 6},
	{178.59616088867, -533.26910400391, 44.248344421387, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{253.90063476562, -488.54516601562, 20.222776412964, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{246.61297607422, -625.52795410156, 30.747308731079, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{317.9792175293, -564.05859375, 9.2740993499756, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{45.722927093506, -410.12307739258, 9.9308681488037, 0, 0, 90, "Őz", 10, {28, -1}, 3},
	{-80.739677429199, -690.50433349609, 0.17974090576172, 0, 0, 90, "Őz", 10, {28, -1}, 3},
	{184.81700134277, -929.19683837891, 23.876628875732, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{130.73582458496, -1109.0465087891, 40.218143463135, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{538.60992431641, -825.32250976562, 92.972358703613, 0, 0, 90, "Mosómedve", 10, {28, -1}, 6},
	{738.86437988281, -674.81848144531, 17.626312255859, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{900.09191894531, -468.08038330078, 43.28267288208, 0, 0, 90, "Medve", 20, {25, 30}, 1},
	{887.67242431641, -246.20770263672, 26.818519592285, 0, 0, 90, "Őz", 10, {28, -1}, 3},
	{495.34201049805, -229.22026062012, 12.666813850403, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	--{334.67837524414, -312.03024291992, 0.12149906158447, 0, 0, 180, "Őz", 10, {28, -1}, 3},
	--{-586.29205322266, -25.944164276123, 64.162178039551, 0, 0, 90, "Róka", 20, {28, 25}, 4},
	{-682.97009277344, -102.81867218018, 64.821792602539, 0, 0, 90, "Róka", 20, {28, 25}, 4},
}

texts = {
    {
        --{"szöveg", mp * 1000},
        {"Előveszi a kést", 5000},
        {"Elkezdi megélezni a kést", 5000},
        {"Beledöfi a kést az állat nyakába", 5000},
        {"Elkezdi kegyetlenül megnyúzni az állatot", 5000},
        {"Összegyűjti az állatból a darabkákat", 5000},
    },

    {
        {"Előveszi a kést", 5000},
        {"Elkezdi megélezni a kést", 5000},
        {"Beledöfi a kést az állat nyakába", 5000},
        {"Elkezdi kegyetlenül trófeává alakítani az állatot", 5000},
        {"Összegyűjti az állatból a darabkákat", 5000},
    },
}