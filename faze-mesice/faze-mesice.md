# Faze Mesice

Mesic nema vlastni svetlo — vidime jen tu cast jeho povrchu, kterou osvetluje Slunce. Jak Mesic obezi Zemi, meni se uhel mezi Sluncem, Zemi a Mesicem, a s nim i to, kolik osvetlene poloviny vidime. Tomu rikame **faze Mesice**.

Tento clanek popisuje, proc faze vznikaji, jak je lide sledovali po tisicileti, a jak je dnes muzeme vypocitat pomoci par radku kodu.

## Proc ma Mesic faze

Mesic je kulata skala o prumeru 3 474 km, ktera obezi Zemi ve vzdalenosti priblizne 384 400 km. Slunce osvetluje vzdy presne jednu polovinu Mesice — ale my z povrchu Zeme vidime jen cast te osvetlene poloviny, v zavislosti na tom, kde se Mesic na sve obezne draze prave nachazi.

- Kdyz je Mesic mezi Zemi a Sluncem (konjunkce), vidime jeho neosvetlenou stranu — **nov**.
- Kdyz je Zeme mezi Mesicem a Sluncem (opozice), vidime celou osvetlenou stranu — **uplnek**.
- Mezi tim se meni tvar osvetlene casti od uzkemu srpku pres polovinu az po temer plny disk.

> Dulezite: faze Mesice **nemaji nic spolecneho se stinem Zeme**. Stin Zeme na Mesici zpusobi jen zatmeni Mesice, coz je vzacna udalost. Bezne faze jsou jen otazkou uhlu pohledu.

## Synodicky mesic

Doba, za kterou Mesic projde vsemi fazemi (od novu do dalsiho novu), se nazyva **synodicky mesic**. Prumerne trva:

**29 dni, 12 hodin, 44 minut a 3 sekundy** (priblizne 29,53 dne)

Tato hodnota je prumer — skutecna delka jednoho cyklu se meni od **29,18 do 29,93 dne** kvuli:

- **Elipticke draze Mesice** — v perigeu (356 500 km) se Mesic pohybuje rychleji, v apogeu (406 700 km) pomaleji
- **Elipticke draze Zeme** kolem Slunce — meni se vzdalenost ke Slunci, a tim i jeho gravitacni vliv
- **Gravitacnim perturbacim** od ostatnich planet

### Synodicky vs. sidericky mesic

| Typ | Delka | Vztazny bod |
|-----|-------|-------------|
| Sidericky | 27,32 dne | Hvezdy (jeden obeh kolem Zeme) |
| Synodicky | 29,53 dne | Slunce (faze novu k novu) |

Synodicky mesic je delsi, protoze Zeme se za tu dobu posune na sve draze kolem Slunce — Mesic musi urazit jeste kousek navic, nez se dostane do stejneho uhlu vuci Slunci.

## 8 fazi

Lunarni cyklus se tradicne deli na 8 fazi:

| # | Faze | Anglicky | Stari (dne) | Osvetleni | Popis |
|---|------|----------|-------------|-----------|-------|
| 1 | **Nov** | New Moon | 0 | 0 % | Mesic neni videt |
| 2 | **Dorust. srpek** | Waxing Crescent | ~3,7 | 1–49 % | Tenky srpek vpravo |
| 3 | **Prvni cvrt** | First Quarter | ~7,4 | 50 % | Prava polovina |
| 4 | **Dorust. mesic** | Waxing Gibbous | ~11,1 | 51–99 % | Vetsina osvetlena |
| 5 | **Uplnek** | Full Moon | ~14,8 | 100 % | Plny disk |
| 6 | **Couvajici mesic** | Waning Gibbous | ~18,4 | 99–51 % | Ubyvani zprava |
| 7 | **Posledni cvrt** | Last Quarter | ~22,1 | 50 % | Leva polovina |
| 8 | **Couvajici srpek** | Waning Crescent | ~25,8 | 49–1 % | Tenky srpek vlevo |

> Na severni polokouli: **dorustajici** = svetlo zprava, **couvajici** = svetlo zleva. Na jizni polokouli je to naopak.

Kazda faze trva priblizne 3,69 dne (29,53 / 8).

## Historie

### Nejstarsi kalendar

Lunarni kalendar je nejstarsi kalendar lidstva. Faze Mesice jsou viditelne holym okem a opakovani je pravidelne a predvidatelne — na rozdil od slunecniho roku, ktery vyzaduje dlouhodobe pozorovani a propocty.

Archeologicke nalezy naznacuji, ze lide sledovali faze Mesice uz pred **25 000 lety** — kosti ze Solutreanu (Francie) a Ishanga (Demokraticka republika Kongo) nesou ryhy interpretovane jako zaznamy lunarnich cyklu.

### Babylon (1800 pr. n. l.)

Babylonsti hvezdari systematicky zaznamenavali faze Mesice na hlinene tabulky. Rozpoznali, ze 235 lunarnich mesicu odpovidou priblizne 19 slunecnim rokum — cyklus, ktery o staletí pozdeji formalizoval recky astronom **Meton** (432 pr. n. l.).

### Metonuv cyklus

Jedna z nejelegantnejsich astronomickych souvislosti:

**19 slunecnich let = 235 lunarnich mesicu**

Tedy: `19 × 365,25 = 6 939,75 dne` vs. `235 × 29,53 = 6 939,55 dne`

Rozdil je pouhych 0,2 dne za 19 let. Po 19 letech tak faze Mesice pripadnou na priblizne stejna data v kalendari. Toto poznatky vyuzivaly anticke i stredoveke kalendare.

### Islamsky kalendar

Islamsky (hidzsra) kalendar je **ciste lunarni** — mesice maji strídave 29 a 30 dni, rok ma 354–355 dni. Proto se islamske svatky posunuji vuci gregorianskeho kalendari o ~11 dni rocne. Zacatek kazdeho mesice je dan pozorovatelnym novovem.

### Computus — vypocet Velikonoc

Datum Velikonoc je definovano jako **prvni nedele po prvnim uplnku po jarni rovnodennosti** (21. brezna). Tento vypocet se nazyva *computus* a je historicky prvnim vaznym algoritmickym problemem — stredovecí ucenci ho resili staletí pred vznikem pocitacu.

Computus vyzaduje kombinaci lunarnich a solarnich cyklu, a prave pro nej vznikly Metonovy tabulky *zlateho cisla* (pozice v 19letem cyklu). Gregorianska reforma v roce 1582 musela opravit i lunární tabulky, ktere se od skutecnosti odchylily o nekolik dni.

## Jak to pocitat

### Nejjednodussi pristup: modulo aritmetika

Pokud zname datum jednoho novu a prumernou delku synodickaho mesice, muzeme fazi pro libovolne datum spocitat jednoduchy delenim:

```javascript
var SYNODIC = 29.53059;  // prumerna delka cyklu ve dnech
var EPOCH = Date.UTC(2024, 0, 11, 11, 57) / 86400000;  // znamy nov

var dnesVeDnech = Date.now() / 86400000;
var stari = ((dnesVeDnech - EPOCH) % SYNODIC + SYNODIC) % SYNODIC;
var faze = stari / SYNODIC;  // 0 = nov, 0.5 = uplnek, 1 = nov
```

Hodnota `faze` je cislo od 0 do 1, ktere mapujeme na 8 pojmenovanych fazi (napr. `Math.round(faze * 8) % 8` da index 0–7).

### Procento osvetleni

Osvetlena cast Mesice z pohledu pozorovatele se da odvodit z kosinu:

```
osvetleni = (1 − cos(2π × faze)) / 2
```

Pri novu (`faze = 0`): `(1 − cos(0)) / 2 = 0` — 0 %
Pri uplnku (`faze = 0.5`): `(1 − cos(π)) / 2 = 1` — 100 %

### Presnost a omezeni

Tento jednoduchy pristup ma presnost priblizne **±1–2 dny**. Duvody nepresnosti:

- Synodicky mesic neni konstantni (29,18–29,93 dne), ale my pouzivame prumer
- Nepocitame s gravitacnimi perturbacemi (vliv Slunce, Jupiteru)
- Neuvazujeme elipticitu obeznych drah

Pro presnejsi vypocty (na minuty) slouzi algoritmy **Jeana Meuse** z knihy *Astronomical Algorithms*, ktere zahrnuji desitky korekcinich clenu polynomialnich aproximaci.

Pro kalendar na zdi ci dekoraci na weather dashboardu je vsak modulo pristup naprosto postacujici.

### Dny do uplnku / novu

```javascript
var uplnekZa = ((SYNODIC / 2 - stari) % SYNODIC + SYNODIC) % SYNODIC;
var novZa = (SYNODIC - stari) % SYNODIC;
```

## SVG vizualizace

Jak vykreslit Mesic ve webovem prohlizeci? Pouzijeme SVG s dvema oblouky.

### Princip

Mesic je kruh. Hranice svetla a stinu (astronomicky **terminator**) je na 2D projekci elipsa. Jeji horizontalni polomer se meni podle faze:

- Pri novu a uplnku: `rx = R` (terminator splyne s okrajem)
- Pri ctvrtich: `rx = 0` (terminator je svisle usecka)

### SVG cesta pro stin

Stinova vrstva se sklada ze dvou oblouku:

1. **Okraj tmavy strany** — vzdy pulkruh (polomer = R)
2. **Terminator** — elipticky oblouk s promennym `rx`

```javascript
function stinMesice(faze, cx, cy, R) {
    var rx = Math.abs(Math.cos(2 * Math.PI * faze)) * R;
    var top = cx + ',' + (cy - R);
    var bot = cx + ',' + (cy + R);

    if (faze < 0.5) {
        // Dorustajici: stin vlevo
        var smer = (faze < 0.25) ? '0' : '1';
        return 'M' + top +
               'A' + R + ',' + R + ' 0 0,0 ' + bot +   // levy pulkruh
               'A' + rx + ',' + R + ' 0 0,' + smer + ' ' + top + 'Z';
    } else {
        // Couvajici: stin vpravo
        var smer = (faze < 0.75) ? '1' : '0';
        return 'M' + top +
               'A' + R + ',' + R + ' 0 0,1 ' + bot +   // pravy pulkruh
               'A' + rx + ',' + R + ' 0 0,' + smer + ' ' + top + 'Z';
    }
}
```

Vysledny SVG element je svetly kruh (`fill="#e8e0c8"`) s tmavy overlay pathom. Volitelne pridame gaussovsky blur filtr pro jemny efekt zare.

## Etymologie a kultura

Mesic zanechal hlubokou stopu v jazyce i kulture.

### Slova odvozena od Mesice

| Jazyk | Slovo | Vyznam | Souvislost |
|-------|-------|--------|------------|
| Cestina | **mesic** | mesic (cas i teleso) | Spolecne pro vsechny slovanske jazyky |
| Anglictina | **month** | mesic | Ze staroanglic. *monað* (mesic) |
| Anglictina | **Monday** | pondeli | *Moon's day* — den Mesice |
| Latina | **lunatic** | sileny | *Lunaticus* — "zasazeny Mesicem" |
| Nemcina | **Monat** | mesic | Ze starovysokonemec. *manod* |

### Povery a tradice

- **Sadeni podle Mesice** — tradice radí sadit nadzemni plodiny za dorustajiciho Mesice a korenovou zeleninu za couvajiciho. Vedecky nepotvrzeno, ale praktika pretrvava.
- **Vlkodlaci** — mytologicka premena za uplnku. Motiv se objevuje uz v anticke literature.
- **Lunaticismus** — stredoveká vira, ze uplnek vyvolava silenstvi. Anglicky termin *lunatic* pochazi prave odtud.
- **Porody za uplnku** — rozsirena domnenka, ze za uplnku se rodi vic deti. Medicinske studie ji opakovane vyvratily.

### Cesky kontext

V cestine je slovo *mesic* pouzivano jak pro nebeske teleso, tak pro casovy usek — stejne jako ve vetsine slovanskych jazyku. Stare ceske pojmenovani mesicu v roce (leden, unor, brezen...) jsou odvozena od prirodnich jevu, ne od Mesice, ale lunarni kalendar hrál roli v lidovych tradicich a zemedelstvi.

## Zajimavosti

### Blue Moon — modry Mesic

Puvodne oznaceni pro **treti uplnek v obdobi se ctyrmi uplnky** (bezne jsou tri za sezonu). Dnes se casto pouziva pro druhy uplnek v jednom kalendarnim mesici. Nastava priblizne jednou za 2,7 roku — odtud fráze *once in a blue moon* (jednou za uherfurt).

### Supermoon — superuplnek

Uplnek v blízkosti **perigea** (nejblizsi bod draze k Zemi). Mesic vypadá o ~14 % vetsi a ~30 % jasnejsi nez pri apogeu. Opak se nekdy nazyva *micromoon*.

### Blood Moon — krvavý Mesic

Uplnek behem uplneho zatmeni Mesice. Mesic ziskava nacervenalou barvu, protoze Zemská atmosfera lame cervene svetlo do stinu — stejny jev, ktery zpusobuje cervene zapady slunce.

### Priliv a odliv

Gravitace Mesice je hlavni pricinou prilivovych sil. Príliv nastava na strane Zeme privrácene k Mesici i na strane odvracene (pusobenim setrvacnosti). Nejsilnejsi prilivy (*skocne*) nastávají pri novu a uplnku, kdy Slunce a Mesic pusobi ve stejnem smeru.

### Mesic se vzdaluje

Laserova mereni (od mise Apollo) ukazuji, ze se Mesic vzdaluje od Zeme rychlosti **3,82 cm za rok**. Pricinou je prilivove treni — Zeme zpomaluje svoji rotaci a predava hybnost Mesici, ktery se posouva na vyssi (vzdalenejsi) obeznou drahu.

Dusledek: za miliardy let bude Mesic tak daleko, ze uplna zatmeni Slunce uz nebudou mozná.

---

*Clanek pouziva stejny algoritmus pro vypocet fazi jako weather appka na k-serveru (v1.5.4). Zivý SVG nahore ukazuje aktualni stav Mesice v okamziku nacteni stranky.*
