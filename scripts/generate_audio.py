"""Reproducible chiptune music and sound effects for the castle adventure.

Only the Python standard library is used. Run from the repository root:

    python3 scripts/generate_audio.py

Every sound is synthesized here, so no recorded or third-party audio is part
of the repository or the export.
"""
from pathlib import Path
import math
import random
import struct
import wave

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / "adventure" / "audio"
NOTES = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}


def midi(name: str) -> int:
    return 12 * (int(name[-1]) + 1) + NOTES[name[0]] + (1 if "#" in name else 0)


def freq(note: float) -> float:
    return 440.0 * 2 ** ((note - 69) / 12)


def square(phase: float, duty: float = 0.5) -> float:
    return 1.0 if phase % 1.0 < duty else -1.0


def triangle(phase: float) -> float:
    return 4.0 * abs(phase % 1.0 - 0.5) - 1.0


def envelope(t: float, length: float, attack: float = 0.005, decay: float = 0.08, sustain: float = 0.6, release: float = 0.04) -> float:
    if t < attack:
        return t / attack
    level = sustain + (1.0 - sustain) * max(0.0, 1.0 - (t - attack) / decay)
    if t > length - release:
        level *= max(0.0, (length - t) / release)
    return level


def add_tone(buffer: list, start: float, length: float, hz: float, wave_fn, volume: float, wrap: bool = False, **env) -> None:
    first = int(start * RATE)
    for i in range(int(length * RATE)):
        t = i / RATE
        index = first + i
        if wrap:
            index %= len(buffer)
        elif index >= len(buffer):
            break
        buffer[index] += wave_fn(hz * t) * envelope(t, length, **env) * volume


def write(name: str, samples: list, peak: float = 0.85) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    top = max(1e-9, max(abs(s) for s in samples))
    scale = peak / top
    with wave.open(str(OUT / name), "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(RATE)
        file.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s * scale)) * 32767)) for s in samples))


def lowpass(samples: list, amount: float) -> list:
    result, last = [], 0.0
    for sample in samples:
        last += amount * (sample - last)
        result.append(last)
    return result


def music() -> list:
    # Bouncy C major loop: 16 bars at 150 BPM, eighth-note grid.
    bpm = 150.0
    eighth = 60.0 / bpm / 2.0
    bar = eighth * 8
    chords = ["C", "G", "Am", "F", "C", "G", "F", "G", "F", "G", "Em", "Am", "F", "G", "C", "C"]
    shapes = {"C": ["C3", "E4", "G4", "C5"], "G": ["G2", "D4", "G4", "B4"], "Am": ["A2", "E4", "A4", "C5"],
              "F": ["F2", "C4", "F4", "A4"], "Em": ["E2", "E4", "G4", "B4"]}
    melody = [
        "E5 - G5 - C6 - B5 A5", "G5 - - D5 G5 - B5 -", "A5 - E5 - A5 G5 E5 -", "F5 - A5 - C6 - A5 G5",
        "E5 - G5 - C6 - B5 A5", "B5 - D6 - B5 G5 A5 B5", "C6 - A5 - F5 - G5 A5", "G5 - - - D5 E5 F5 G5",
        "A5 - - G5 F5 - A5 -", "B5 - - A5 G5 - B5 -", "G5 - E5 - G5 - B5 -", "C6 - B5 - A5 - E5 -",
        "F5 - A5 - C6 - A5 -", "D6 - B5 - G5 - B5 D6", "E6 - - D6 C6 - G5 -", "C6 - - - . . G5 -",
    ]
    total = int(bar * len(chords) * RATE)
    lead, bass, keys, drums = [0.0] * total, [0.0] * total, [0.0] * total, [0.0] * total
    for index, (chord, line) in enumerate(zip(chords, melody)):
        start = index * bar
        root, *upper = shapes[chord]
        # Oom-pah bass with an octave bounce.
        for step in range(8):
            note = midi(root) + (12 if step % 2 else 0)
            add_tone(bass, start + step * eighth, eighth * 0.9, freq(note), triangle, 0.55, wrap=True, sustain=0.8)
        # Offbeat chord stabs.
        for step in range(1, 8, 2):
            for note in upper:
                add_tone(keys, start + step * eighth, eighth * 0.55, freq(midi(note)), lambda p: square(p, 0.25), 0.07, wrap=True, decay=0.05, sustain=0.3)
        tokens = line.split()
        step = 0
        while step < 8:
            token = tokens[step]
            if token in "-.":
                step += 1
                continue
            hold = 1
            while step + hold < 8 and tokens[step + hold] == "-":
                hold += 1
            hz = freq(midi(token))
            length = eighth * hold * 0.92
            vibrato = lambda p, hz=hz: square(p + 0.004 * math.sin(2 * math.pi * 5.5 * p / hz), 0.5)
            add_tone(lead, start + step * eighth, length, hz, vibrato, 0.22, wrap=True, decay=0.12, sustain=0.55)
            step += hold
        # Kick on 1 and 3, snare on 2 and 4, soft hats on eighths.
        rng = random.Random(index)
        for beat in range(4):
            first = int((start + beat * eighth * 2) * RATE)
            if beat % 2 == 0:
                phase = 0.0
                for i in range(int(0.12 * RATE)):
                    t = i / RATE
                    phase += (55 + 110 * math.exp(-t * 35)) / RATE
                    drums[(first + i) % total] += math.sin(2 * math.pi * phase) * math.exp(-t * 22) * 0.9
            else:
                for i in range(int(0.1 * RATE)):
                    t = i / RATE
                    drums[(first + i) % total] += (rng.uniform(-1, 1) * 0.5 + math.sin(2 * math.pi * 190 * t) * 0.3) * math.exp(-t * 30)
        for step in range(8):
            first = int((start + step * eighth) * RATE)
            for i in range(int(0.025 * RATE)):
                drums[(first + i) % total] += rng.uniform(-1, 1) * math.exp(-i / RATE * 160) * 0.12
    bass, keys = lowpass(bass, 0.35), lowpass(keys, 0.5)
    return [math.tanh((lead[i] + bass[i] * 0.6 + keys[i] + drums[i] * 0.45) * 1.2) for i in range(total)]


def sweep(length: float, start_hz: float, end_hz: float, wave_fn, decay: float = 0.0) -> list:
    samples, phase = [], 0.0
    count = int(length * RATE)
    for i in range(count):
        t = i / RATE
        phase += (start_hz + (end_hz - start_hz) * i / count) / RATE
        fade = min(1.0, t / 0.004) * min(1.0, (length - t) / 0.02)
        samples.append(wave_fn(phase) * fade * (math.exp(-t * decay) if decay else 1.0))
    return samples


def mix(*parts) -> list:
    size = max(int(offset * RATE) + len(part) for offset, part in parts)
    result = [0.0] * size
    for offset, part in parts:
        first = int(offset * RATE)
        for i, sample in enumerate(part):
            result[first + i] += sample
    return result


def notes(sequence, step: float, wave_fn, length: float) -> list:
    buffer = [0.0] * int((step * len(sequence) + length) * RATE)
    for i, name in enumerate(sequence):
        add_tone(buffer, i * step, length, freq(midi(name)), wave_fn, 0.5, decay=0.1, sustain=0.4, release=0.06)
    return buffer


def bell(phase: float) -> float:
    return math.sin(2 * math.pi * phase) + 0.4 * math.sin(4 * math.pi * phase) + 0.2 * math.sin(6 * math.pi * phase)


def bark() -> list:
    rng = random.Random(7)
    raw = sweep(0.13, 520, 260, lambda p: (p % 1.0) * 2 - 1, decay=14)
    return lowpass([s * 0.8 + rng.uniform(-0.15, 0.15) * abs(s) for s in raw], 0.3)


def fart() -> list:
    rng = random.Random(3)
    samples, phase = [], 0.0
    length = 0.55
    for i in range(int(length * RATE)):
        t = i / RATE
        phase += (95 + 25 * math.sin(t * 31) + rng.uniform(-18, 18)) / RATE
        flutter = 0.65 + 0.35 * math.sin(t * 2 * math.pi * 23)
        samples.append(square(phase, 0.3) * flutter * min(1.0, t / 0.02) * min(1.0, (length - t) / 0.12))
    return lowpass(samples, 0.12)


def whoosh(length: float, start: float, end: float, seed: int) -> list:
    rng = random.Random(seed)
    result, last = [], 0.0
    count = int(length * RATE)
    for i in range(count):
        amount = start + (end - start) * i / count
        last += amount * (rng.uniform(-1, 1) - last)
        t = i / RATE
        result.append(last * math.sin(math.pi * t / length))
    return result


def yawn() -> list:
    samples, phase = [], 0.0
    length = 1.3
    for i in range(int(length * RATE)):
        t = i / RATE
        hz = 260 - 110 * (t / length) + 6 * math.sin(t * 2 * math.pi * 5)
        phase += hz / RATE
        voice = (phase % 1.0) * 2 - 1
        samples.append(voice * math.sin(math.pi * t / length) ** 0.7)
    return lowpass(lowpass(samples, 0.08), 0.15)


def main() -> None:
    write("music_castle.wav", music(), peak=0.8)
    write("jump.wav", sweep(0.14, 330, 760, lambda p: square(p, 0.25), decay=12), peak=0.5)
    write("rescue.wav", mix((0.0, bark()), (0.17, bark()), (0.36, notes(["C5", "E5", "G5", "C6"], 0.075, bell, 0.25))))
    write("collect.wav", mix((0.0, sweep(0.18, 620, 140, lambda p: math.sin(2 * math.pi * p), decay=8)), (0.16, notes(["G5", "C6"], 0.08, bell, 0.2))))
    write("paw.wav", notes(["E6", "B6"], 0.09, bell, 0.35))
    write("judo.wav", mix((0.0, whoosh(0.25, 0.05, 0.6, 1)), (0.12, sweep(0.3, 220, 660, lambda p: math.sin(2 * math.pi * p + 0.6 * math.sin(6 * math.pi * p)), decay=6))))
    write("force.wav", mix((0.0, lowpass(sweep(0.6, 70, 140, lambda p: (p % 1.0) * 2 - 1), 0.1)), (0.0, sweep(0.6, 880, 1320, lambda p: math.sin(2 * math.pi * p) * 0.25, decay=3))))
    write("pum.wav", fart())
    write("gate.wav", mix((0.0, notes(["C5", "E5", "G5"], 0.11, lambda p: square(p, 0.5), 0.12)), (0.33, notes(["C6"], 0.1, lambda p: square(p, 0.5), 0.5)), (0.33, notes(["E5", "G5"], 0.0, lambda p: square(p, 0.25), 0.5))))
    write("yawn.wav", yawn(), peak=0.6)
    print("Audio written to", OUT)


if __name__ == "__main__":
    main()
