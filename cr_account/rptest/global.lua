questions = {
    --[ID] = {"Kérdés", "Elsőválasz", "Másodikválasz", "Harmadikválasz", "NegyedikVálasz" HelyesVálasz(1,2,3,4)},
    {"Mikor használjuk a /me parancsot?", "Mikor láthatatlan cselekvést akarunk kifejezni", "Mikor látható cselekményt akarunk kifejezni írásban", "Mikor gondolatmenetet akarunk kifejezni", "Fogalmam sincs", 2},
    {"Mikor használjuk a /do parancsot?", "Saját akaratom másra erőltetésekor", "Mikor látható cselekményt akarunk kifejezni írásban", "Mikor gondolatmenetet akarunk kifejezni", "Fogalmam sincs", 3},
    {"Egy játékosra hárman ráfogjuk a fegyvert, de ő elszalad. Mit követ el ilyenkor?", "MetaGaming", "Fogalmam sincs", "SpawnKill", "PowerGaming", 4},
    {"Mit jelent a szereptévesztés?", "Saját RP-d más játékosra erőlteted", "Olyan cselekedet ami nem illik a karakteredhez.", "Nincs jelentése", "Fogalmam sincs", 2},
    {"Mit jelent az RP kifejezés?", "Szerepjáték", "Egy cég neve", "RiotPoint",  "Fogalmam sincs", 1},
    {"Mit jelent az IG kifejezés?", "A játékon kívüli történéseket foglalja magába", "Egy játékon belüli rp szituációt jelöl", "Nincs jelentése",  "A játékon belüli történéseket foglalja magába", 4},
    {"Mit jelent a /ame kifejezés?", "Karakter vizuális leírása.", "Fogalmam sincs.", "Láthatatlan cselekvés.",  "Tagfelvétel.", 1},
    {"Mit jelent az OOC kifejezés?", "A karakteren kívüli történéseket foglalja magába", "Nincs egyértelmű jelentése", "Egy karakteren kívüli adásvételi szerződés",  "A karakteren belüli történéseket foglalja magába", 1},
    {"Látsz egy admint aki szolgálat közben megver egy játékost. Mit teszel?", "Nem szólsz senkinek", "Panaszt teszel rá a megfelelő formában", "Beszállsz a verekedésbe",  "Elütöd az admint kocsival", 2},
    {"Egy fegyvert szeretnél eladni. Hogyan teszed meg?", "Kiállok egy forgalmas helyre és kiabálok, hogy fegyver eladó", "Burkolt formában hirdetést adok fel", "Városházán megpróbálok házalni vele", "Egyik sem eközül", 4},
    {"Szeretnél egy illegális bűnszervezethez (maffiához) csatlakozni. Hogyan teszed meg?", "Odamegyek a HQ-ra és közlöm, hogy csatlakozni akarok a maffiához", "Megkeresem a tagok nevét Discordon majd a szerveren felkeresem őket", "Feladok egy hirdetést, hogy maffiába szeretnék csatlakozni",  "Várok, hogy hirdessenek valamiféle munkát, majd jelentkezek rá és fokozatosan lépek előre", 4},
    {"Szeretnél a rendőrség tagja lenni. Miként tudsz csatlakozni?", "Várok, hogy munkát hirdessenek. Ha lesz felvétel akkor jelentkezek", "Megkérek egy admint, hogy rakjon a frakcióba", "Discordon felkeresem a leadert és berakatom magam a frakcióba",  "Megkérem a barátom, hogy vetessen fel engem", 1},
    {"Mi az a RK?", "Bosszúállás, vagyis halál után egyből megölöd a gyilkosaid (szándékosan)", "Fogalmam sincs", "Bosszúból egy admin által kirúgatod a játékost, mert megölt",  "Bosszúból kirúgod a játékost a frakcióból", 1},
    {"Mi az a DM?", "Ok nélküli gyilkolás", "Indokolt gyilkolás", "Adminok meggyilkolás okkal",  "Fogalmam sincs", 1},
    {"Nem akarsz játszani a szerveren, de tovább adnál a cuccaidon. Hogy teheted meg?", "Eladom őket CS:GO skinekért", "Odaadom egy barátomnak a szerveren", "Eladom valamelyik facebook csoportban",  "Elcserélem más játékból származó tárgyakra", 2},
    {"A szerveren milyen játékmód folyik?", "Prison break", "Play", "Szerepjáték azaz RolePlay", "RoliPlay", 3},
    {"Hibát találsz. Mit csinálsz?", "Kihasználod", "Nem szólsz senkinek sem", "Készítesz egy videót és lejáratod a szervert",  "Jelented a fejlesztőknek és nem használod ki", 4},
    {"Mit csinálsz ha egy játékos látod hogy nem rpzik vagy nonrp-t hajt végre?", "A megfelelő formában jelented a játékost", "Segítesz neki", "Nem foglalkozol vele, hisz nem a te dolgod",  "Nézed, hogy mit csinál és kineveted", 1},
    {"Mire használod a /placedo parancsot?", "Fogalmam sincs.", "A környezet leírása.", "Karakter vizuális leírása.", "Látható cselekmény kifejezésére", 2},
}

hasQuestions = {}
maxQuestions = 19
rtMultipler = 0.8 -- 90% kell
neededToComplete = maxQuestions * rtMultipler