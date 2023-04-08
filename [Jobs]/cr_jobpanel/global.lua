jobsList = {
    {
        {
            ["id"] = 1,
            ["name"] = "Buszsofőr",
            ["payment"] = "110",
            ["location"] = {
                ["name"] = "Blueberry",
                ["position"] = {152.42510986328, -34.17387008667, 26.78125},
            },
            ["description"] = "Menj el a térképen jelölt buszpályaudvarra, vedd fel a munkavégzéshez szükséges járművet, majd szállítsd el a megállóban tartózkodó utasokat és vállj Red County legjobb buszsofőrévé.",
        }, -- Job 1 

        {
            ["id"] = 2,
            ["name"] = "Borászat",
            ["payment"] = "500",
            ["location"] = {
                ["name"] = "Red County",
                ["position"] = {1935.1656494141, 160.0121307373, 51.130191802979},
            },
            ["description"] = "Menj és vegyél fel egy munkajárművet majd pakold fel a ládákat. Ezután menj és szüretelj le! Ha minden láda tele van menj le a pincében. Válasz ki egy neked megfelelő hordót majd töltsd bele a ládából a fürtöket. Várd meg ameddig megér majd fedd le és menj a pince aljába és add le!",
        }, -- Job 2
    } , -- Row 1

    {
        {
            ["id"] = 3,
            ["name"] = "Áruszállító",
            ["payment"] = "200",
            ["location"] = {
                ["name"] = "Blueberry",
                ["position"] = {215.86346435547, 14.534826278687, 2.57080078125},
            },
            ["description"] = "Nincs más dolgod mint elmenni a telephelyre, ott felvenni a kapcsolatot a közvetítővel és kiszállítani a megrendelési lista alapján kapott címekre a csomagokat.",
        }, -- Job 1 

        {
            ["id"] = 4,
            ["name"] = "Hentes",
            ["payment"] = "80",
            ["location"] = {
                ["name"] = "Blueberry",
                ["position"] = {207.92121887207, -64.278106689453, 1.578125},
            },
            ["description"] = "Először is vásárolj a munkavégzéshez egy bárdot, majd látogass el a húsfeldolgozó üzembe. A teremben lévő felakasztott disznókat vágd darabokra és add le a szalagnál a húst. A gép végénél a feldolgozott áru dobozba kerül és ezt le kell adnod a raktár másik pontján.",
        }, -- Job 2
    } , -- Row 1
    
    {
        {
            ["id"] = 5,
            ["name"] = "Bányász",
            ["payment"] = "200",
            ["location"] = {
                ["name"] = "Blueberry",
                ["position"] = {65.400650024414, -289.2626953125, 1.578125},
            },
            ["description"] = "Vásárolj a hobbi boltban egy csákányt, majd vedd fel a munkajárművet. Amint ezzel megvagy menj el a térképen jelölt bányába és szedd össze a köveket és rakd a járműved hátuljába. A jármű hátulja amint megtelt, szállítsd le a köveket a megfelelő helyre.",
        }, -- Job 1 

        {
            ["id"] = 6,
            ["name"] = "Favágó",
            ["payment"] = "110",
            ["location"] = {
                ["name"] = "The Panopticon",
                ["position"] = {-488.00061035156, -171.95805358887, 77.1},
            },
            ["description"] = "Vásárolj a hobbi boltban egy baltát, majd vedd fel a munkajárművet. Amint ezzel megvagy menj el a térképen jelölt fatelepre és vágd ki a fákat, darabold fel őket és rakd a járműved hátuljába. A jármű hátulja amint megtelt, szállítsd le a rönköket a megfelelő megrendelőnek.",
        }, -- Job 2
    } , -- Row 1

    {
        {
            ["id"] = 7,
            ["name"] = "Pizzafutár",
            ["payment"] = "100",
            ["location"] = {
                ["name"] = "Montgomery",
                ["position"] = {1362.9362792969, 244.83561706543, 19.5625},
            },
            ["description"] = "Ez a munka kétféle részből áll, így az általunk kedvelt részét választhatjuk. A Montgomeryben lévő lévő pizzahut épületében megrendelések alapján készítheted el a pizzákat, vagy pedig megrendeléseket szállíthatsz ki a vásárlók címére.",
        }, -- Job 1 

        {
            ["id"] = 8,
            ["name"] = "Hotdog árus",
            ["payment"] = "60",
            ["location"] = {
                ["name"] = "Dillimore",
                ["position"] = {622.04113769531, -494.84857177734, 26.5},
            },
            ["description"] = "Látogass el Dillimoreban a Dog house épületbe és megrendelések alapján a vásárlók kívánságait készítheted el.",
        }, -- Job 2
    } , -- Row 1
}

scrollMinLines = 1
scrollMaxLines = 3

jobs = {}

local i = 1 
for k,v in pairs(jobsList) do 
    local data = v 
    if data then 
        jobs[data[1]["id"]] = data[1]
        jobs[data[2]["id"]] = data[2]
    end 
end 

function getJobName(id)
    if jobs[id] then 
        return jobs[id]["name"]
    else 
        return "Munkanélküli"
    end
end