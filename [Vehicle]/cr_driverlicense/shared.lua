priceSetting = {
--  [ID] = {Min,Max}
	[1] = {50,100}, -- A kategória 
	[2] = {250,300}, -- B kategória 
	[3] = {320,450}, -- C kategória 
	[4] = {500,600}, -- D kategória 
	[5] = {700,850}, -- V kategória 
}

licenseType = {
	{"A kategória",463},  --Motor
	{"B kategória",436},  --Kocsi
	{"C kategória",413},  --Teherautó
	{"D kategória",437},  --Busz
	{"H kategória",473}   --Hajó
}

licenseShop = {
	[1] = {1},
	[2] = {2},
	[3] = {1,2,3,4},
	[4] = {5}
}

licensePed = {
	--skin, x, y, z, rot, int, dim, school name, school type, start x, start y, start z, start rot, start int, start dim, routin type, forgalmi type
	{147, -2034.6838378906, -117.94553375244, 1035.171875, 271, 3, 35, "Sprint Driving School", 1, 2266.8659667969, 23.855714797974, 26.454065322876, 4, 0, 0, 1, 1, 2266.8659667969, 23.855714797974, 26.454065322876, 180, 0, 0},
	{147, -2033.5339355469, -114.35231781006, 1035.171875, 183, 3, 35, "Part Driving School", 2, 2261.6745605469, 24.135713577271, 26.452880859375, 4, 0, 0, 2, 1, 2261.6745605469, 24.135713577271, 26.452880859375, 180, 0, 0},
}

pedType = "Oktató (Jogosítvány)"

licenseReason = {
  --{"--Kérdés--"},                                   "Válasz A",                                  "Válasz B",                   "Válasz C",              jó válasz(számmal)
    {"Útnak minősül-e a közforgalom elől el nem zárt magánút?","Igen.","Csak akkor, ha az út alkalmas kétirányú forgalom lebonyolítására.","Nem.",1},
	{"Mi a járművezető kötelessége, ha a rendőr jelzései ellentétesek valamely közúti jelzéssel?","Köteles a biztonságosabb megoldást választani.","Köteles erre a rendőr figyelmét felhívni.","A rendőr jelzései szerint köteles eljárni.",3},
    {"Milyen irányba haladhatnak tovább az útkereszteződésben a rendőr oldalirányban kinyújtott mindkét karjára merőleges irányból érkezők?","Csak jobbra kis ívben.","Semmilyen irányba, mert ez a karjelzés az útkereszteződésbe való behajtás tilalmát jelenti.","Csak egyenesen vagy jobbra.",2},
    {"A félsorompó rúdja még nyitott helyzetben van, de a fénysorompó már villogó piros fényjelzést ad. Mit kell tennie?","Amennyiben nem lát érkező vasúti járművet, még áthajthat a vasúti átjárón.","Mivel vasúti jármű csak akkor érkezhet, ha a sorompórúd teljesen le van engedve, még nyugodtan áthajthat a vasúti átjárón.","Megáll a vasúti átjáró előtt.",3},
    {"Egyéb jelzés hiányában mekkora sebességgel szabad közlekedni személygépkocsival lakott területen belüli főútvonalon?","Legfeljebb 60 km/h sebességgel.","Legfeljebb 50 km/h sebességgel.","Legfeljebb 70 km/h sebességgel.",2},
    {"Hogyan kell elsőbbséget adni a megkülönböztető jelzéseit használó gépjármű részére?","Félrehúzódással, szükség esetén megállással.","Kizárólag megállással..","Enyhe lassítással.",1},
    {"Szabad-e a közlekedés hatósági ellenőrzését megakadályozni?","Igen, indokolt esetben.","Igen, ha nem értünk egyet az ellenőrzéssel.","Nem.",3},
    {"Hol közlekedhet a gyalogosok zárt csoportja lakott területen kívül főútvonalon?","Az úttesten, annak menetirány szerinti jobb szélén.","Az úttesten, annak menetirány szerinti bal szélén.","A járdán.",1},
	{"Szabad-e előzni, ha az előzés során a megelőzendő jármű mellett nem lehet megfelelő oldaltávolságot tartani?","Igen, de csak az egy nyomon haladó járművek előzése esetén.","Nem.","Igen, de csak motorkerékpárral.",2},
	{"Ha a motor üzemi hőmérséklete nem éri el a 80 Celsius fokot, ... ","akkor a hűtőrendszer kiegyenlítő tartálya kiürült, után kell tölteni.","akkor tovább közlekedni nem szabad, azonnal szakszervízhez kell fordulni.","akkor a motor teljesítménye csökken, fogyasztása nő, kenése romlik.",3},
	{"Elromlott személygépkocsija lakott területen az úttesten áll. Ezt a járművet, elakadást jelző háromszöggel...","meg szabad jelölni.","meg kell jelölni.","tilos megjelölni.",1},
	{"Hol szabad tompított fényszóró helyett távolsági fényszórót használni?","A fényjelzés kivételével csak lakott területen.","Kizárólag autópályán.","A fényjelzés kivételével csak lakott területen kívül.",3},
	{"Szabad-e lakott területen kívül a távolsági fényszórót fényjelzés céljából használni?","Nem.","Igen, ha ez a közlekedés többi résztvevőjét nem vakítja el.","Igen, ha elsőbbségünkről akarunk lemondani.",2},
	{"A veszélyt jelző táblákat követően milyen távolságban kell számítani a veszélyes helyre?","Lakott területen 50-100 m, autópályán 250-500 m, lakott területen kívül egyéb úton 150-250 m távolságban.","Lakott területen 25 m, lakott területen kívül 50 m távolságban.","Minden esetben a veszélyt jelző tábla alatt elhelyezett kiegészítő táblán megjelölt távolságban.",1},
}

licenseRoutin = {
	-- keyek kategória alapján vannak megadva, nem a pedes szar alapján
	[1] = { -- A kategóriának a rutin pályája
		{2256.9558105469, 23.578521728516, 26.455757141113, "next"},
		{2237.8051757812, 30.536905288696, 26.040235519409, "park"},
		{2226.095703125, 58.113338470459, 25.94895362854, "next"},
		{2279.2629394531, 89.625137329102, 25.933738708496, "park"},
		{2296.4526367188, 126.85329437256, 25.94987487793, "next"},
		{2237.6730957031, 143.7204284668, 25.936479568481, "next"},
		{2221.7666015625, 56.424331665039, 25.94183921814, "park"},
		{2252.8889160156, 33.39351272583, 26.09211730957, "next"},
		{2269.2719726562, 24.800373077393, 26.055652618408, "end"},

	},
	[2] = { -- B kategóriának a rutin pályája
		{2256.9558105469, 23.578521728516, 26.455757141113, "next"},
		{2237.8051757812, 30.536905288696, 26.040235519409, "park"},
		{2226.095703125, 58.113338470459, 25.94895362854, "next"},
		{2279.2629394531, 89.625137329102, 25.933738708496, "park"},
		{2296.4526367188, 126.85329437256, 25.94987487793, "next"},
		{2237.6730957031, 143.7204284668, 25.936479568481, "next"},
		{2221.7666015625, 56.424331665039, 25.94183921814, "park"},
		{2252.8889160156, 33.39351272583, 26.09211730957, "next"},
		{2269.2719726562, 24.800373077393, 26.055652618408, "end"},
	},
	[5] = {
		{1770.8918457031, -2896.9184570313, 0.42452123761177, "next"},
		{1706.6778564453, -2929.4584960938, -1.2940144538879, "park"},
		{1671.9813232422, -2969.521484375, 0.24030245840549, "end"},
	}, -- h kategóriának a rutin pályája
}

licenseTraffic = {
	-- első key a forgalmi id, másik a kategória id
	[1] = { -- 1-es forgalmi pályához a B és a C kategória rutin pályái
		[1] = {
			{2258.515625, 24.820743560791, 26.048736572266, "next"},
			{2226.1398925781, 53.78609085083, 25.944452285767, "next"},
			{2210.0356445312, 85.769271850586, 25.547151565552, "next"},
			{2129.0454101562, 94.592239379883, 31.931743621826, "next"},
			{2015.9750976562, 106.96997070312, 28.861066818237, "next"},
			{1911.6795654297, 138.59173583984, 34.534503936768, "next"},
			{1848.1285400391, 177.54925537109, 31.564277648926, "next"},
			{1766.5620117188, 200.40576171875, 25.875247955322, "next"},
			{1688.240234375, 235.74453735352, 13.078485488892, "next"},
			{1640.7406005859, 264.72616577148, 19.312475204468, "next"},
			{1585.1408691406, 262.50616455078, 15.680540084839, "next"},
			{1519.1037597656, 244.89033508301, 17.095357894897, "next"},
			{1470.8269042969, 210.94400024414, 18.64864730835, "next"},
			{1423.4659423828, 207.32566833496, 18.145244598389, "next"},
			{1390.2664794922, 226.39120483398, 19.017339706421, "next"},
			{1407.7365722656, 268.82083129883, 19.015129089355, "next"},
			{1339.7823486328, 304.96920776367, 19.019889831543, "next"},
			{1330.0357666016, 337.4192199707, 19.009386062622, "next"},
			{1372.2375488281, 430.55236816406, 19.307189941406, "next"},
			{1334.8873291016, 469.23275756836, 19.488084793091, "next"},
			{1193.0749511719, 541.77764892578, 19.481189727783, "next"},
			{1087.3533935547, 575.51721191406, 19.494766235352, "next"},
			{1001.380859375, 440.85202026367, 19.486280441284, "next"},
			{857.21319580078, 350.37866210938, 19.495098114014, "next"},
			{585.25134277344, 294.06216430664, 18.08376121521, "next"},
			{408.9909362793, 148.90466308594, 7.4323563575745, "next"},
			{326.2200012207, 87.092056274414, 3.1084878444672, "next"},
			{230.19758605957, 33.311752319336, 2.0234141349792, "next"},
			{216.40432739258, -20.35147857666, 1.0437363386154, "next"},
			{180.73481750488, -54.531772613525, 1.0374734401703, "next"},
			{130.89402770996, -90.387084960938, 1.0355851650238, "next"},
			{131.02137756348, -187.40347290039, 1.0490446090698, "next"},
			{150.76086425781, -214.58950805664, 1.0392631292343, "next"},
			{201.87121582031, -214.45712280273, 1.0381073951721, "next"},
			{235.27975463867, -196.5139465332, 1.0455305576324, "next"},
			{234.20967102051, -117.01136016846, 1.0402693748474, "next"},
			{248.44139099121, -74.225692749023, 1.0404542684555, "next"},
			{280.61184692383, -87.514907836914, 1.0433022975922, "next"},
			{298.90414428711, -144.53804016113, 1.0299706459045, "next"},
			{383.94683837891, -145.50788879395, 3.6846282482147, "next"},
			{519.40399169922, -168.25126647949, 36.906875610352, "next"},
			{489.99142456055, -317.67413330078, 38.760860443115, "next"},
			{441.453125, -498.95486450195, 41.614059448242, "next"},
			{456.68182373047, -601.90081787109, 36.499389648438, "next"},
			{585.26123046875, -645.05804443359, 22.592018127441, "next"},
			{641.49163818359, -641.64135742188, 16.8779296875, "next"},
			{662.33343505859, -602.23889160156, 15.797485351562, "next"},
			{705.19128417969, -601.62750244141, 15.786049842834, "next"},
			{723.34600830078, -512.07946777344, 15.799696922302, "next"},
			{699.77862548828, -483.11990356445, 15.796803474426, "next"},
			{642.90087890625, -470.24163818359, 15.791836738586, "next"},
			{562.92706298828, -413.00381469727, 27.770343780518, "next"},
			{483.01388549805, -364.51300048828, 29.954544067383, "next"},
			{492.74737548828, -328.50354003906, 37.153606414795, "next"},
			{519.72711181641, -202.31156921387, 36.466651916504, "next"},
			{576.07250976562, -150.01931762695, 33.687049865723, "next"},
			{766.39678955078, -165.7283782959, 18.121459960938, "next"},
			{1002.2280273438, -184.59239196777, 20.610738754272, "next"},
			{1135.7990722656, -184.080078125, 41.357955932617, "next"},
			{1262.2586669922, -113.78340911865, 37.756309509277, "next"},
			{1364.5814208984, -25.130229949951, 33.746952056885, "next"},
			{1494.4505615234, 82.090789794922, 29.645498275757, "next"},
			{1600.4213867188, 127.77295684814, 29.345161437988, "next"},
			{1819.2774658203, 66.128868103027, 34.9377784729, "next"},
			{1979.0582275391, 37.154891967773, 31.684522628784, "next"},
			{2167.5275878906, 39.871505737305, 25.931224822998, "next"},
			{2240.0539550781, 39.548244476318, 25.948587417603, "next"},
			{2261.3400878906, 24.433340072632, 26.052625656128, "end"},
		},
		[2] = {
			{2258.515625, 24.820743560791, 26.048736572266, "next"},
			{2226.1398925781, 53.78609085083, 25.944452285767, "next"},
			{2210.0356445312, 85.769271850586, 25.547151565552, "next"},
			{2129.0454101562, 94.592239379883, 31.931743621826, "next"},
			{2015.9750976562, 106.96997070312, 28.861066818237, "next"},
			{1911.6795654297, 138.59173583984, 34.534503936768, "next"},
			{1848.1285400391, 177.54925537109, 31.564277648926, "next"},
			{1766.5620117188, 200.40576171875, 25.875247955322, "next"},
			{1688.240234375, 235.74453735352, 13.078485488892, "next"},
			{1640.7406005859, 264.72616577148, 19.312475204468, "next"},
			{1585.1408691406, 262.50616455078, 15.680540084839, "next"},
			{1519.1037597656, 244.89033508301, 17.095357894897, "next"},
			{1470.8269042969, 210.94400024414, 18.64864730835, "next"},
			{1423.4659423828, 207.32566833496, 18.145244598389, "next"},
			{1390.2664794922, 226.39120483398, 19.017339706421, "next"},
			{1407.7365722656, 268.82083129883, 19.015129089355, "next"},
			{1339.7823486328, 304.96920776367, 19.019889831543, "next"},
			{1330.0357666016, 337.4192199707, 19.009386062622, "next"},
			{1372.2375488281, 430.55236816406, 19.307189941406, "next"},
			{1334.8873291016, 469.23275756836, 19.488084793091, "next"},
			{1193.0749511719, 541.77764892578, 19.481189727783, "next"},
			{1087.3533935547, 575.51721191406, 19.494766235352, "next"},
			{1001.380859375, 440.85202026367, 19.486280441284, "next"},
			{857.21319580078, 350.37866210938, 19.495098114014, "next"},
			{585.25134277344, 294.06216430664, 18.08376121521, "next"},
			{408.9909362793, 148.90466308594, 7.4323563575745, "next"},
			{326.2200012207, 87.092056274414, 3.1084878444672, "next"},
			{230.19758605957, 33.311752319336, 2.0234141349792, "next"},
			{216.40432739258, -20.35147857666, 1.0437363386154, "next"},
			{180.73481750488, -54.531772613525, 1.0374734401703, "next"},
			{130.89402770996, -90.387084960938, 1.0355851650238, "next"},
			{131.02137756348, -187.40347290039, 1.0490446090698, "next"},
			{150.76086425781, -214.58950805664, 1.0392631292343, "next"},
			{201.87121582031, -214.45712280273, 1.0381073951721, "next"},
			{235.27975463867, -196.5139465332, 1.0455305576324, "next"},
			{234.20967102051, -117.01136016846, 1.0402693748474, "next"},
			{248.44139099121, -74.225692749023, 1.0404542684555, "next"},
			{280.61184692383, -87.514907836914, 1.0433022975922, "next"},
			{298.90414428711, -144.53804016113, 1.0299706459045, "next"},
			{383.94683837891, -145.50788879395, 3.6846282482147, "next"},
			{519.40399169922, -168.25126647949, 36.906875610352, "next"},
			{489.99142456055, -317.67413330078, 38.760860443115, "next"},
			{441.453125, -498.95486450195, 41.614059448242, "next"},
			{456.68182373047, -601.90081787109, 36.499389648438, "next"},
			{585.26123046875, -645.05804443359, 22.592018127441, "next"},
			{641.49163818359, -641.64135742188, 16.8779296875, "next"},
			{662.33343505859, -602.23889160156, 15.797485351562, "next"},
			{705.19128417969, -601.62750244141, 15.786049842834, "next"},
			{723.34600830078, -512.07946777344, 15.799696922302, "next"},
			{699.77862548828, -483.11990356445, 15.796803474426, "next"},
			{642.90087890625, -470.24163818359, 15.791836738586, "next"},
			{562.92706298828, -413.00381469727, 27.770343780518, "next"},
			{483.01388549805, -364.51300048828, 29.954544067383, "next"},
			{492.74737548828, -328.50354003906, 37.153606414795, "next"},
			{519.72711181641, -202.31156921387, 36.466651916504, "next"},
			{576.07250976562, -150.01931762695, 33.687049865723, "next"},
			{766.39678955078, -165.7283782959, 18.121459960938, "next"},
			{1002.2280273438, -184.59239196777, 20.610738754272, "next"},
			{1135.7990722656, -184.080078125, 41.357955932617, "next"},
			{1262.2586669922, -113.78340911865, 37.756309509277, "next"},
			{1364.5814208984, -25.130229949951, 33.746952056885, "next"},
			{1494.4505615234, 82.090789794922, 29.645498275757, "next"},
			{1600.4213867188, 127.77295684814, 29.345161437988, "next"},
			{1819.2774658203, 66.128868103027, 34.9377784729, "next"},
			{1979.0582275391, 37.154891967773, 31.684522628784, "next"},
			{2167.5275878906, 39.871505737305, 25.931224822998, "next"},
			{2240.0539550781, 39.548244476318, 25.948587417603, "next"},
			{2261.3400878906, 24.433340072632, 26.052625656128, "end"},
		},
	},
	[2] = { -- 2-es forgalmi pálya
		[5] = { -- h kategória
			{1585.3217773438, -2929.7604980469, 0.80625331401825, "next"},
			{1634.8848876953, -2936.2395019531, 0.45766451954842, "end"},
		},
	},
}

actorInteract = {

	[1] = {
		["col-shape-leave"] = {
			{"Nem nagyon kőne erre felí menni."}, --{"Erre nem kellene elkószálni.."},
			{"Vissza kőne fordulni hé, vagy jogos nélkű maradol."}, --{"Vissza kellene menni, másképp megbuktatlak."},
			{"Én azé vissza mennék."}, --{"Jobban jársz ha vissza mész!"},
			{"Ott a csikk hé, vissza menjé de izibe."}, --{"Nem gondolod, hogy vissza kéne menni?"}
		},
		["col-shape-hit"] = {
			{"Íííha de jó itt he, nem akarod te elhagyni ezt a helyöt."}, --{"Jól tetted, hogy vissza jöttél.."},
			{"Legalább nem köllöt keménykednöm véled.. *visszacsúsztatja a viperát*"}, --{"Szerencséd nem kellet többet figyelmeztetni.."},
			{"Ezé most bedurrantok pár fekete pontot."}, --{"Ezért most kapsz pár rossz pontot!"}
		},
		["col-shape-warning"] = {
			{"Na most betelt a bili.."}, --{"Szerintem eleget figyelmeztettelek!"},
			{"Feküdj a fékre, most gatya.."}, --{"Itt meg is állhatsz!"},
			{"Csapjad ide felé a volánt, innentől én vagyok a kapitány.."}, --{"Innestől vezetek!"},
			{"Takarodó van, a rosszbaj álljon beléd, remélem nem látlak többet.."}, --{"Remélem nem találkozunk többet.."}
		},
		["random-voice"] = {
			{"Kurvásul meleg van, tekerjed le azt az életmentő cuccot, nem dísznök van."}, --{"Elég meleg van ebben a kocsiban, nem?"},
			{"Szivarkámat előrántom nem gond, iga?"}, --{"Zavar ha rágyújtok egy cigire?"},
			{"6 gatyóm van, abból mind a 6 vizes olyan dög melög van."}, --{"Manapság nehéz ebben a melegben."},
			{"Én azé csak társalognék a papival.."}, --{"Nem kötelező ám csendbe lenni.. *nevetve*"},
			{"A seriffel vigyázzá komé.. olyan csekköt köt a gatyódra hogy a hónapba csak kutya csonton fogsz élni.."}, --{"A yardal óvatosan, adnak olyan csekket, hogy a hónapba nem eszel.."},
			{"Mesélj, tágítottak már meg a fakabátok?"}, --{"Mesélj, voltál már büntetve?"},
			{"Ilyen otromba utakon se koptattam még a gumikat.. pláne egy ilyen amatőrrel mint te.. *nevetve*"}, --{"Manapság a kormány elég sz@r utakat csinál.."},
			{"Tartsd vissza felé a verejtéket, ha megbukol akkor én csak jól járok.. *nevetve*"}, --{"Nem kell izgulni, ha megbuksz többet keresek.. *nevetve*"},
			{"Pipámból kérsz?"}, --{"Kérsz egy cigit?"},
			{"Ebbe a kis faluba a lánykákat szeretöm a legjobban, ha van időd less be hozzájuk.."}, --{"Ebbe a városba a csajokat szeretem a legjobban.."},
			{"Szólj ha kussoljak.."}, --{"Ugye nem zavar ha jártatom a szám?"},
			{"Vigyázzá erre a szekérre, ez nem lopott.."}, --{"Vigyázz a kocsira, ha össze töröd kifizeted.."},
			{"Még egy gumifüst, aztán a picsád is füstölni fog.."}, --{"Meg ne lássam, hogy füstöl a gumi.."},
			{"Leszívhatjuk a maradékot a kútbó ha szar a hölyzet.."}, --{"Benzinnel, hogy állunk?"},
			{"Mi a hölyzet a vájúval? Kissé baszakszik a belem.."}, --{"Nem ismersz valami jó kajáldát?"},
			{"Kof.. koffen.. faszba bele, hogy hííják? Jaa, koffein. Kőne már egy szünet.."}, --{"Inni kellene egy jó kávét."},
			{"Gólya mikor csapott a faluba?"}, --{"Új vagy a városba?"},
			{"Első szekérnek én a lábaidat ajánlom."}, --{"Első kocsinak van már elképzelés?"},
			{"Maradj a gyári lovaknál, az újakkal csak a gond van.."}, --{"Vigyázz a használt kocsikkal, némeiket drágábban adják mint az újat.."},
			{"Csapd le a gatyát, ilyen meleg a világon még nem volt soha."}, --{"Neked nincs meleged?"},
			{"Íjha de szar ez a meló, bár még mindig jobb mint a szar lapátolás.."}, --{"Kezdem unni ezt a munkát.."},
			{"Küdd meg a gázpedált, vagy ha nem..."}, --{"Nem akarsz a gázra lépni?"},
			{"Muzsikát ne kapcsolj 100-as hangerő alatt.."}, --{"Ha zenét kapcsolnál, nem bánnám. *nevetve*"},
			{"Nálam jobb vizsgabiztost, vagy hogy híjjákot nem kaphattá vóna."}, --{"Jól jártál, hogy engem fogtál ki. *nevetve*"},
			{"Szólj ha kussoljak."}, --{"Ugye nem beszélek sokat?"},
			{"Rohadjak meg de a tükörbe jobban néző ki."}, --{"Olyan jól nézek ki a tükörbe. *nevetve*"},
			{"Ha az öv nincs a helyén akkor fejed az ülés alatt legyen."}, --{"Ugye az övedet bekötötted?"},
			{"Ilyen csudajó orcát te.. megint magamról beszélek. *nevetve*"}, --{"Bűn ilyen szépnek lenni, de ne érts félre magamra montam. *nevetve*"},
			{"Forróbik vagy?"}, --{"Te Ugye nem vagy meleg?"},
			{"Határnál figyeljé, akkor szívnak amikor nem látod.."}, --{"Vigyázz a határnál, van ott pár pénzes lány aki nem a legjobb! *nevetve*"},
			{"Máskor fürdjé meg.."}, --{"Neked se van kifejezetten baba arcod. *nevetve*"}
		},
		["ped-belt"] = {
			{"Most csapjam ki pár rágódat vagy bekötöd az öved?"}, --{"Kösd be az öved.."},
			{"A nadrágszíjadat se szoktad bekötni ahogy látom.."}, --{"Nem ártana azt az övet bekötni."},
			{"Bekötöd, vagy kiszállok és nyakon baszlak.."}, --{"Megkérhetlek, hogy kösd be az öved?"},
			{"Forgalom nincs, de helyette én foglak kibaszni az ablakon ha nem kötöd be az övedet.."}, --{"Igaz nincs forgalom, de kösd már be az övet."}
		},
		["damage-veh"] = {
			{"Mutasd a tárcád, hadd lássam mennyid van.."}, --{"Ez a törés drága lesz."},
			{"Csipádat kapard mán ki.."}, --{"Figyelhetnél jobban is!"},
			{"Fizetsz, vagy ledolgozod?"}, --{"Ezt Ugye tudod, hogy kifizeted?"},
			{"Na akkor most jöhet a csekk vagy ledolgozod?"}, --{"Ezt a törést már számlázom is."}
		},
		["speed-veh"] = {
			{"Feküdj már rá a fékre is néha.."}, --{"Lassíts mert megbuktatlak."},
			{"Ez nem a forma 1-es versenypálya, lassíthatnál is néha.."}, --{"Nem kellene ilyen gyorsan menni.."},
			{"Én csak betartanám a sebességet.."}, --{"Nem gondolod, hogy be kellene tartani a sebesség határt?"},
			{"Nem kell a racsing, feküdj rá a fékre.."}, --{"Nem egy versenyautó ez, lassíts.."},
			{"Ha meg akarsz bukni, akkor gyorsan csináld.. Lassíts."}, --{"Ha nem akarsz megbukni akkor jobban teszed ha lassítasz.."}
		}
	},
	
	[2] = {
		["col-shape-leave"] = {
			{"Nem nagyon kőne erre felí menni."}, --{"Erre nem kellene elkószálni.."},
			{"Vissza kőne fordulni hé, vagy jogos nélkű maradol."}, --{"Vissza kellene menni, másképp megbuktatlak."},
			{"Én azé vissza mennék."}, --{"Jobban jársz ha vissza mész!"},
			{"Ott a csikk hé, vissza menjé de izibe."}, --{"Nem gondolod, hogy vissza kéne menni?"}
		},
		["col-shape-hit"] = {
			{"Íííha de jó itt he, nem akarod te elhagyni ezt a helyöt."}, --{"Jól tetted, hogy vissza jöttél.."},
			{"Legalább nem köllöt keménykednöm véled.. *visszacsúsztatja a viperát*"}, --{"Szerencséd nem kellet többet figyelmeztetni.."},
			{"Ezé most bedurrantok pár fekete pontot."}, --{"Ezért most kapsz pár rossz pontot!"}
		},
		["col-shape-warning"] = {
			{"Na most betelt a bili.."}, --{"Szerintem eleget figyelmeztettelek!"},
			{"Feküdj a fékre, most gatya.."}, --{"Itt meg is állhatsz!"},
			{"Csapjad ide felé a volánt, innentől én vagyok a kapitány.."}, --{"Innestől vezetek!"},
			{"Takarodó van, a rosszbaj álljon beléd, remélem nem látlak többet.."}, --{"Remélem nem találkozunk többet.."}
		},
		["random-voice"] = {
			{"Kurvásul meleg van, tekerjed le azt az életmentő cuccot, nem dísznök van."}, --{"Elég meleg van ebben a kocsiban, nem?"},
			{"Szivarkámat előrántom nem gond, iga?"}, --{"Zavar ha rágyújtok egy cigire?"},
			{"6 gatyóm van, abból mind a 6 vizes olyan dög melög van."}, --{"Manapság nehéz ebben a melegben."},
			{"Én azé csak társalognék a papival.."}, --{"Nem kötelező ám csendbe lenni.. *nevetve*"},
			{"A seriffel vigyázzá komé.. olyan csekköt köt a gatyódra hogy a hónapba csak kutya csonton fogsz élni.."}, --{"A yardal óvatosan, adnak olyan csekket, hogy a hónapba nem eszel.."},
			{"Mesélj, tágítottak már meg a fakabátok?"}, --{"Mesélj, voltál már büntetve?"},
			{"Ilyen otromba utakon se koptattam még a gumikat.. pláne egy ilyen amatőrrel mint te.. *nevetve*"}, --{"Manapság a kormány elég sz@r utakat csinál.."},
			{"Tartsd vissza felé a verejtéket, ha megbukol akkor én csak jól járok.. *nevetve*"}, --{"Nem kell izgulni, ha megbuksz többet keresek.. *nevetve*"},
			{"Pipámból kérsz?"}, --{"Kérsz egy cigit?"},
			{"Ebbe a kis faluba a lánykákat szeretöm a legjobban, ha van időd less be hozzájuk.."}, --{"Ebbe a városba a csajokat szeretem a legjobban.."},
			{"Szólj ha kussoljak.."}, --{"Ugye nem zavar ha jártatom a szám?"},
			{"Vigyázzá erre a szekérre, ez nem lopott.."}, --{"Vigyázz a kocsira, ha össze töröd kifizeted.."},
			{"Még egy gumifüst, aztán a picsád is füstölni fog.."}, --{"Meg ne lássam, hogy füstöl a gumi.."},
			{"Leszívhatjuk a maradékot a kútbó ha szar a hölyzet.."}, --{"Benzinnel, hogy állunk?"},
			{"Mi a hölyzet a vájúval? Kissé baszakszik a belem.."}, --{"Nem ismersz valami jó kajáldát?"},
			{"Kof.. koffen.. faszba bele, hogy hííják? Jaa, koffein. Kőne már egy szünet.."}, --{"Inni kellene egy jó kávét."},
			{"Gólya mikor csapott a faluba?"}, --{"Új vagy a városba?"},
			{"Első szekérnek én a lábaidat ajánlom."}, --{"Első kocsinak van már elképzelés?"},
			{"Maradj a gyári lovaknál, az újakkal csak a gond van.."}, --{"Vigyázz a használt kocsikkal, némeiket drágábban adják mint az újat.."},
			{"Csapd le a gatyát, ilyen meleg a világon még nem volt soha."}, --{"Neked nincs meleged?"},
			{"Íjha de szar ez a meló, bár még mindig jobb mint a szar lapátolás.."}, --{"Kezdem unni ezt a munkát.."},
			{"Küdd meg a gázpedált, vagy ha nem..."}, --{"Nem akarsz a gázra lépni?"},
			{"Muzsikát ne kapcsolj 100-as hangerő alatt.."}, --{"Ha zenét kapcsolnál, nem bánnám. *nevetve*"},
			{"Nálam jobb vizsgabiztost, vagy hogy híjjákot nem kaphattá vóna."}, --{"Jól jártál, hogy engem fogtál ki. *nevetve*"},
			{"Szólj ha kussoljak."}, --{"Ugye nem beszélek sokat?"},
			{"Rohadjak meg de a tükörbe jobban néző ki."}, --{"Olyan jól nézek ki a tükörbe. *nevetve*"},
			{"Ha az öv nincs a helyén akkor fejed az ülés alatt legyen."}, --{"Ugye az övedet bekötötted?"},
			{"Ilyen csudajó orcát te.. megint magamról beszélek. *nevetve*"}, --{"Bűn ilyen szépnek lenni, de ne érts félre magamra montam. *nevetve*"},
			{"Forróbik vagy?"}, --{"Te Ugye nem vagy meleg?"},
			{"Határnál figyeljé, akkor szívnak amikor nem látod.."}, --{"Vigyázz a határnál, van ott pár pénzes lány aki nem a legjobb! *nevetve*"},
			{"Máskor fürdjé meg.."}, --{"Neked se van kifejezetten baba arcod. *nevetve*"}
		},
		["ped-belt"] = {
			{"Most csapjam ki pár rágódat vagy bekötöd az öved?"}, --{"Kösd be az öved.."},
			{"A nadrágszíjadat se szoktad bekötni ahogy látom.."}, --{"Nem ártana azt az övet bekötni."},
			{"Bekötöd, vagy kiszállok és nyakon baszlak.."}, --{"Megkérhetlek, hogy kösd be az öved?"},
			{"Forgalom nincs, de helyette én foglak kibaszni az ablakon ha nem kötöd be az övedet.."}, --{"Igaz nincs forgalom, de kösd már be az övet."}
		},
		["damage-veh"] = {
			{"Mutasd a tárcád, hadd lássam mennyid van.."}, --{"Ez a törés drága lesz."},
			{"Csipádat kapard mán ki.."}, --{"Figyelhetnél jobban is!"},
			{"Fizetsz, vagy ledolgozod?"}, --{"Ezt Ugye tudod, hogy kifizeted?"},
			{"Na akkor most jöhet a csekk vagy ledolgozod?"}, --{"Ezt a törést már számlázom is."}
		},
		["speed-veh"] = {
			{"Feküdj már rá a fékre is néha.."}, --{"Lassíts mert megbuktatlak."},
			{"Ez nem a forma 1-es versenypálya, lassíthatnál is néha.."}, --{"Nem kellene ilyen gyorsan menni.."},
			{"Én csak betartanám a sebességet.."}, --{"Nem gondolod, hogy be kellene tartani a sebesség határt?"},
			{"Nem kell a racsing, feküdj rá a fékre.."}, --{"Nem egy versenyautó ez, lassíts.."},
			{"Ha meg akarsz bukni, akkor gyorsan csináld.. Lassíts."}, --{"Ha nem akarsz megbukni akkor jobban teszed ha lassítasz.."}
		}
	},
	
	[3] = {
		["col-shape-leave"] = {
			{"Nem nagyon kőne erre felí menni."}, --{"Erre nem kellene elkószálni.."},
			{"Vissza kőne fordulni hé, vagy jogos nélkű maradol."}, --{"Vissza kellene menni, másképp megbuktatlak."},
			{"Én azé vissza mennék."}, --{"Jobban jársz ha vissza mész!"},
			{"Ott a csikk hé, vissza menjé de izibe."}, --{"Nem gondolod, hogy vissza kéne menni?"}
		},
		["col-shape-hit"] = {
			{"Íííha de jó itt he, nem akarod te elhagyni ezt a helyöt."}, --{"Jól tetted, hogy vissza jöttél.."},
			{"Legalább nem köllöt keménykednöm véled.. *visszacsúsztatja a viperát*"}, --{"Szerencséd nem kellet többet figyelmeztetni.."},
			{"Ezé most bedurrantok pár fekete pontot."}, --{"Ezért most kapsz pár rossz pontot!"}
		},
		["col-shape-warning"] = {
			{"Na most betelt a bili.."}, --{"Szerintem eleget figyelmeztettelek!"},
			{"Feküdj a fékre, most gatya.."}, --{"Itt meg is állhatsz!"},
			{"Csapjad ide felé a volánt, innentől én vagyok a kapitány.."}, --{"Innestől vezetek!"},
			{"Takarodó van, a rosszbaj álljon beléd, remélem nem látlak többet.."}, --{"Remélem nem találkozunk többet.."}
		},
		["random-voice"] = {
			{"Kurvásul meleg van, tekerjed le azt az életmentő cuccot, nem dísznök van."}, --{"Elég meleg van ebben a kocsiban, nem?"},
			{"Szivarkámat előrántom nem gond, iga?"}, --{"Zavar ha rágyújtok egy cigire?"},
			{"6 gatyóm van, abból mind a 6 vizes olyan dög melög van."}, --{"Manapság nehéz ebben a melegben."},
			{"Én azé csak társalognék a papival.."}, --{"Nem kötelező ám csendbe lenni.. *nevetve*"},
			{"A seriffel vigyázzá komé.. olyan csekköt köt a gatyódra hogy a hónapba csak kutya csonton fogsz élni.."}, --{"A yardal óvatosan, adnak olyan csekket, hogy a hónapba nem eszel.."},
			{"Mesélj, tágítottak már meg a fakabátok?"}, --{"Mesélj, voltál már büntetve?"},
			{"Ilyen otromba utakon se koptattam még a gumikat.. pláne egy ilyen amatőrrel mint te.. *nevetve*"}, --{"Manapság a kormány elég sz@r utakat csinál.."},
			{"Tartsd vissza felé a verejtéket, ha megbukol akkor én csak jól járok.. *nevetve*"}, --{"Nem kell izgulni, ha megbuksz többet keresek.. *nevetve*"},
			{"Pipámból kérsz?"}, --{"Kérsz egy cigit?"},
			{"Ebbe a kis faluba a lánykákat szeretöm a legjobban, ha van időd less be hozzájuk.."}, --{"Ebbe a városba a csajokat szeretem a legjobban.."},
			{"Szólj ha kussoljak.."}, --{"Ugye nem zavar ha jártatom a szám?"},
			{"Vigyázzá erre a szekérre, ez nem lopott.."}, --{"Vigyázz a kocsira, ha össze töröd kifizeted.."},
			{"Még egy gumifüst, aztán a picsád is füstölni fog.."}, --{"Meg ne lássam, hogy füstöl a gumi.."},
			{"Leszívhatjuk a maradékot a kútbó ha szar a hölyzet.."}, --{"Benzinnel, hogy állunk?"},
			{"Mi a hölyzet a vájúval? Kissé baszakszik a belem.."}, --{"Nem ismersz valami jó kajáldát?"},
			{"Kof.. koffen.. faszba bele, hogy hííják? Jaa, koffein. Kőne már egy szünet.."}, --{"Inni kellene egy jó kávét."},
			{"Gólya mikor csapott a faluba?"}, --{"Új vagy a városba?"},
			{"Első szekérnek én a lábaidat ajánlom."}, --{"Első kocsinak van már elképzelés?"},
			{"Maradj a gyári lovaknál, az újakkal csak a gond van.."}, --{"Vigyázz a használt kocsikkal, némeiket drágábban adják mint az újat.."},
			{"Csapd le a gatyát, ilyen meleg a világon még nem volt soha."}, --{"Neked nincs meleged?"},
			{"Íjha de szar ez a meló, bár még mindig jobb mint a szar lapátolás.."}, --{"Kezdem unni ezt a munkát.."},
			{"Küdd meg a gázpedált, vagy ha nem..."}, --{"Nem akarsz a gázra lépni?"},
			{"Muzsikát ne kapcsolj 100-as hangerő alatt.."}, --{"Ha zenét kapcsolnál, nem bánnám. *nevetve*"},
			{"Nálam jobb vizsgabiztost, vagy hogy híjjákot nem kaphattá vóna."}, --{"Jól jártál, hogy engem fogtál ki. *nevetve*"},
			{"Szólj ha kussoljak."}, --{"Ugye nem beszélek sokat?"},
			{"Rohadjak meg de a tükörbe jobban néző ki."}, --{"Olyan jól nézek ki a tükörbe. *nevetve*"},
			{"Ha az öv nincs a helyén akkor fejed az ülés alatt legyen."}, --{"Ugye az övedet bekötötted?"},
			{"Ilyen csudajó orcát te.. megint magamról beszélek. *nevetve*"}, --{"Bűn ilyen szépnek lenni, de ne érts félre magamra montam. *nevetve*"},
			{"Forróbik vagy?"}, --{"Te Ugye nem vagy meleg?"},
			{"Határnál figyeljé, akkor szívnak amikor nem látod.."}, --{"Vigyázz a határnál, van ott pár pénzes lány aki nem a legjobb! *nevetve*"},
			{"Máskor fürdjé meg.."}, --{"Neked se van kifejezetten baba arcod. *nevetve*"}
		},
		["ped-belt"] = {
			{"Most csapjam ki pár rágódat vagy bekötöd az öved?"}, --{"Kösd be az öved.."},
			{"A nadrágszíjadat se szoktad bekötni ahogy látom.."}, --{"Nem ártana azt az övet bekötni."},
			{"Bekötöd, vagy kiszállok és nyakon baszlak.."}, --{"Megkérhetlek, hogy kösd be az öved?"},
			{"Forgalom nincs, de helyette én foglak kibaszni az ablakon ha nem kötöd be az övedet.."}, --{"Igaz nincs forgalom, de kösd már be az övet."}
		},
		["damage-veh"] = {
			{"Mutasd a tárcád, hadd lássam mennyid van.."}, --{"Ez a törés drága lesz."},
			{"Csipádat kapard mán ki.."}, --{"Figyelhetnél jobban is!"},
			{"Fizetsz, vagy ledolgozod?"}, --{"Ezt Ugye tudod, hogy kifizeted?"},
			{"Na akkor most jöhet a csekk vagy ledolgozod?"}, --{"Ezt a törést már számlázom is."}
		},
		["speed-veh"] = {
			{"Feküdj már rá a fékre is néha.."}, --{"Lassíts mert megbuktatlak."},
			{"Ez nem a forma 1-es versenypálya, lassíthatnál is néha.."}, --{"Nem kellene ilyen gyorsan menni.."},
			{"Én csak betartanám a sebességet.."}, --{"Nem gondolod, hogy be kellene tartani a sebesség határt?"},
			{"Nem kell a racsing, feküdj rá a fékre.."}, --{"Nem egy versenyautó ez, lassíts.."},
			{"Ha meg akarsz bukni, akkor gyorsan csináld.. Lassíts."}, --{"Ha nem akarsz megbukni akkor jobban teszed ha lassítasz.."}
		}
	},
	
	--Sima
	--[[[1] = {
		["col-shape-leave"] = {
			{"Erre nem kellene elkószálni.."},
			{"Vissza kellene menni, másképp megbuktatlak."},
			{"Jobban jársz ha vissza mész!"},
			{"Nem gondolod, hogy vissza kéne menni?"}
		},
		["col-shape-hit"] = {
			{"Jól tetted, hogy vissza jöttél.."},
			{"Szerencséd nem kellet többet figyelmeztetni.."},
			{"Ezért most kapsz pár rossz pontot!"}
		},
		["col-shape-warning"] = {
			{"Szerintem eleget figyelmeztettelek!"},
			{"Itt meg is állhatsz!"},
			{"Innestől vezetek!"},
			{"Remélem nem találkozunk többet.."}
		},
		["random-voice"] = {
			{"Elég meleg van ebben a kocsiban, nem?"},
			{"Zavar ha rágyújtok egy cigire?"},
			{"Manapság nehéz ebben a melegben."},
			{"Nem kötelező ám csendbe lenni.. *nevetve*"},
			{"A yardal óvatosan, adnak olyan csekket, hogy a hónapba nem eszel.."},
			{"Mesélj, voltál már büntetve?"},
			{"Manapság a kormány elég szar utakat csinál.."},
			{"Nem kell izgulni, ha megbuksz többet keresek.. *nevetve*"},
			{"Kérsz egy cigit?"},
			{"Ebbe a városba a csajokat szeretem a legjobban.."},
			{"Ugye nem zavar ha jártatom a szám?"},
			{"Vigyázz a kocsira, ha össze töröd kifizeted.."},
			{"Meg ne lássam, hogy füstöl a gumi.."},
			{"Benzinnel, hogy állunk?"},
			{"Nem ismersz valami jó kajáldát?"},
			{"Inni kellene egy jó kávét."},
			{"Új vagy a városba?"},
			{"Első kocsinak van már elképzelés?"},
			{"Vigyázz a használt kocsikkal, némeiket drágábban adják mint az újat.."},
			{"Neked nincs meleged?"},
			{"Kezdem unni ezt a munkát.."},
			{"Nem akarsz a gázra lépni?"},
			{"Ha zenét kapcsolnál, nem bánnám. *nevetve*"},
			{"Jól jártál, hogy engem fogtál ki. *nevetve*"},
			{"Ugye nem beszélek sokat?"},
			{"Olyan jól nézek ki a tükörbe. *nevetve*"},
			{"Ugye az övedet bekötötted?"},
			{"Bűn ilyen szépnek lenni, de ne érts félre magamra montam. *nevetve*"},
			{"Te Ugye nem vagy meleg?"},
			{"Vigyázz a határnál, van ott pár pénzes lány aki nem a legjobb! *nevetve*"},
			{"Neked se van kifejezetten baba arcod. *nevetve*"}
		},
		["ped-belt"] = {
			{"Kösd be az öved.."},
			{"Nem ártana azt az övet bekötni."},
			{"Megkérhetlek, hogy kösd be az öved?"},
			{"Igaz nincs forgalom, de kösd már be az övet."}
		},
		["damage-veh"] = {
			{"Ez a törés drága lesz."},
			{"Figyelhetnél jobban is!"},
			{"Ezt ugye tudod, hogy kifizeted?"},
			{"Ezt a törést már számlázom is."}
		},
		["speed-veh"] = {
			{"Lassíts mert megbuktatlak."},
			{"Nem kellene ilyen gyorsan menni.."},
			{"Nem gondolod, hogy be kellene tartani a sebesség határt?"},
			{"Nem egy versenyautó ez, lassíts.."},
			{"Ha nem akarsz megbukni akkor jobban teszed ha lassítasz.."}
		}
	},
	--Erőszakos
	[2] = {
		["col-shape-leave"] = {
			{"Nem mennék ide a helyedbe, sok a köcsög."}, --{"Erre nem kellene elkószálni.."},
			{"Azért jó lenne vissza menni, különben rád verek párat."}, --{"Vissza kellene menni, másképp megbuktatlak."},
			{"Takarodjál már vissza!"}, --{"Jobban jársz ha vissza mész!"},
			{"Menj már vissza, hát hülye vagy?!"}, --{"Nem gondolod, hogy vissza kéne menni?"}
		},
		["col-shape-hit"] = {
			{"Reméltem hogy vissza jössz, különben megvannak rá az embereim."}, --{"Jól tetted, hogy vissza jöttél.."},
			{"Nagyon nagy szerencséd hogy nem kellett benyúljak a kesztyűtartóba."}, --{"Szerencséd nem kellet többet figyelmeztetni.."},
			{"Akkor egyből 3 minuszponttal kezdünk.."}, --{"Ezért most kapsz pár rossz pontot!"}
		},
		["col-shape-warning"] = {
			{"Szerintem elég sok esélyt kaptál, már az elsőnél ki akartalak baszni."}, --{"Szerintem eleget figyelmeztettelek!"},
			{"Itt akkor meg is állhatsz, én vissza viszem a kocsit te meg gyalogolj."}, --{"Itt meg is állhatsz!"},
			{"Innentől vezetek, te meg takarodj vissza oda ahonnan jöttél."}, --{"Innestől vezetek!"},
			{"Remélem hogy nem fogjuk többet egymást látni."}, --{"Remélem nem találkozunk többet.."}
		},
		["random-voice"] = {
			{"Tekerd már le azt a kurva ablakot!"}, --{"Elég meleg van ebben a kocsiban, nem?"},
			{"Nem érdekel hogy zavar vagy sem, elviseled *rágyújt egy cigire*."}, --{"Zavar ha rágyújtok egy cigire?"},
			{"Nehéz ebben a melegben, de veled még nehezebb.."}, --{"Manapság nehéz ebben a melegben."},
			{"Örülök hogy nem pofázol."}, --{"Nem kötelező ám csendbe lenni.. *nevetve*"},
			{"Rendőrökkel bassz ki ahogy tudsz, jól teszik ha majd megbasznak."}, --{"A yardal óvatosan, adnak olyan csekket, hogy a hónapba nem eszel.."},
			{"Remélem már párszor az élet végén voltál anyagilag.."}, --{"Mesélj, voltál már büntetve?"},
			{"Szar a kormány, és az utak is. De te még szarabb vagy."}, --{"Manapság a kormány elég szar utakat csinál.."},
			{"Jó lenne ha megbuknál, nekem jobban kell a pénz mint neked."}, --{"Nem kell izgulni, ha megbuksz többet keresek.. *nevetve*"},
			{"Nem fogsz cigit kapni, ne is álmodj."}, --{"Kérsz egy cigit?"},
			{"Ilyen jó csajokat mint amilyenek itt vannak, de téged még le se szopnának.. *nevetve*"}, --{"Ebbe a városba a csajokat szeretem a legjobban.."},
			{"Remélem hogy zavar a pofázásom."}, --{"Ugye nem zavar ha jártatom a szám?"},
			{"A kocsit úgy törd össze ahogy tudod, legalább neked kell kifizetned.."}, --{"Vigyázz a kocsira, ha össze töröd kifizeted.."},
			{"Gumit csak füstöltesd ahogy tudod."}, --{"Meg ne lássam, hogy füstöl a gumi.."},
			{"Ha a benzin kifogy, akkor majd te tolod a kocsit és én meg nézem."}, --{"Benzinnel, hogy állunk?"},
			{"Hiába kérdeznélek a kajáldákról, ekkora pancsernak semmi tapasztalata nincs."}, --{"Nem ismersz valami jó kajáldát?"},
			{"Kellene már egy jó kávé, de te fizeted a sajátodat."}, --{"Inni kellene egy jó kávét."},
			{"Új vagy a városban? Elég szarul ismered a környéket.."}, --{"Új vagy a városba?"},
			{"Első kocsin ne is gondolkodj, lehet még jogsid se lesz.."}, --{"Első kocsinak van már elképzelés?"},
			{"Használt kocsi néha drágább mint a gyári, de azért a drágábbat vedd, neked az való.."}, --{"Vigyázz a használt kocsikkal, némeiket drágábban adják mint az újat.."},
			{"Zsepit adjak? Úgy folyik rólad a víz mint ha a csapból folyna.."}, --{"Neked nincs meleged?"},
			{"Ilyenek miatt mint te, megy el a kedvem a munkától.."}, --{"Kezdem unni ezt a munkát.."},
			{"Taposs már bele abba a kurva gázba, lemegy a nap mire visszaérünk!"}, --{"Nem akarsz a gázra lépni?"},
			{"Zenét ki fog kapcsolni?"}, --{"Ha zenét kapcsolnál, nem bánnám. *nevetve*"},
			{"A lehető legjobb embert fogtad ki erre a vizsgára.. *nevetve*"}, --{"Jól jártál, hogy engem fogtál ki. *nevetve*"},
			{"Nem érdekel ha sokat beszélek, meg amúgy te se érdekelsz. *nevetve*"}, --{"Ugye nem beszélek sokat?"},
			{"Olyan jól nézek ki a tükörbe."}, --{"Olyan jól nézek ki a tükörbe. *nevetve*"},
			{"Remélem az övedet nem kötötted be, legalább több pénz jön nekem."}, --{"Ugye az övedet bekötötted?"},
			{"Ilyen szép embert mint én, ez már bűnnek mondható."}, --{"Bűn ilyen szépnek lenni, de ne érts félre magamra montam. *nevetve*"},
			{"Ha buzi vagy akkor most szállj ki, az biztos hogy nem érek hozzád."}, --{"Te Ugye nem vagy meleg?"},
			{"A határnál több kurva van mint normális csaj, de neked azok is valók."}, --{"Vigyázz a határnál, van ott pár pénzes lány aki nem a legjobb! *nevetve*"},
			{"Hát nem neked van a legszebb pofád, az biztos."}, --{"Neked se van kifejezetten baba arcod. *nevetve*"}
		},
		["ped-belt"] = {
			{"Kösd be az övedet!"}, --{"Kösd be az öved.."},
			{"Kösd már be azt a kurva övet!"}, --{"Nem ártana azt az övet bekötni."},
			{"Na ide figyelj, vagy bekötöd az öved vagy már most megbuktatlak a faszba!"}, --{"Megkérhetlek, hogy kösd be az öved?"},
			{"Leszarom a forgalmat, vagy bekötöd az öved vagy én kötöm ki a sajátomat és megyek el!"}, --{"Igaz nincs forgalom, de kösd már be az övet."}
		},
		["damage-veh"] = {
			{"Hát ez a törés sokba fog fájni, csak nem nekem."}, --{"Ez a törés drága lesz."},
			{"Figyeljél, vagy akár meg is állhatunk!"}, --{"Figyelhetnél jobban is!"},
			{"Remélem tudod hogy ennek a dupláját fogod kifizetni!"}, --{"Ezt Ugye tudod, hogy kifizeted?"},
			{"Akkor ezt a törést már fel is írom, dupláját pláne."}, --{"Ezt a törést már számlázom is."}
		},
		["speed-veh"] = {
			{"Taposs a fékbe, vagy most megbuktatlak!"}, --{"Lassíts mert megbuktatlak."},
			{"Ha még egyszer ilyen gyorsan mész akkor nem kell többet vezetned!"}, --{"Nem kellene ilyen gyorsan menni.."},
			{"Nem dísznek van a sebességkorlát, tartsd be!"}, --{"Nem gondolod, hogy be kellene tartani a sebesség határt?"},
			{"Ez nem egy versenyautó, lassíts vagy megbuktatlak!"}, --{"Nem egy versenyautó ez, lassíts.."},
			{"Ha ezt még egyszer megpróbálod akkor nem kell többet, lassíts!"}, --{"Ha nem akarsz megbukni akkor jobban teszed ha lassítasz.."}
		}
	},
	--Paraszt
	[3] = {
		["col-shape-leave"] = {
			{"Nem nagyon kőne erre felí menni."}, --{"Erre nem kellene elkószálni.."},
			{"Vissza kőne fordulni hé, vagy jogos nélkű maradol."}, --{"Vissza kellene menni, másképp megbuktatlak."},
			{"Én azé vissza mennék."}, --{"Jobban jársz ha vissza mész!"},
			{"Ott a csikk hé, vissza menjé de izibe."}, --{"Nem gondolod, hogy vissza kéne menni?"}
		},
		["col-shape-hit"] = {
			{"Íííha de jó itt he, nem akarod te elhagyni ezt a helyöt."}, --{"Jól tetted, hogy vissza jöttél.."},
			{"Legalább nem köllöt keménykednöm véled.. *visszacsúsztatja a viperát*"}, --{"Szerencséd nem kellet többet figyelmeztetni.."},
			{"Ezé most bedurrantok pár fekete pontot."}, --{"Ezért most kapsz pár rossz pontot!"}
		},
		["col-shape-warning"] = {
			{"Na most betelt a bili.."}, --{"Szerintem eleget figyelmeztettelek!"},
			{"Feküdj a fékre, most gatya.."}, --{"Itt meg is állhatsz!"},
			{"Csapjad ide felé a volánt, innentől én vagyok a kapitány.."}, --{"Innestől vezetek!"},
			{"Takarodó van, a rosszbaj álljon beléd, remélem nem látlak többet.."}, --{"Remélem nem találkozunk többet.."}
		},
		["random-voice"] = {
			{"Kurvásul meleg van, tekerjed le azt az életmentő cuccot, nem dísznök van."}, --{"Elég meleg van ebben a kocsiban, nem?"},
			{"Szivarkámat előrántom nem gond, iga?"}, --{"Zavar ha rágyújtok egy cigire?"},
			{"6 gatyóm van, abból mind a 6 vizes olyan dög melög van."}, --{"Manapság nehéz ebben a melegben."},
			{"Én azé csak társalognék a papival.."}, --{"Nem kötelező ám csendbe lenni.. *nevetve*"},
			{"A seriffel vigyázzá komé.. olyan csekköt köt a gatyódra hogy a hónapba csak kutya csonton fogsz élni.."}, --{"A yardal óvatosan, adnak olyan csekket, hogy a hónapba nem eszel.."},
			{"Mesélj, tágítottak már meg a fakabátok?"}, --{"Mesélj, voltál már büntetve?"},
			{"Ilyen otromba utakon se koptattam még a gumikat.. pláne egy ilyen amatőrrel mint te.. *nevetve*"}, --{"Manapság a kormány elég sz@r utakat csinál.."},
			{"Tartsd vissza felé a verejtéket, ha megbukol akkor én csak jól járok.. *nevetve*"}, --{"Nem kell izgulni, ha megbuksz többet keresek.. *nevetve*"},
			{"Pipámból kérsz?"}, --{"Kérsz egy cigit?"},
			{"Ebbe a kis faluba a lánykákat szeretöm a legjobban, ha van időd less be hozzájuk.."}, --{"Ebbe a városba a csajokat szeretem a legjobban.."},
			{"Szólj ha kussoljak.."}, --{"Ugye nem zavar ha jártatom a szám?"},
			{"Vigyázzá erre a szekérre, ez nem lopott.."}, --{"Vigyázz a kocsira, ha össze töröd kifizeted.."},
			{"Még egy gumifüst, aztán a picsád is füstölni fog.."}, --{"Meg ne lássam, hogy füstöl a gumi.."},
			{"Leszívhatjuk a maradékot a kútbó ha szar a hölyzet.."}, --{"Benzinnel, hogy állunk?"},
			{"Mi a hölyzet a vájúval? Kissé baszakszik a belem.."}, --{"Nem ismersz valami jó kajáldát?"},
			{"Kof.. koffen.. faszba bele, hogy hííják? Jaa, koffein. Kőne már egy szünet.."}, --{"Inni kellene egy jó kávét."},
			{"Gólya mikor csapott a faluba?"}, --{"Új vagy a városba?"},
			{"Első szekérnek én a lábaidat ajánlom."}, --{"Első kocsinak van már elképzelés?"},
			{"Maradj a gyári lovaknál, az újakkal csak a gond van.."}, --{"Vigyázz a használt kocsikkal, némeiket drágábban adják mint az újat.."},
			{"Csapd le a gatyát, ilyen meleg a világon még nem volt soha."}, --{"Neked nincs meleged?"},
			{"Íjha de szar ez a meló, bár még mindig jobb mint a szar lapátolás.."}, --{"Kezdem unni ezt a munkát.."},
			{"Küdd meg a gázpedált, vagy ha nem..."}, --{"Nem akarsz a gázra lépni?"},
			{"Muzsikát ne kapcsolj 100-as hangerő alatt.."}, --{"Ha zenét kapcsolnál, nem bánnám. *nevetve*"},
			{"Nálam jobb vizsgabiztost, vagy hogy híjjákot nem kaphattá vóna."}, --{"Jól jártál, hogy engem fogtál ki. *nevetve*"},
			{"Szólj ha kussoljak."}, --{"Ugye nem beszélek sokat?"},
			{"Rohadjak meg de a tükörbe jobban néző ki."}, --{"Olyan jól nézek ki a tükörbe. *nevetve*"},
			{"Ha az öv nincs a helyén akkor fejed az ülés alatt legyen."}, --{"Ugye az övedet bekötötted?"},
			{"Ilyen csudajó orcát te.. megint magamról beszélek. *nevetve*"}, --{"Bűn ilyen szépnek lenni, de ne érts félre magamra montam. *nevetve*"},
			{"Forróbik vagy?"}, --{"Te Ugye nem vagy meleg?"},
			{"Határnál figyeljé, akkor szívnak amikor nem látod.."}, --{"Vigyázz a határnál, van ott pár pénzes lány aki nem a legjobb! *nevetve*"},
			{"Máskor fürdjé meg.."}, --{"Neked se van kifejezetten baba arcod. *nevetve*"}
		},
		["ped-belt"] = {
			{"Most csapjam ki pár rágódat vagy bekötöd az öved?"}, --{"Kösd be az öved.."},
			{"A nadrágszíjadat se szoktad bekötni ahogy látom.."}, --{"Nem ártana azt az övet bekötni."},
			{"Bekötöd, vagy kiszállok és nyakon baszlak.."}, --{"Megkérhetlek, hogy kösd be az öved?"},
			{"Forgalom nincs, de helyette én foglak kibaszni az ablakon ha nem kötöd be az övedet.."}, --{"Igaz nincs forgalom, de kösd már be az övet."}
		},
		["damage-veh"] = {
			{"Mutasd a tárcád, hadd lássam mennyid van.."}, --{"Ez a törés drága lesz."},
			{"Csipádat kapard mán ki.."}, --{"Figyelhetnél jobban is!"},
			{"Fizetsz, vagy ledolgozod?"}, --{"Ezt Ugye tudod, hogy kifizeted?"},
			{"Na akkor most jöhet a csekk vagy ledolgozod?"}, --{"Ezt a törést már számlázom is."}
		},
		["speed-veh"] = {
			{"Feküdj már rá a fékre is néha.."}, --{"Lassíts mert megbuktatlak."},
			{"Ez nem a forma 1-es versenypálya, lassíthatnál is néha.."}, --{"Nem kellene ilyen gyorsan menni.."},
			{"Én csak betartanám a sebességet.."}, --{"Nem gondolod, hogy be kellene tartani a sebesség határt?"},
			{"Nem kell a racsing, feküdj rá a fékre.."}, --{"Nem egy versenyautó ez, lassíts.."},
			{"Ha meg akarsz bukni, akkor gyorsan csináld.. Lassíts."}, --{"Ha nem akarsz megbukni akkor jobban teszed ha lassítasz.."}
		}
	},]]
}

local oldVoice = nil
function getActorInteract(a,b)
	local c = math.random(1,#actorInteract[a][b])
	if c == oldVoice then
		return getActorInteract(a,b)
	end
	return actorInteract[a][b][c][1]
end