"""Repo-native SVG art. No photographs are copied or embedded."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "adventure" / "art"
ROOT.mkdir(parents=True, exist_ok=True)

def dog(kind, state):
    fofins = kind == "fofins"
    coat, ear, face = ("#fffbee", "#9b7154", "#d4b28d") if fofins else ("#cf945b", "#765038", "#f3ce98")
    collar = "#ee5686" if fofins else "#24a6bc"
    step = 5 if state == "walk" else (-4 if state == "follow" else 0)
    smile = '<path d="M81 49 Q86 64 92 48" fill="#f18d9d"/>' if state == "rescue" else '<path d="M81 48 Q87 53 92 48" fill="none"/>'
    tuft = '<path d="M58 22 Q51 5 69 10 Q73 0 81 10 Q96 3 101 20 L89 26 L82 18 L76 29 L70 19Z" fill="#fffbee"/>' if fofins else '<path d="M58 20 Q73 4 94 19 L83 26Z" fill="#f3ce98"/>'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="110" height="80" viewBox="0 0 110 80">
<g stroke="#44352f" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
<path d="M19 50 Q1 51 8 36 Q17 30 23 38 Q14 33 15 44 L25 46" fill="{coat}"/>
<path d="M21 55 L{23-step} 73 Q{29-step} 79 {34-step} 72 L37 58" fill="{coat}"/>
<path d="M60 57 L{59+step} 73 Q{65+step} 79 {70+step} 73 L77 56" fill="{coat}"/>
<path d="M14 48 Q20 38 39 40 Q47 36 56 40 Q78 40 81 52 Q87 63 74 66 L67 69 L58 66 L45 69 L37 66 L27 69 Q12 67 14 48Z" fill="{coat}"/>
<path d="M22 60 L{19+step} 73 Q{25+step} 80 {31+step} 73 L36 63" fill="{coat}"/>
<path d="M61 61 L{62-step} 73 Q{68-step} 80 {74-step} 73 L78 62" fill="{coat}"/>
<path d="M42 43 Q54 47 51 59 Q42 64 35 58" fill="{face}" stroke="none" opacity=".55"/>
<path d="M60 23 Q43 24 47 44 L46 57 Q51 69 61 56 L66 32" fill="{ear}"/>
<path d="M95 23 Q109 26 105 43 L106 55 Q99 66 94 51 L91 31" fill="{ear}"/>
<path d="M58 25 Q66 12 88 15 Q103 21 99 43 Q101 54 87 61 Q71 63 59 51 Q53 41 58 25Z" fill="{face}"/>
{tuft}
<path d="M78 19 Q73 31 76 42 L87 43 Q90 31 85 21" fill="#fffbee" stroke="none"/>
<ellipse cx="68" cy="33" rx="7.4" ry="8.4" fill="#221d1c"/>
<ellipse cx="91" cy="33" rx="7.4" ry="8.4" fill="#221d1c"/>
<circle cx="70" cy="30" r="2.8" fill="white" stroke="none"/><circle cx="93" cy="30" r="2.8" fill="white" stroke="none"/>
<path d="M61 42 Q60 37 68 40 Q76 36 81 42 Q89 38 96 42 Q103 52 91 55 L84 52 L77 55 Q62 56 61 42Z" fill="#fff4df"/>
<path d="M78 40 Q84 37 90 40 Q93 44 86 48 Q78 47 78 40Z" fill="#251f1e"/>
<path d="M85 47 L85 50" fill="none"/>{smile}
<path d="M62 59 Q77 67 95 58" fill="none" stroke="{collar}" stroke-width="5"/>
<circle cx="83" cy="63" r="3.4" fill="#ffd66b"/>
<path d="M53 33 L55 43 M50 43 L53 52 M99 42 L101 51 M23 48 L21 55 M41 46 L40 52" stroke-width="1.2" fill="none"/>
</g></svg>'''

DOG_PALETTES = {
    "tokio": ("#17171e", "#121218", "#22222a", "#24a6bc"),
    "creme": ("#fff2cc", "#d4b68d", "#fff5df", "#dc5692"),
    "cinza": ("#a8afc3", "#545b77", "#d8ddeb", "#ef8d2d"),
    "caramelo": ("#dc944e", "#8b582d", "#edb575", "#586be0"),
    "malhado": ("#fff9ed", "#3e3433", "#bb8a6a", "#28a878"),
    "dourado": ("#f1c055", "#c28738", "#ffdc84", "#df6480"),
    "chocolate": ("#6b4235", "#3c2824", "#986851", "#3bafce"),
    "branco": ("#fffdf9", "#f2e4d1", "#ffffff", "#9a61d6"),
    "pintinhas": ("#eee5d7", "#534b44", "#e8d6c2", "#ed7844"),
}
for kind in ["fofins", "amigo", *DOG_PALETTES]:
    for state in ["idle", "walk", "rescue", "follow"]:
        art = dog(kind, state)
        if kind in DOG_PALETTES:
            coat, ears, face, collar = DOG_PALETTES[kind]
            for old, new in [("#cf945b", coat), ("#765038", ears), ("#f3ce98", face), ("#24a6bc", collar)]:
                art = art.replace(old, new)
            if kind == "tokio":
                # Black coat everywhere: the only light areas are eye reflections and collar.
                art = art.replace("#fffbee", "#22222a").replace("#fff4df", "#22222a").replace("#44352f", "#55515f")
            if kind in ["malhado", "pintinhas"]:
                spots = '<ellipse cx="31" cy="48" rx="10" ry="7" fill="#453a35" stroke="none"/>' if kind == "malhado" else ''.join(f'<circle cx="{x}" cy="{y}" r="3" fill="#554a43" stroke="none"/>' for x,y in [(24,48),(37,58),(52,48),(64,59)])
                art = art.replace('<path d="M42 43', spots + '<path d="M42 43')
        (ROOT / f"{kind}_{state}.svg").write_text(art, encoding="utf-8")

palettes = [("#eed29b", "#f179a4", "#f8e4bc"), ("#bbd5dd", "#8863b5", "#d9e9ed"), ("#e8c3e5", "#526ec8", "#f2ddf0"), ("#e9b184", "#df695b", "#ffddb4"), ("#a5c6bf", "#4095a0", "#d2e8dc")]
for index, (stone, roof, light) in enumerate(palettes, 1):
    elements = [f'<svg xmlns="http://www.w3.org/2000/svg" width="2500" height="640" viewBox="0 0 2500 640"><g stroke="#675561" stroke-width="5" stroke-linejoin="round">']
    for x, y in [(135, 190), (850, 110), (1660, 145), (2260, 210)]:
        elements.append(f'<path d="M{x} {y} q-10 -40 35 -35 q20 -43 50 -12 q43 -10 43 34 q30 9 12 30Z" fill="#fffdf2" stroke="#c0d7df" stroke-width="3"/>')
    elements.append(f'<path d="M0 550 Q230 430 400 560 Q630 450 900 565 Q1260 440 1480 575 Q1780 475 1970 566 Q2200 440 2500 557 L2500 640 L0 640Z" fill="#b5d78d" stroke="#87b16e" stroke-width="3"/>')
    elements.append(f'<path d="M440 620 L440 350 L2050 350 L2050 620Z" fill="{light}"/>')
    for x in range(440, 2070, 85):
        elements.append(f'<path d="M{x} 350 L{x} 322 L{x+38} 322 L{x+38} 350" fill="{light}"/>')
    for x, top, width in [(350, 225, 175), (960, 158, 205), (1510, 225, 180), (2100, 190, 185)]:
        elements.append(f'<path d="M{x} 620 L{x} {top} L{x+width} {top} L{x+width} 620Z" fill="{stone}"/>')
        elements.append(f'<path d="M{x-22} {top} L{x+width//2} {top-105} L{x+width+22} {top}Z" fill="{roof}"/>')
        elements.append(f'<path d="M{x+width//2} {top-105} L{x+width//2} {top-158} L{x+width//2+73} {top-143} L{x+width//2} {top-126}" fill="#ffd473"/>')
        for wy in [top + 52, top + 194]:
            elements.append(f'<path d="M{x+width//2-21} {wy+54} L{x+width//2-21} {wy+17} Q{x+width//2} {wy-10} {x+width//2+21} {wy+17} L{x+width//2+21} {wy+54}Z" fill="#6f8fa8"/>')
            elements.append(f'<path d="M{x+width//2} {wy+5} L{x+width//2} {wy+54} M{x+width//2-20} {wy+29} L{x+width//2+20} {wy+29}" fill="none" stroke="#fff6d7" stroke-width="3"/>')
    for y in [407, 466, 526, 584]:
        for x in range(560 + (27 if y == 466 else 0), 2050, 120):
            elements.append(f'<path d="M{x} {y} h45 m-18 0 v20" fill="none" stroke="#b7a4af" stroke-width="2"/>')
    elements.append(f'<path d="M1280 620 V492 Q1350 410 1420 492 V620Z" fill="#bc8664"/><path d="M1350 450 V620 M1297 530 H1403" fill="none"/>')
    elements.append('<circle cx="1333" cy="571" r="5" fill="#ffdc73"/>')
    if index == 3:
        for x in range(540, 2040, 120):
            elements.append(f'<path d="M{x} 303 L{x+37} 308 L{x+19} 343Z" fill="{roof}"/>')
        elements.append('<path d="M540 303 Q1310 380 2040 303" fill="none" stroke="#735075" stroke-width="3"/>')
    if index == 4:
        for x in [630, 1240, 1790]:
            elements.append(f'<circle cx="{x}" cy="389" r="17" fill="#ffd473"/><path d="M{x-8} 394 Q{x} 375 {x+8} 394Z" fill="#9c6547" stroke="none"/>')
    if index == 5:
        for x in range(480, 2080, 190):
            elements.append(f'<path d="M{x} 350 Q{x+45} 375 {x+20} 430" fill="none" stroke="#638c69" stroke-width="4"/><ellipse cx="{x+17}" cy="388" rx="14" ry="7" fill="#75ad72" stroke="#507b55" stroke-width="2"/>')
    elements.append('</g></svg>')
    (ROOT / f"castle_{index}.svg").write_text("\n".join(elements), encoding="utf-8")

(ROOT / "gate.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="160" height="180"><g stroke="#4c3b48" stroke-width="4" stroke-linejoin="round"><path d="M15 178 V72 Q80 -8 145 72 V178Z" fill="#ffd174"/><path d="M33 178 V78 Q80 16 127 78 V178Z" fill="#795b9b"/><path d="M38 175 V81 Q80 31 122 81 V175Z" fill="#b3ecdf" stroke="none"/><path d="M80 37 V174" fill="none"/><circle cx="68" cy="120" r="5" fill="#ffd174"/><path d="M13 178 H148"/></g></svg>''', encoding="utf-8")
(ROOT / "paw.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="54" height="54"><circle cx="27" cy="27" r="25" fill="#ffda69" stroke="#68542f" stroke-width="3"/><g fill="#a36947"><ellipse cx="16" cy="19" rx="5" ry="7" transform="rotate(-22 16 19)"/><ellipse cx="27" cy="14" rx="5" ry="7"/><ellipse cx="38" cy="19" rx="5" ry="7" transform="rotate(22 38 19)"/><path d="M14 35 Q15 27 27 24 Q39 27 40 35 Q39 42 32 40 Q27 37 22 40 Q14 42 14 35Z"/></g></svg>''', encoding="utf-8")

# Long limbs, friendly face and a scoop/bag for the manually controlled collector.
for frame in ["idle", "walk", "collect", "jump"]:
    stride = 10 if frame == "walk" else 0
    arm = '<path d="M83 72 Q101 87 103 126 L124 138"/>' if frame == "collect" else '<path d="M85 73 Q109 93 105 129"/>'
    left_arm = '<path d="M36 74 Q14 94 18 123"/>' if frame != "jump" else '<path d="M36 74 Q7 72 11 38"/>'
    art = f'''<svg xmlns="http://www.w3.org/2000/svg" width="140" height="170" viewBox="0 0 140 170">
<g stroke="#4b3930" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">
<path d="M44 105 Q{32-stride} 134 {35-stride} 160 L{23-stride} 164 M76 106 Q{87+stride} 132 {83+stride} 160 L{96+stride} 164" fill="none" stroke="#ad8760" stroke-width="15"/>
<ellipse cx="61" cy="88" rx="29" ry="37" fill="#ad8760"/><ellipse cx="60" cy="92" rx="19" ry="25" fill="#ddc09a" stroke="none"/>
<g fill="none" stroke="#ad8760" stroke-width="13">{left_arm}{arm}</g>
<ellipse cx="60" cy="44" rx="34" ry="31" fill="#c4a37b"/>
<path d="M30 35 Q42 24 60 29 Q76 24 91 37 L87 56 Q60 79 34 55Z" fill="#f7dfbb"/>
<path d="M37 38 Q45 33 53 43 L49 56 L34 47Z M67 42 Q78 32 86 39 L89 48 L71 57Z" fill="#775b48" stroke="none"/>
<circle cx="44" cy="44" r="4" fill="#201e21"/><circle cx="78" cy="44" r="4" fill="#201e21"/>
<circle cx="45" cy="42" r="1.4" fill="white" stroke="none"/><circle cx="79" cy="42" r="1.4" fill="white" stroke="none"/>
<ellipse cx="61" cy="49" rx="6" ry="4" fill="#392c29"/><path d="M49 58 Q61 70 75 57" fill="none"/>
<path d="M21 119 l-6 9 m8-5 l-1 8 m2-10 l5 7" fill="none" stroke="#f9e2b3" stroke-width="2"/>
<path d="M97 121 L116 132 L108 149 L91 145Z" fill="#efa955"/><path d="M97 120 Q107 107 116 132" fill="none"/>
{('<path d="M121 134 l10 6 l-7 13 l-15-8Z" fill="#94d5cd"/>' if frame == "collect" else '')}
</g></svg>'''
    (ROOT / f"sloth_{frame}.svg").write_text(art, encoding="utf-8")

(ROOT / "poop.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="48" height="40"><g stroke="#5d4035" stroke-width="2.5" stroke-linejoin="round"><path d="M7 36 Q-2 30 10 23 Q3 17 20 12 Q17 7 28 2 Q38 9 30 15 Q45 18 37 25 Q51 32 40 36Z" fill="#b17b50"/><path d="M12 24 Q25 28 37 24 M17 14 Q25 18 32 14" fill="none"/><circle cx="19" cy="28" r="1.5" fill="#45342b"/><circle cx="30" cy="28" r="1.5" fill="#45342b"/><path d="M20 31 Q25 35 30 31" fill="none" stroke-width="1.5"/></g></svg>''', encoding="utf-8")
(ROOT / "burrow.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="170" height="100"><g stroke="#5f483d" stroke-width="4"><path d="M4 96 Q11 7 85 9 Q156 6 166 96Z" fill="#c39365"/><ellipse cx="85" cy="66" rx="51" ry="29" fill="#443b40"/><path d="M22 62 L31 50 M130 31 L138 43 M42 29 L51 24" stroke="#e4bf8a"/></g></svg>''', encoding="utf-8")
(ROOT / "burrow_rim.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="170" height="50"><path d="M9 31 Q85 47 163 31 L165 48 L5 48Z" fill="#c39365" stroke="#5f483d" stroke-width="4"/><path d="M28 32 l8-7 m102 5 l8-8" stroke="#e4bf8a" stroke-width="3"/></svg>''', encoding="utf-8")
(ROOT / "richard.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="100" height="150"><g stroke="#655251" stroke-width="3.5" stroke-linecap="round"><path d="M32 58 Q11 0 28 4 Q48 11 47 60 M55 59 Q58 -4 75 6 Q91 20 69 68" fill="#fff6eb"/><path d="M31 16 Q27 28 38 47 M72 19 Q78 28 65 48" fill="none" stroke="#e8a2ac" stroke-width="7"/><ellipse cx="51" cy="109" rx="30" ry="33" fill="#fff6eb"/><ellipse cx="50" cy="72" rx="34" ry="28" fill="#fff6eb"/><circle cx="36" cy="69" r="6" fill="#29232b"/><circle cx="64" cy="69" r="6" fill="#29232b"/><circle cx="38" cy="67" r="2" fill="white" stroke="none"/><circle cx="66" cy="67" r="2" fill="white" stroke="none"/><path d="M44 78 Q50 74 56 78 L50 84Z" fill="#dd8f9d"/><path d="M39 87 Q49 95 61 86" fill="none"/><path d="M47 89 v8 h8 v-8" fill="white"/><ellipse cx="30" cy="139" rx="17" ry="8" fill="#fff6eb"/><ellipse cx="70" cy="139" rx="17" ry="8" fill="#fff6eb"/><path d="M29 103 Q19 114 31 121 M72 102 Q87 111 74 121" fill="none"/><path d="M20 80 L6 75 M20 85 L5 86 M78 80 L93 75 M78 85 L95 85" fill="none" stroke-width="2"/></g></svg>''', encoding="utf-8")

for frame in ["idle", "walk", "force"]:
    stride = 7 if frame == "walk" else 0
    arm = '<path d="M84 81 L116 68 L129 62" fill="none" stroke="#a88861" stroke-width="14"/><path d="M123 59 l8-5 m-7 9 l11-2" stroke="#554033" stroke-width="2"/>' if frame == "force" else '<path d="M84 80 L105 110" fill="none" stroke="#a88861" stroke-width="14"/>'
    art = f'''<svg xmlns="http://www.w3.org/2000/svg" width="140" height="170" viewBox="0 0 140 170"><g stroke="#463632" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round">
<path d="M42 123 L{38-stride} 161 L{24-stride} 163 Q20 170 {45-stride} 167 L55 124 M72 124 L{77+stride} 161 L{94+stride} 163 Q100 170 {71+stride} 167 L63 124" fill="#64524b"/>
<path d="M37 69 Q59 57 85 71 L96 133 L27 133Z" fill="#9d7955"/><path d="M45 71 L62 97 L79 71 L79 130 L44 130Z" fill="#efe0bf"/>
<path d="M45 71 L62 95 L53 108 M80 71 L60 101 L64 118" fill="none" stroke="#8d714f"/><path d="M30 112 H92 V123 H30Z" fill="#61443b"/><rect x="57" y="112" width="13" height="11" rx="2" fill="#d9af59"/>
<path d="M35 78 L20 112" fill="none" stroke="#a88861" stroke-width="14"/>{arm}
<ellipse cx="62" cy="41" rx="27" ry="30" fill="#f0c09b"/><path d="M37 37 Q23 0 64 6 Q101 0 88 39 L77 20 L64 29 L50 18Z" fill="#574236"/>
<ellipse cx="49" cy="41" rx="3.8" ry="5.4" fill="#28212a"/><ellipse cx="74" cy="41" rx="3.8" ry="5.4" fill="#28212a"/><circle cx="50" cy="39" r="1.4" fill="white" stroke="none"/><circle cx="75" cy="39" r="1.4" fill="white" stroke="none"/>
<path d="M60 47 l-3 6 h6 M50 57 Q62 70 77 56" fill="none"/><path d="M45 34 l8-2 M70 32 l8 2" fill="none" stroke-width="2"/>
<path d="M12 123 L16 77" fill="none" stroke="#7de9b2" stroke-width="9"/><path d="M12 123 L16 77" fill="none" stroke="#eafff1" stroke-width="3"/><path d="M11 121 L10 141" stroke="#656879" stroke-width="7"/>
</g></svg>'''
    (ROOT / f"guilherme_{frame}.svg").write_text(art, encoding="utf-8")

(ROOT / "bighead.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="86" height="106"><g stroke="#513c58" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"><path d="M33 77 L27 96 L15 101 H33 L41 84 M51 79 L58 98 L73 100 H53 L44 86" fill="#efc96d"/><path d="M29 64 Q43 56 56 65 L58 87 H27Z" fill="#8468ab"/><path d="M29 67 L17 80 M56 67 L69 80" fill="none" stroke-width="8"/><circle cx="43" cy="35" r="31" fill="#c6a5e4"/><path d="M18 19 Q31 -1 49 8 Q68 3 72 25 L62 15 L52 22 L39 11 L30 22Z" fill="#5e486d"/><ellipse cx="31" cy="35" rx="7" ry="9" fill="white"/><ellipse cx="56" cy="35" rx="7" ry="9" fill="white"/><circle cx="33" cy="37" r="3" fill="#34293c"/><circle cx="54" cy="37" r="3" fill="#34293c"/><path d="M23 25 L36 29 M50 29 L63 25 M40 41 l5 5 h-7 M31 53 Q45 59 58 50" fill="none"/><path d="M43 60 V76" stroke="#efd68d"/></g></svg>''', encoding="utf-8")

for frame in ["idle", "walk", "follow", "rescue", "sleep"]:
    step = 5 if frame == "walk" else (-4 if frame == "follow" else 0)
    if frame == "sleep":
        drawing = '''<path d="M18 63 Q2 49 14 46" fill="none"/><ellipse cx="40" cy="61" rx="29" ry="13" fill="white"/><ellipse cx="34" cy="58" rx="11" ry="8" fill="#24232a"/><path d="M37 66 Q66 79 80 69" fill="white"/><ellipse cx="79" cy="55" rx="20" ry="16" fill="white"/><ellipse cx="95" cy="60" rx="13" ry="10" fill="white"/><path d="M68 48 Q57 48 59 67 Q65 77 72 64Z" fill="#24232a"/><path d="M80 54 q5 4 10 0" fill="none"/><ellipse cx="105" cy="57" rx="4" ry="5" fill="#24232a"/><path d="M70 68 L82 70" stroke="#db5357" stroke-width="4"/>'''
    else:
        drawing = f'''<path d="M16 48 Q2 30 12 27" fill="none"/><path d="M23 57 L{23-step} 74 H{35-step} L39 57 M58 57 L{58+step} 74 H{73+step} L75 55" fill="white"/><ellipse cx="43" cy="52" rx="29" ry="18" fill="white"/><ellipse cx="34" cy="47" rx="10" ry="12" fill="#24232a"/><path d="M26 62 L{23+step} 75 H{37+step} L40 64 M61 60 L{60-step} 75 H{75-step} L77 57" fill="white"/><ellipse cx="77" cy="29" rx="21" ry="25" fill="white"/><ellipse cx="93" cy="40" rx="14" ry="13" fill="white"/><path d="M65 21 Q50 20 53 43 Q57 61 67 45Z" fill="#24232a"/><ellipse cx="105" cy="35" rx="4" ry="6" fill="#24232a"/><path d="M77 25 q4 -5 7 0" fill="none"/><circle cx="80" cy="27" r="2.2" fill="#24232a"/><path d="M86 45 Q96 50 102 43" fill="none"/><path d="M67 51 L84 54" stroke="#db5357" stroke-width="5"/>'''
    (ROOT / f"snoopy_{frame}.svg").write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="110" height="80" viewBox="0 0 110 80"><g stroke="#34313a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">{drawing}</g></svg>', encoding="utf-8")

(ROOT / "snoopy_house.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180"><g stroke="#663637" stroke-width="4" stroke-linejoin="round"><path d="M41 65 H206 V176 H41Z" fill="#ec575c"/><path d="M5 65 L71 12 H207 L215 65Z" fill="#d93e48"/><path d="M15 55 H210 M29 42 H210 M44 30 H209" fill="none" stroke="#ad3542" stroke-width="2"/><path d="M75 176 V128 Q111 82 145 128 V176Z" fill="#703b3b"/><path d="M43 87 H205 M44 108 H77 M145 108 H204 M44 133 H75 M147 133 H206 M44 158 H75 M147 158 H206" fill="none" stroke="#c24347" stroke-width="2"/><path d="M38 176 H210" stroke-width="5"/></g></svg>''', encoding="utf-8")
