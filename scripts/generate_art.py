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

for kind in ["fofins", "amigo"]:
    for state in ["idle", "walk", "rescue", "follow"]:
        (ROOT / f"{kind}_{state}.svg").write_text(dog(kind, state), encoding="utf-8")

palettes = [("#eed29b", "#f179a4", "#f8e4bc"), ("#bbd5dd", "#8863b5", "#d9e9ed"), ("#e8c3e5", "#526ec8", "#f2ddf0")]
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
    elements.append('</g></svg>')
    (ROOT / f"castle_{index}.svg").write_text("\n".join(elements), encoding="utf-8")

(ROOT / "gate.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="160" height="180"><g stroke="#4c3b48" stroke-width="4" stroke-linejoin="round"><path d="M15 178 V72 Q80 -8 145 72 V178Z" fill="#ffd174"/><path d="M33 178 V78 Q80 16 127 78 V178Z" fill="#795b9b"/><path d="M38 175 V81 Q80 31 122 81 V175Z" fill="#b3ecdf" stroke="none"/><path d="M80 37 V174" fill="none"/><circle cx="68" cy="120" r="5" fill="#ffd174"/><path d="M13 178 H148"/></g></svg>''', encoding="utf-8")
(ROOT / "paw.svg").write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="54" height="54"><circle cx="27" cy="27" r="25" fill="#ffda69" stroke="#68542f" stroke-width="3"/><g fill="#a36947"><ellipse cx="16" cy="19" rx="5" ry="7" transform="rotate(-22 16 19)"/><ellipse cx="27" cy="14" rx="5" ry="7"/><ellipse cx="38" cy="19" rx="5" ry="7" transform="rotate(22 38 19)"/><path d="M14 35 Q15 27 27 24 Q39 27 40 35 Q39 42 32 40 Q27 37 22 40 Q14 42 14 35Z"/></g></svg>''', encoding="utf-8")
