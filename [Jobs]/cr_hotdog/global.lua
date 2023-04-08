jobID = 8

markerPositions = {
    --{x,y,z,dim,int},
    {0, 0, 0, 0, 0},
}

vehiclePositions = {
    --{x,y,z,dim,int,rot}
     {0, 0, 0, 0, 0, 0},
}

pizzaPositions = {
    --{x,y,z,dim,int,rot}
    {0, 0, 0, 0, 0, 0},
}

pedSkins = {
    {
        107, 
        7, 
        1, 
    }, -- Férfi

    {
        2,
    }, -- Nő
}

pedPositions = {
    --{x,y,z,rot}
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
}

typeNames = {
    ['croissant'] = 'Kifli: ',
    ['sausage'] = 'Kolbász: ',
    ['sauce'] = 'Szósz: ',
    ['drink'] = 'Ital: ',
}

orderTabs = {
    --[[
        Kiflik
    ]]
    {
        ['name'] = 'Kiflik',

        {
            ['name'] = 'Sima kifli',
            ['imageData'] = {282, 140, ':cr_hotdog/assets/images/croissant/1/icon.png'},
            ['overlayImageData'] = {
                {45, -65, 128, 55, ':cr_hotdog/assets/images/croissant/1/overlay/1.png'},
                {25, -50, 165, 55, ':cr_hotdog/assets/images/croissant/1/overlay/2.png'},
            },
        },
		
		{
            ['name'] = 'Magos kifli',
            ['imageData'] = {282, 140, ':cr_hotdog/assets/images/croissant/2/icon.png'},
            ['overlayImageData'] = {
                {45, -65, 128, 55, ':cr_hotdog/assets/images/croissant/2/overlay/1.png'},
                {25, -50, 165, 55, ':cr_hotdog/assets/images/croissant/2/overlay/2.png'},
            },
        },
		
		{
            ['name'] = 'Teljes kiörlésű kifli',
            ['imageData'] = {282, 140, ':cr_hotdog/assets/images/croissant/3/icon.png'},
            ['overlayImageData'] = {
                {45, -65, 128, 55, ':cr_hotdog/assets/images/croissant/3/overlay/1.png'},
                {25, -50, 165, 55, ':cr_hotdog/assets/images/croissant/3/overlay/2.png'},
            },
        },
    },

    --[[
        Kolbászok
    ]]
    {
        ['name'] = 'Kolbászok',

        {
            ['name'] = 'Sima Kolbász',
            ['imageData'] = {282, 142, ':cr_hotdog/assets/images/sausage/1/icon.png'},
            ['overlayImageData'] = {20, -75, 177, 48, ':cr_hotdog/assets/images/sausage/1/overlay.png'},
        },
		
		{
            ['name'] = 'Olasz kolbász',
            ['imageData'] = {282, 142, ':cr_hotdog/assets/images/sausage/2/icon.png'},
            ['overlayImageData'] = {20, -75, 177, 48, ':cr_hotdog/assets/images/sausage/2/overlay.png'},
        },
		
		{
            ['name'] = 'Sült kolbász',
            ['imageData'] = {282, 142, ':cr_hotdog/assets/images/sausage/3/icon.png'},
            ['overlayImageData'] = {20, -75, 177, 48, ':cr_hotdog/assets/images/sausage/3/overlay.png'},
        },
    },

    --[[
        Szósz
    ]]
    {
        ['name'] = 'Szószok',

        {
            ['name'] = 'Ketchup',
            ['imageData'] = {38, 126, ':cr_hotdog/assets/images/sauce/1/icon.png'},
            ['overlayImageData'] = {33, -70, 151, 23, ':cr_hotdog/assets/images/sauce/1/overlay.png'},
        },
		
		{
            ['name'] = 'Majonéz',
            ['imageData'] = {38, 126, ':cr_hotdog/assets/images/sauce/2/icon.png'},
            ['overlayImageData'] = {33, -70, 151, 23, ':cr_hotdog/assets/images/sauce/2/overlay.png'},
        },
		
		{
            ['name'] = 'Mustár',
            ['imageData'] = {38, 126, ':cr_hotdog/assets/images/sauce/3/icon.png'},
            ['overlayImageData'] = {33, -70, 151, 23, ':cr_hotdog/assets/images/sauce/3/overlay.png'},
        },
    },

    --[[
        Italok
    ]]
    {
        ['name'] = 'Italok',

        {
            ['name'] = 'Coca Cola',
            ['imageData'] = {70, 127, ':cr_hotdog/assets/images/drink/1/icon.png'},
            ['overlayImageData'] = {250, -140, 70, 127, ':cr_hotdog/assets/images/drink/1/overlay.png'},
        },
		
		{
            ['name'] = 'Fanta',
            ['imageData'] = {70, 127, ':cr_hotdog/assets/images/drink/2/icon.png'},
            ['overlayImageData'] = {250, -130, 70, 127, ':cr_hotdog/assets/images/drink/2/overlay.png'},
        },
		
		{
            ['name'] = 'Sprite',
            ['imageData'] = {70, 127, ':cr_hotdog/assets/images/drink/3/icon.png'},
            ['overlayImageData'] = {250, -130, 70, 127, ':cr_hotdog/assets/images/drink/3/overlay.png'},
        },
    },
}