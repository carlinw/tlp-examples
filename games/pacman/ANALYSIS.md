# PAC-MAN Implementation Analysis

## Overview

This document analyzes the current `pacman.tpl` implementation against the official PAC-MAN specification (based on *The Pac-Man Dossier* by Jamey Pittman) and identifies language features that would be needed in TPL for a more faithful reproduction.

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

## Required Language Features Analysis

### Features TPL Already Has (Adequate)

1. **Variables & Data Types**: `let`, numbers, strings, booleans, arrays
2. **Control Flow**: `if/else if/else`, `while` loops
3. **Functions**: User-defined, parameters, return values, recursion
4. **Arrays**: Dynamic, indexed access, `.length()`
5. **String Operations**: Concatenation, indexing, comparison
6. **Classes**: Object-oriented programming with `class`, `new`, `this`
7. **Graphics Primitives**: `rect()`, `circle()`, `line()`, `triangle()`, `text()`
8. **Input Handling**: `pressed()` for keyboard polling
9. **Random Numbers**: `random(min, max)`
10. **Timing**: `sleep(ms)`

### Missing Language Features for Faithful Implementation

#### Critical (Block Core Gameplay Accuracy)

| Feature | Why Needed | Workaround Possible? |
|---------|------------|---------------------|
| **`sqrt()` function** | Euclidean distance for ghost pathfinding | Yes - use squared distances for comparison |
| **Frame counter / `getTime()`** | 1/3 frame pauses, mode timers, animation sync | Partial - use `sleep()` accumulation |
| **Floating-point precision control** | Sub-pixel positioning, speed percentages | Partial - use fixed-point with integers |

#### Important (Affect Authenticity)

| Feature | Why Needed | Workaround Possible? |
|---------|------------|---------------------|
| **Bitwise operators** (`&`, `|`, `^`, `<<`, `>>`) | Efficient wall flags, PRNG implementation | Yes - use arithmetic (slower) |
| **Constants** (`const`) | Magic numbers, tile counts, timing values | Yes - use `let` and discipline |
| **Enums / named states** | Ghost modes (CHASE, SCATTER, FRIGHTENED) | Yes - use integers with comments |
| **`floor()` / `ceil()` / `round()`** | Tile calculations from pixel positions | Partial - integer division truncates |
| **`abs()` function** | Distance calculations | Yes - `if (x < 0) { x = -x }` |
| **Modulo for negatives** | Wrap-around calculations | Need to verify behavior |

#### Nice to Have (Polish & Completeness)

| Feature | Why Needed | Workaround Possible? |
|---------|------------|---------------------|
| **Audio API** | Sound effects per spec | No - not possible without audio support |
| **Sprite/image loading** | Authentic graphics, animations | No - must use primitives |
| **`for` loop syntax** | Cleaner iteration | Yes - use `while` |
| **Multiple return values / tuples** | Ghost movement returns (dx, dy) | Yes - use arrays (current approach) |
| **Hash maps / dictionaries** | Named state lookups | Yes - use arrays with indices |

---

## Feasibility Assessment

### What CAN Be Faithfully Implemented with Current TPL

1. **Complete maze with proper layout** - Already done
2. **Basic ghost AI with scatter/chase** - Needs implementation work
3. **Power pellet mode** - Partially done, needs timer improvements
4. **Scoring system** - Needs ghost chain multiplier
5. **Multiple levels** - Can track level number, adjust speeds
6. **Ghost house exit logic** - Can use counters
7. **Fruit bonuses** - Can implement with dot counter
8. **Lives system** - Can add life counter and reset

### What CANNOT Be Faithfully Implemented Without New Features

1. **True Euclidean pathfinding** - Need `sqrt()` (can approximate)
2. **Sound effects** - Need audio API
3. **Sprite-based graphics** - Need image loading
4. **Frame-perfect timing** - Need frame counter or high-precision timer
5. **PRNG for frightened mode** - Need seeded random or bitwise ops

---

## Recommendations

### For a More Faithful Implementation in Current TPL

1. **Use squared distance comparison** instead of Euclidean distance (mathematically equivalent for comparisons)
2. **Implement state machine** using integer constants for modes
3. **Add mode timer** using accumulated sleep calls
4. **Implement ghost chain scoring** with counter reset per energizer
5. **Add scatter targets** for each ghost
6. **Implement proper ghost exit sequencing**
7. **Add fruit spawning** at 70/170 dot counts

### Language Features to Request

**Priority 1 (High Impact):**
- `sqrt(x)` - Square root function
- `floor(x)`, `ceil(x)`, `round(x)` - Rounding functions
- `abs(x)` - Absolute value
- `millis()` or frame counter - Precise timing

**Priority 2 (Medium Impact):**
- Bitwise operators - For efficient flags and PRNG
- `sin(x)`, `cos(x)` - For animations (optional)
- Audio functions - `playSound()`, `stopSound()`

**Priority 3 (Polish):**
- Image/sprite loading
- `for` loop syntax
- Constants with `const`

---

## Conclusion

The current TPL language provides sufficient features for a **recognizable PAC-MAN game** but lacks the precision required for an **arcade-accurate reproduction**. The most critical gaps are:

1. **Mathematical functions** (`sqrt`, `abs`) - Can be worked around
2. **Precise timing** - Partially addressable with `sleep()`
3. **Audio support** - Cannot be addressed without new API

A faithful implementation is approximately **70% achievable** with current TPL features using workarounds. The remaining 30% would require language extensions, primarily around timing precision and audio support.

The current `pacman.tpl` implements roughly **30-40%** of the full specification. With significant additional work using existing TPL features, this could be raised to **60-70%** accuracy.
