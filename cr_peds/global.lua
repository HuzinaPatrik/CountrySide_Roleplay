cache = {
    --{"Name", Nokill (true = igen, false = nem), type (server, client), nametagType pld:Hambrugeres, {skin, x,y,z,rx,ry,rz,dim,int}},
    --{"Jesse M Black", true, "client", "Eladó (Hamburger)", {107, 1916.6982421875, -1813.3432617188, 13.6484375, 0,0,282, 0,0}, {"fam3", ":cr_texture/files/fam3-2.png"}},
    {"Bruno Davies", true, "client", "Eladó (Autókereskedés)", {132, 1398.4052734375, 398.68313598633, 20.203125, 0,0,68, 0,0}},
    --{"Bruno Davies", true, "client", "Eladó (Autókereskedés)", {133,1395.71875, 392.49252319336, 20.203125, 0,0,63, 0,0}},
    --{"Jesse Lay", true, "client", "Eladó (Hajókereskedés)", {2, 2121.4541015625, -59.465065002441, 1.346866607666, 0,0,255, 0,0}},
    --{"Dave Jhonson", true, "client", "Eladó (Légijárműkereskedés)", {107, 1892.2828369141, -2244.2648925781, 13.546875, 0,0,270, 0,0}},
    {"Elisabeth Internz", true, "client", "Eladó (Ruhabolt)", {9, 207.5502166748, -98.70531463623, 1005.2578125, 0,0,177, 4,15}},
    {"Joseph Internz", true, "client", "Eladó (Ruhabolt)", {9, 207.5502166748, -98.70531463623, 1005.2578125, 0,0,177, 13,15}},
    {"Troy Internz", true, "client", "Eladó (Ruhabolt)", {9, 207.5502166748, -98.70531463623, 1005.2578125, 0,0,177, 14,15}},
    {"Stewart Wilkinson", true, "client", "Buszjárat felelős", {173, 144.79061889648, -33.825969696045, 1.7265625, 0, 0, 268, 0, 0}},
}

pedCache = {}

function getPed(id)
    return pedCache[id]
end