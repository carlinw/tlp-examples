# PAC-MAN Implementation Analysis

## Overview

This document analyzes the current `pacman.tpl` implementation against the official PAC-MAN specification (based on *The Pac-Man Dossier* by Jamey Pittman) and identifies language features needed for a faithful reproduction.

---

## Current Implementation Summary

The current implementation provides a basic playable PAC-MAN game with:
- 28x31 tile grid with classic maze layout
- Pac-Man with 4-directional movement and mouth animation
- 4 ghosts with basic chase AI
- Dots (240 small + 4 power pellets)
- Power-up mode (ghosts turn blue, can be eaten)
- Score tracking
- Win/lose conditions
- Tunnel wrapping

**Current spec coverage: ~30-40%**

---

## Gap Analysis: Current Implementation vs Specification

### 1. Movement Mechanics

| Feature | Spec Requirement | Current Status | Gap |
|---------|------------------|----------------|-----|
| Speed percentages | 80%/90%/100% based on level | Fixed speed | **Missing** |
| Dot eating pause | 1 frame (small), 3 frames (energizer) | No pause | **Missing** |
| Cornering pre/post-turn | 3-4 pixel early turn window | Tile-based only | **Missing** |
| Sub-pixel positioning | Pixel-precise movement | Tile-based | **Missing** |
| Tunnel speed reduction | Ghosts 40-50% speed in tunnels | Same speed | **Missing** |

### 2. Ghost AI

| Feature | Spec Requirement | Current Status | Gap |
|---------|------------------|----------------|-----|
| Blinky targeting | Direct chase (Pac-Man's tile) | Implemented | OK |
| Pinky targeting | 4 tiles ahead + overflow bug | 4 tiles ahead (no bug) | Partial |
| Inky targeting | Vector doubling from Blinky | Fixed center target | **Missing** |
| Clyde targeting | Distance-based switching | Fixed chase | **Missing** |
| Euclidean distance | sqrt((x2-x1)^2 + (y2-y1)^2) | Greedy direction | **Missing** |
| Direction priority | Up > Left > Down > Right on ties | First valid direction | **Missing** |
| No-reverse rule | Ghosts never reverse voluntarily | Not enforced | **Missing** |
| Scatter mode | Fixed corner targets | Not implemented | **Missing** |
| Mode alternation | Scatter/Chase timer cycles | Chase only | **Missing** |
| Cruise Elroy | Blinky speedup at low dot count | Not implemented | **Missing** |

### 3. Frightened Mode

| Feature | Spec Requirement | Current Status | Gap |
|---------|------------------|----------------|-----|
| Duration by level | 6s down to 0s | Fixed ~6 seconds | Partial |
| Ghost flashing | Flash before ending | No flashing | **Missing** |
| Random movement | PRNG-based direction | Not random | **Missing** |
| Direction reversal | Reverse on mode change | Not implemented | **Missing** |
| Ghost point escalation | 200/400/800/1600 | Fixed 200 | **Missing** |

### 4. Ghost House

| Feature | Spec Requirement | Current Status | Gap |
|---------|------------------|----------------|-----|
| Staged exits | Dot counter per ghost | All start outside | **Missing** |
| Exit order | Pinky -> Inky -> Clyde | N/A | **Missing** |
| Inactivity timer | 3-4 second forced exit | Not implemented | **Missing** |
| Eyes return | Dead ghosts go to house | Instant respawn | **Missing** |

### 5. Scoring & Progression

| Feature | Spec Requirement | Current Status | Gap |
|---------|------------------|----------------|-----|
| Small dots | 10 points | Implemented | OK |
| Energizers | 50 points | Implemented | OK |
| Ghost chain | 200-400-800-1600 | Fixed 200 | **Missing** |
| Bonus fruit | Appears at 70/170 dots | Not implemented | **Missing** |
| Fruit points | 100-5000 by level | N/A | **Missing** |
| Extra lives | At 10,000 points | Not implemented | **Missing** |
| Level progression | Speed/timing changes | Single level only | **Missing** |

### 6. Visual/Audio

| Feature | Spec Requirement | Current Status | Gap |
|---------|------------------|----------------|-----|
| Ghost eyes | White with blue pupils | No pupils | Minor |
| Frightened flash | Blue/white alternation | No flash | **Missing** |
| Eaten ghost score display | Show points briefly | Not shown | **Missing** |
| Ready screen | "READY!" before round | Not implemented | **Missing** |
| Death animation | Descending tones visual | Instant game over | **Missing** |
| Sound effects | Multiple audio cues | No audio | **Missing** |

---

## TPL Language Feature Assessment

### Features TPL Already Has (Adequate)

1. **Variables & Data Types**: `let`, numbers, strings, booleans, arrays
2. **Control Flow**: `if/else if/else`, `while` loops
3. **Functions**: User-defined, parameters, return values, recursion
4. **Arrays**: Dynamic, indexed access, `.length()`
5. **String Operations**: Concatenation, indexing, comparison
6. **Classes**: Object-oriented programming with `class`, `new`, `this`
7. **Graphics Primitives**: `rect()`, `circle()`, `line()`, `triangle()`, `text()`
8. **Input Handling**: `pressed()` for keyboard polling
9. **Random Numbers**: `random(min, max)` - sufficient for frightened mode
10. **Timing**: `sleep(ms)` - frame counting via loop iterations works fine

### Features with Easy Workarounds (Not Blockers)

| Feature | Workaround |
|---------|------------|
| `abs(x)` | `if (x < 0) { x = -x }` |
| `floor(x)` | Integer division already truncates |
| `ceil(x)` | `floor(x) + 1` when needed |
| Frame counting | Count loop iterations, use `sleep(16)` for ~60 FPS |
| Constants | Use `let` with naming discipline |
| Enums | Use integers with comments |

### Features NOT Needed

| Feature | Reason |
|---------|--------|
| Bitwise operators | `random()` handles frightened mode; arithmetic works for flags |
| PRNG seed control | `random()` is sufficient |
| `millis()` / precise timer | Loop iteration counting works |

---

## Required New Language Features

### 1. sqrt() Function (Confirmed for upcoming release)

**Why needed:** Ghost pathfinding uses Euclidean distance to choose directions.

```
// Spec requires: distance = sqrt((x2-x1)^2 + (y2-y1)^2)
let dx = targetX - ghostX
let dy = targetY - ghostY
let distance = sqrt(dx * dx + dy * dy)
```

Note: For comparisons only, squared distances work. But `sqrt()` enables cleaner code and exact spec compliance.

### 2. Audio API

**Required sounds:**

| Sound | Behavior | Trigger |
|-------|----------|---------|
| intro | Play once | Game start |
| waka | Alternating tone | Each dot eaten |
| siren | Loop, pitch rises as dots decrease | During normal play |
| frightened | Different loop | During power mode |
| ghost-eaten | Short effect | Eat ghost |
| fruit-eaten | Short effect | Eat fruit |
| extra-life | Short jingle | Hit 10k points |
| death | Descending sequence | Pac-Man dies |

**Proposed API (browser-compatible):**

```
sound("waka")              // Play sound effect once
soundLoop("siren")         // Start looping sound
soundStop("siren")         // Stop specific looping sound
soundStop()                // Stop all sounds
```

**Optional enhancements:**
```
soundVolume("siren", 0.5)  // Volume 0.0 to 1.0
soundRate("siren", 1.2)    // Playback rate for pitch shifting
```

**Browser implementation:** Preloaded audio files (MP3/WAV), runtime handles Web Audio API.

### 3. Sprite API

**Required sprites:**

| Sprite | Frames | Notes |
|--------|--------|-------|
| pacman-right | 3 | Closed, half-open, open mouth |
| pacman-left | 3 | Or horizontal flip |
| pacman-up | 3 | |
| pacman-down | 3 | |
| pacman-death | 11 | Death animation sequence |
| ghost-red | 2 | Wobble animation |
| ghost-pink | 2 | |
| ghost-cyan | 2 | |
| ghost-orange | 2 | |
| ghost-frightened | 2 | Blue body |
| ghost-flash | 4 | Blue/white alternation |
| ghost-eyes-right | 1 | Eyes returning to house |
| ghost-eyes-left | 1 | |
| ghost-eyes-up | 1 | |
| ghost-eyes-down | 1 | |
| fruit-cherry | 1 | Level 1 |
| fruit-strawberry | 1 | Level 2 |
| fruit-peach | 1 | Levels 3-4 |
| fruit-apple | 1 | Levels 5-6 |
| fruit-grapes | 1 | Levels 7-8 |
| fruit-galaxian | 1 | Levels 9-10 |
| fruit-bell | 1 | Levels 11-12 |
| fruit-key | 1 | Level 13+ |
| score-200 | 1 | Ghost eaten popup |
| score-400 | 1 | |
| score-800 | 1 | |
| score-1600 | 1 | |

**Proposed API:**

```
sprite("ghost-red", x, y)           // Draw sprite at position
sprite("ghost-red", x, y, frame)    // Draw specific animation frame (0-indexed)
```

**Optional enhancements:**
```
spriteFlip("pacman-right", x, y, true, false)  // Flip horizontal/vertical
spriteScale("ghost-red", x, y, 2.0)            // Scale factor
```

**Browser implementation:** Preloaded spritesheet, runtime handles slicing and drawing to canvas.

---

## Feasibility With New Features

### Coverage Estimate with sqrt() + Audio + Sprites

| Category | Coverage | Notes |
|----------|----------|-------|
| Maze & Movement | 95% | Cornering pre/post-turn is remaining 5% |
| Ghost AI | 95% | All targeting fully implementable |
| Frightened Mode | 100% | `random()` + sprites handle everything |
| Scoring | 100% | Implementation work only |
| Ghost House | 100% | Implementation work only |
| Audio | 100% | With proposed API |
| Visuals | 95% | Sprites handle all animations |
| Level Progression | 100% | Data tables, no new features needed |

### What Remains at <100%

1. **Cornering mechanic** (3-4 pixel early turn window) - Subtle physics detail
2. **Pass-through bug** (same-frame tile swap) - Extremely rare edge case
3. **Level 256 corruption** - Intentional bug replication (optional)

---

## Conclusion

**With `sqrt()`, audio API, and sprite API: 90-95% spec accuracy achievable.**

The remaining 5-10% consists of subtle physics details (cornering) and rare edge cases (pass-through bug) that even many official ports don't replicate.

### Summary of Required Features

| Feature | Priority | Status |
|---------|----------|--------|
| `sqrt(x)` | Required | Confirmed for upcoming release |
| `sound(name)` | Required | Proposed |
| `soundLoop(name)` | Required | Proposed |
| `soundStop(name)` | Required | Proposed |
| `sprite(name, x, y, frame)` | Required | Proposed |

### Implementation Roadmap

1. **R8**: Add `sqrt()`, audio API, sprite API to TPL runtime
2. **R9**: Upgrade `pacman.tpl` with full ghost AI, audio, sprites, level progression
