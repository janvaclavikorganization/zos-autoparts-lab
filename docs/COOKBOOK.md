# Mainframe kuchařka — studijní poznámky

> Moje poznámky k projektu `zos-autoparts-lab`. Píšu si je, jak to stavíme, abych
> tomu rozuměl do hloubky a uměl o tom mluvit — ne aby to „napsal jen agent".
> Před pohovorem si to proletím.

---

## Velký obraz (mentální model sálu)

- **z/OS** = operační systém mainframu (IBM Z). Jako Windows/Linux, ale pro sál.
  **MVS** je jeho předek — stejná linie, starší jméno.
- Programy se píšou hlavně v **COBOLu**, spouští se jako **dávky (batch)** přes
  **JCL** (job control language = „spouštěcí skript").
- Data žijou v **datasetech** (soubory) a ve **VSAM** (strukturované keyed
  soubory). Žádný implicitní SQL svět — perzistence je soubor s pevným tvarem.
- **Všechno je fixed-length**: záznam má pevnou délku, pole jdou za sebou na
  pevných **offsetech**. Myslí se v **bajtech a pozicích**, ne v typovaných
  sloupcích.
- Moderně se to edituje z **VS Code** (ne zelená 3270 obrazovka):
  **IBM Z Open Editor** (jazyk) + **Zowe Explorer** (datasety, submit jobů).

---

## Slovníček (co je co)

| Pojem | Jedna věta |
|---|---|
| **z/OS** | OS mainframu; moderní nástupce MVS |
| **MVS** | Multiple Virtual Storage — původní jméno té samé OS linie |
| **COBOL** | ukecaný byznys jazyk, co drží enterprise core logiku |
| **JCL** | Job Control Language — „skript", co řekne co zkompilovat/spustit a jaké soubory napojit |
| **batch (dávka)** | „proteč celý soubor a vyplivni výsledek", ne request/response |
| **dataset** | soubor na z/OS (s pevným formátem záznamu) |
| **VSAM** | rodina strukturovaných souborů; keyed access |
| **KSDS** | Key-Sequenced Data Set — VSAM soubor klíčovaný, čte se přímo po klíči |
| **IDCAMS** | utilita na správu VSAM (DEFINE, REPRO…) |
| **copybook** | sdílená definice záznamu (`struct`/DTO), `COPY`-uje se do programů |
| **PIC** | „picture" — typ + délka pole (X = text, 9 = číslo) |
| **COMP-3** | packed decimal — přesné peníze, 2 číslice/bajt, žádný float |
| **DISPLAY** | zoned decimal — 1 číslice/bajt, čitelné, napsatelné rukou |
| **DD statement** | v JCL napojení logického souboru programu na fyzický dataset (jako DI connection stringu) |
| **ABEND** | abnormal end — pád jobu (jako unhandled exception) |
| **S0C7** | data exception — nenumerická data v numerickém poli (klasický abend) |
| **return code (RC)** | výsledek kroku; `0000` = OK, vyšší = problém |
| **TSO / ISPF** | interaktivní přístup + editor/panely na z/OS (základní navigace) |
| **CICS** | transakční monitor (online transakce nad sálem) |
| **DB2** | relační databáze na z/OS (SQL, tabulky) |
| **IMS** | hierarchická databáze (strom segmentů) — nerelační |
| **Zowe** | moderní open-source most na z/OS (CLI + VS Code Explorer) |
| **IBM Z Xplore** | free cloud z/OS na učení |
| **Hercules** | emulátor sálu na obyčejném PC (+ TK5 = MVS image) |

---

## Lekce 1 — Copybook (datový model)

**Co to je:** sdílená definice záznamu, `COPY`-uje se do `DATA DIVISION` každého
programu, co na ta data sahá. Jeden zdroj pravdy o tvaru záznamu.

**COBOL program = 4 divisions (vždy v tomto pořadí):**
IDENTIFICATION (jméno) · ENVIRONMENT (napojení souborů) · DATA (struktury) ·
PROCEDURE (logika).

**Sloupce — fixed-format, pozice = syntaxe:**
- sloupec 7 = indikátor; `*` = komentář
- sloupce 8–11 = Area A (`01`, `FD`, názvy divisions/paragrafů)
- sloupce 12–72 = Area B (`05`+, statementy)
- dědictví děrných štítků (80 sloupců); IBM Z Open Editor to hlídá
- praktika: VS Code `editor.rulers` [6, 7, 11, 72] nakreslí hranice sloupců
  (v repu už v `.vscode/settings.json`); status bar ukazuje číslo sloupce

**Level numbers = vnoření:** `01` = kořen záznamu, `05` = pole. Skoky (01, 05,
10) kvůli pozdějšímu vkládání bez přečíslování.

**PIC (picture = typ + délka):**
- `PIC X(10)` = 10 znaků textu (`char[10]`)
- `PIC 9(7)V99` = číslo: 7 celých + `V` implicitní tečka (0 bajtů) + 2 desetinná

**DISPLAY vs COMP-3 (peníze):**
- **DISPLAY** (zoned) = 1 číslice/bajt, čitelné, napsatelné rukou
- **COMP-3** (packed) = 2 číslice/bajt + znaménko, přesné, kompaktní → reálné peníze

**Fixed-length myšlení:** záznam = přesně N bajtů, pole na pevných offsetech.
Proto VSAM řekne „klíč = prvních 10 bajtů". Myslí se v bajtech, ne ve varcharu.

**Co říct u pohovoru:**
> „Copybook je sdílený record layout — `struct`, co `COPY`-uju do programů, aby
> tvar dat žil na jednom místě. Záznamy jsou fixed-length, pole na pevných
> offsetech; peníze držím v COMP-3 (packed decimal) kvůli přesnosti, ne ve floatu."

---

## Lekce 2 — JCL + definice VSAM (IDCAMS)

**JCL** = „spouštěcí skript": řekne co zkompilovat/spustit a jaké soubory napojit.
Každý řádek začíná `//`. Je to tvůj deployment/run manifest.

**Anatomie jobu:**
- `//NAME JOB ...` — **JOB card** (hlavička). `CLASS` = fronta, `MSGCLASS` = kam
  jdou hlášky, `NOTIFY=&SYSUID` = cinkni mi. `&SYSUID` = user id, dosadí se
  (je to v `//` řádku).
- `//*` = komentář.
- `//STEP EXEC PGM=xxx` — **krok**, co spustí program. Job = N kroků za sebou.
- `//DDNAME DD ...` — **DD statement** = napoj logický soubor programu na fyzický
  dataset (tvoje DI / connection string). `DD SYSOUT=*` = do výstupu jobu;
  `DD *` = inline data až po `/*`.

**IDCAMS** = utilita na VSAM (zakládá/maže/kopíruje). `DEFINE CLUSTER` = „CREATE
TABLE" pro VSAM soubor:
- `NAME(HLQ.AUTOPART.PARTS)` — jméno datasetu (HLQ = tvoje user id).
- `INDEXED` — udělá **KSDS** (keyed). (`NONINDEXED`=ESDS, `NUMBERED`=RRDS.)
- `KEYS(10 0)` — klíč: 10 bajtů na offsetu 0 → „klíč = prvních 10 bajtů".
- `RECORDSIZE(42 42)` — avg/max délka záznamu (fixed), sedí na copybook.
- `TRACKS(1 1)` — alokace místa (primární/sekundární).
- `-` na konci řádku = pokračování příkazu; `/*` = konec SYSIN.

**Pozor (gotcha):** JCL symbolics (`&SYSUID`) se dosazují jen v `//` řádcích,
**NE v instream SYSIN datech** → v IDCAMS příkazu musíš napsat HLQ natvrdo.

**Co říct u pohovoru:**
> „JCL je job skript — JOB card, kroky (`EXEC PGM=`), a DD statementy, co napojí
> logické soubory na datasety. VSAM KSDS zakládám přes IDCAMS `DEFINE CLUSTER` —
> `INDEXED`, `KEYS(délka offset)`, `RECORDSIZE` — je to obdoba `CREATE TABLE` pro
> keyed soubor."

## Lekce 3 — Data + load (REPRO)

**Datový soubor** = fixed-width řádky, políčka natěsno, žádné oddělovače.
Pozice = všechno. (`parts.dat`, každý řádek 42 znaků.)

**Load** = druhý JCL skript, stejný tvar jako DEFINE, ale:
- dva DD řádky: `INFILE` (plochý soubor) a `OUTFILE` (KSDS)
- jediný IDCAMS příkaz: **`REPRO INFILE(..) OUTFILE(..)`** = zkopíruj řádky do tabulky

**Pořadí:** DEFINE (založ prázdnou tabulku) → upload dat na z/OS → REPRO (nalij).

**Co říct u pohovoru:**
> „Plochý soubor nahraju na z/OS a přes IDCAMS `REPRO` ho načtu do KSDS —
> INFILE → OUTFILE. Záznamy jsou fixed-width, takže klíč sedí na prvních N bajtů."

## Lekce 4 — První COBOL program (čtečka)

**Jednoduše:** `PARTRDR.cbl` otevře naplněnou tabulku, `while` smyčkou ji pročte
a vypíše každý díl. **Otevři → protoč → zavři.** Zbytek programu je jen ceremonie,
co vypadá v každém COBOLu stejně.

**Každý program = 4 divisions:**
1. **IDENTIFICATION** — jméno programu.
2. **ENVIRONMENT** — napojení souborů (`SELECT ... ASSIGN TO ddname`, typ souboru).
3. **DATA** — struktury: záznam (`COPY` copybooku = reuse) + `WORKING-STORAGE`
   (lokální proměnné, flagy, počítadla).
4. **PROCEDURE** — logika (těla metod).

**Vzor čtení souboru (procedure):**
```
OPEN INPUT soubor
PERFORM UNTIL konec        (= while)
   READ soubor
     AT END     → nastav flag konce
     NOT AT END → zpracuj záznam (DISPLAY = print)
CLOSE soubor
GOBACK                     (= return)
```

Mapování na C#: `SELECT/ASSIGN` = inject souboru, `FD` = tvar záznamu,
`WORKING-STORAGE` = lokální proměnné, `PERFORM UNTIL` = `while`, `DISPLAY` =
`Console.WriteLine`, `GOBACK` = `return`.

**Spuštění (JCL):** dvoukrokový job — ① `EXEC IGYWCL` zkompiluje + slinkuje
program, ② `EXEC PGM=xxx` ho spustí; `STEPLIB` = kde je load modul, DD jména
napojí soubory (`PARTSDD` ↔ `ASSIGN TO PARTSDD`).

**Co říct u pohovoru:**
> „COBOL program má čtyři divisions — identification, environment (napojení
> souborů), data (záznamy + working-storage), procedure (logika). Soubor čtu
> `OPEN` / `PERFORM UNTIL` + `READ ... AT END` / `CLOSE`. Spouští se JCL jobem,
> co nejdřív zkompiluje a pak program spustí se STEPLIB a DD napojením."

## Téma: Datový model na sále (a čím se liší od relační DB)

Na z/OS žijou vedle sebe **tři světy ukládání dat** — a to, který drží co, JE
kus té „enterprise architektury".

**1. VSAM — keyed soubory (co jsme používali).**
Není to databáze, jsou to **strukturované soubory**. Typy: **KSDS** (klíčovaný,
čteš po klíči = jedna indexovaná tabulka), **ESDS** (append log), **RRDS** (po
čísle záznamu). Žádný SQL, žádné joiny, žádné vztahy. Navigace po klíči nebo
sekvenčně. Rychlé, prosté, všudypřítomné.

**2. IMS — hierarchická databáze.**
Data jako **strom segmentů**: rodič → děti → vnuci. Celá entita (pojistka,
objednávka) i se svými potomky = **jedna hierarchie**. Navigace **dolů stromem**
voláními `GU` / `GN` / `GNP`. Místo joinů přes kolekce **lezeš dovnitř jedné
entity**.

**3. DB2 — relační na sále.**
Tabulky, řádky, SQL, joiny, klíče — úplně jako Postgres. Moderní relační volba,
běží **vedle** těch starších.

**Jádro rozdílu — navigational vs relational:**

| | Relační (DB2, Postgres) | Navigational (VSAM, IMS) |
|---|---|---|
| Data | tabulky (ploché kolekce) | keyed soubor / strom |
| Vztahy | foreign keys | pozice v souboru / větev stromu |
| Entitu složíš | **JOINem** přes tabulky | **sestupem** do klíče/stromu |
| Kdo řídí přístup | engine (optimizer) | **ty** (kóduješ access path) |
| Styl | deklarativní („CO chci") | imperativní („JAK se tam dostat") |

- **Relační** = *„popiš CO chceš, engine vymyslí jak"* (SQL, optimizer).
  Flexibilní — jakýkoli dotaz — ale platíš cenu joinů a optimizeru.
- **Navigational** = *„nakóduj JAK se k datům dostaneš"* (čti klíč, jdi na dítě).
  **Extrémně rychlé a předvídatelné** pro známou cestu — žádný join, žádné
  překvapení optimizeru. Proto banky/pojišťovny zvládaly miliony transakcí denně
  dekády předtím, než to relační dohnalo. Cena: **rigidní** — zeptat se jinak je
  těžké, struktura je postavená kolem té známé cesty.

**Mentální přepnutí:** relační = *dotaz tě dovede k datům*; navigational =
*ty chodíš po datech za ruku*. SQL vs pointer-chasing.

**Architektonicky:** reálný estate má **všechny tři** — VSAM pro něco, IMS pro
nejstarší hierarchické jádro, DB2 pro novější relační — a **data mezi nimi
tečou.** Vědět, který store drží co a jak se data přelévají, **JE** ta „analýza
datových toků / enterprise architektura" z inzerátu.

**Co říct u pohovoru:**
> „Sál má tři datové světy: VSAM (keyed soubory), IMS (hierarchická DB, strom
> segmentů) a DB2 (relační). Klíčový rozdíl je navigational vs relational —
> u VSAM/IMS kóduju access path sám (čti klíč, jdi na dítě), u DB2 popíšu SQL
> a optimizer to vyřeší. Navigational je rychlé a předvídatelné pro známé cesty,
> relační flexibilní. Reálný estate kombinuje všechny tři a data mezi nimi
> tečou — a pochopit ty toky je půlka té práce."

## Téma: Architektura = pipeline + datové toky

Reálná aplikace na sále **není jeden program** — je to **pipeline kroků**, mezi
kterými **tečou data přes datasety**. Tohle je ta „enterprise architektura".

- **Job = N kroků** (`EXEC`); **output datasetu jednoho kroku = input dalšího**.
- **Temp dataset `&&NAME`** = žije jen po dobu jobu. `DISP=(NEW,PASS)` = vytvoř
  a předej dalšímu kroku; `DISP=(OLD,DELETE)` = vezmi a po použití smaž.
- **SORT** (DFSORT) = utilita, co seřadí soubor:
  `SORT FIELDS=(pozice,délka,typ,směr)` — např. `(9,2,CH,A)` = od pozice 9,
  2 znaky, znakově (CH), vzestupně (A).
- **Integrace** = **interface soubor** předaný jinému systému (SAP…) = „datový
  tok mezi systémy".
- **Dopad změn:** změníš krok 2 → propíše se do priced → report → extract →
  downstream. Pochopit ten **ripple** = „dopad změn na celý systém".

**Co říct u pohovoru:**
> „Mainframe aplikace je pipeline job kroků, kde output datasetu jednoho kroku
> je input dalšího — data tečou přes (často dočasné) datasety. Integrace na jiné
> systémy je přes interface soubory. Takže ‚dopad změny' čtu jako ripple skrz tu
> pipeline až k downstream systému — to je ta analýza datových toků."

<!-- další lekce se přidávají sem, jak stavíme -->
