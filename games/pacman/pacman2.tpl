// PAC-MAN - Enhanced Implementation
// Based on The Pac-Man Dossier specification
// Arrow keys to move, eat all 244 dots to advance!

// ============================================
// AUDIO LOADING
// ============================================

// Load sound effects from daleharvey/pacman GitHub repository
let audioBase = "https://raw.githubusercontent.com/daleharvey/pacman/master/audio/"

sound.load("intro", audioBase + "opening_song.mp3")
sound.load("chomp", audioBase + "eating.short.mp3")
sound.load("eatghost", audioBase + "eatghost.mp3")
sound.load("eatpill", audioBase + "eatpill.mp3")
sound.load("die", audioBase + "die.mp3")
sound.load("siren", audioBase + "siren.mp3")
sound.load("extralive", audioBase + "extra lives.mp3")
sound.load("intermission", audioBase + "intermission.mp3")

// ============================================
// SPRITE LOADING
// ============================================

// Load sprites from vilbeyli/Pacman GitHub repository
let spriteBase = "https://raw.githubusercontent.com/vilbeyli/Pacman/master/Assets/Sprites/"

sprite.load("pacman", spriteBase + "pacman.png")
sprite.load("blinky", spriteBase + "blinky.png")
sprite.load("spritesheet", spriteBase + "spritesheet.png")

// Also load from rm-hull/big-bang for a complete sprite sheet
let spriteBase2 = "https://raw.githubusercontent.com/rm-hull/big-bang/master/examples/pacman/"
sprite.load("spritemap", spriteBase2 + "spritemap-384.png")

// Flag to control whether to use sprites or primitives
// Set to false if sprites fail to load
let useSprites = true

// ============================================
// CONFIGURATION CONSTANTS
// ============================================

let CELL_SIZE = 12
let COLS = 28
let ROWS = 31
let TOTAL_DOTS = 244

// Game states
let STATE_READY = 0
let STATE_PLAYING = 1
let STATE_DEATH = 2
let STATE_LEVEL_COMPLETE = 3
let STATE_GAME_OVER = 4

// Ghost modes
let MODE_SCATTER = 0
let MODE_CHASE = 1
let MODE_FRIGHTENED = 2
let MODE_EYES = 3

// Direction constants
let DIR_UP = 0
let DIR_LEFT = 1
let DIR_DOWN = 2
let DIR_RIGHT = 3
let DIR_NONE = 4

// Direction deltas: [dx, dy] for UP, LEFT, DOWN, RIGHT
let dirDX = [0, -1, 0, 1]
let dirDY = [-1, 0, 1, 0]

// ============================================
// LEVEL DATA TABLES (from spec)
// ============================================

// Pac-Man speeds by level (as percentage * 10, so 80 = 80%)
let pacSpeedNormal = [80, 90, 90, 90, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 90]
let pacSpeedFright = [90, 95, 95, 95, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]

// Ghost speeds by level
let ghostSpeedNormal = [75, 85, 85, 85, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95]
let ghostSpeedFright = [50, 55, 55, 55, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60]
let ghostSpeedTunnel = [40, 45, 45, 45, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50]

// Frightened mode duration (frames at 60fps, so 360 = 6 seconds)
let frightDuration = [360, 300, 240, 180, 120, 300, 120, 120, 60, 300, 120, 60, 60, 180, 60, 60, 0, 60, 0, 0, 0]

// Scatter/Chase mode timings (in frames)
// Phase pattern: Scatter1, Chase1, Scatter2, Chase2, Scatter3, Chase3, Scatter4, Chase4
let scatterTime1 = [420, 420, 300]  // 7s, 7s, 5s for levels 1, 2-4, 5+
let chaseTime1 = [1200, 1200, 1200]  // 20s all levels
let scatterTime2 = [420, 420, 300]
let chaseTime2 = [1200, 1200, 1200]
let scatterTime3 = [300, 300, 300]  // 5s all levels
let chaseTime3 = [1200, 61980, 62220]  // 20s, 1033s, 1037s
let scatterTime4 = [300, 1, 1]  // 5s, 1/60s, 1/60s

// Cruise Elroy thresholds [dots remaining to activate]
let elroy1Dots = [20, 30, 40, 40, 40, 40, 40, 40, 60, 60, 60, 80, 80, 80, 100, 100, 100, 100, 120, 120, 120]
let elroy2Dots = [10, 15, 20, 20, 20, 20, 20, 20, 30, 30, 30, 40, 40, 40, 50, 50, 50, 50, 60, 60, 60]

// Ghost house dot counters by level
let inkyDotLimit = [30, 0, 0]
let clydeDotLimit = [60, 50, 0]

// Bonus fruit by level
let fruitPoints = [100, 300, 500, 500, 700, 700, 1000, 1000, 2000, 2000, 3000, 3000, 5000]

// ============================================
// MAZE LAYOUT
// ============================================

// Map cell types: 0=empty, 1=wall, 2=dot, 3=power pellet, 4=ghost house, 5=ghost door
let map = []

// Classic Pac-Man maze layout (28x31)
let layout = "1111111111111111111111111111"
layout = layout + "1222222222222112222222222221"
layout = layout + "1211112111112112111112111121"
layout = layout + "1311112111112112111112111131"
layout = layout + "1211112111112112111112111121"
layout = layout + "1222222222222222222222222221"
layout = layout + "1211112112111111112112111121"
layout = layout + "1211112112111111112112111121"
layout = layout + "1222222112222112222112222221"
layout = layout + "1111112111110110111112111111"
layout = layout + "0000012111110110111112100000"
layout = layout + "0000012110000000000112100000"
layout = layout + "0000012110111551110112100000"
layout = layout + "1111112110144444410112111111"
layout = layout + "0000002000144444410002000000"
layout = layout + "1111112110144444410112111111"
layout = layout + "0000012110111111110112100000"
layout = layout + "0000012110000000000112100000"
layout = layout + "0000012110111111110112100000"
layout = layout + "1111112110111111110112111111"
layout = layout + "1222222222222112222222222221"
layout = layout + "1211112111112112111112111121"
layout = layout + "1211112111112112111112111121"
layout = layout + "1322112222222002222222112231"
layout = layout + "1112112112111111112112112111"
layout = layout + "1112112112111111112112112111"
layout = layout + "1222222112222112222112222221"
layout = layout + "1211111111112112111111111121"
layout = layout + "1211111111112112111111111121"
layout = layout + "1222222222222222222222222221"
layout = layout + "1111111111111111111111111111"

// No-upward-turn zones (ghost AI restriction)
// These tiles prevent ghosts from turning up during scatter/chase
let noUpZones = [[12, 11], [15, 11], [12, 23], [15, 23]]

// ============================================
// MAP FUNCTIONS
// ============================================

function initMap() {
  let i = 0
  while (i < COLS * ROWS) {
    let c = layout[i]
    if (c equals "1") {
      map[i] = 1
    } else if (c equals "2") {
      map[i] = 2
    } else if (c equals "3") {
      map[i] = 3
    } else if (c equals "4") {
      map[i] = 4
    } else if (c equals "5") {
      map[i] = 5
    } else {
      map[i] = 0
    }
    i = i + 1
  }
}

function getCell(x, y) {
  if (x < 0 or x >= COLS or y < 0 or y >= ROWS) {
    return 1
  }
  return map[x + y * COLS]
}

function setCell(x, y, val) {
  if (x >= 0 and x < COLS and y >= 0 and y < ROWS) {
    map[x + y * COLS] = val
  }
}

function isWalkable(x, y) {
  let cell = getCell(x, y)
  return cell not equals 1
}

function isWalkableForGhost(x, y) {
  let cell = getCell(x, y)
  // Ghosts can walk on empty, dots, power pellets, ghost house, and door
  return cell not equals 1
}

function isInTunnel(x, y) {
  return (y equals 14 and (x < 6 or x > 21))
}

function isNoUpZone(x, y) {
  let i = 0
  while (i < noUpZones.length()) {
    if (noUpZones[i][0] equals x and noUpZones[i][1] equals y) {
      return true
    }
    i = i + 1
  }
  return false
}

function countDotsRemaining() {
  let count = 0
  let i = 0
  while (i < COLS * ROWS) {
    if (map[i] equals 2 or map[i] equals 3) {
      count = count + 1
    }
    i = i + 1
  }
  return count
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

function abs(x) {
  if (x < 0) {
    return 0 - x
  }
  return x
}

function getLevelIndex(level) {
  if (level <= 1) { return 0 }
  if (level <= 4) { return 1 }
  return 2
}

function getSpeedIndex(level) {
  if (level > 21) { return 20 }
  return level - 1
}

// Euclidean distance squared (avoid sqrt where possible)
function distanceSquared(x1, y1, x2, y2) {
  let dx = x2 - x1
  let dy = y2 - y1
  return dx * dx + dy * dy
}

// Get opposite direction
function oppositeDir(dir) {
  if (dir equals DIR_UP) { return DIR_DOWN }
  if (dir equals DIR_DOWN) { return DIR_UP }
  if (dir equals DIR_LEFT) { return DIR_RIGHT }
  if (dir equals DIR_RIGHT) { return DIR_LEFT }
  return DIR_NONE
}

// ============================================
// GHOST CLASS
// ============================================

class Ghost {
  name, colorName,
  tileX, tileY,
  direction,
  mode,
  scatterTargetX, scatterTargetY,
  isInHouse, dotCounter, dotLimit,
  isActive, isEyes,

  // Get chase target based on ghost personality
  getChaseTarget(pacX, pacY, pacDir, blinkyX, blinkyY) {
    let targetX = pacX
    let targetY = pacY

    if (this.name equals "blinky") {
      // Blinky: Direct chase - target Pac-Man's tile
      targetX = pacX
      targetY = pacY
    } else if (this.name equals "pinky") {
      // Pinky: Ambush - target 4 tiles ahead of Pac-Man
      targetX = pacX + dirDX[pacDir] * 4
      targetY = pacY + dirDY[pacDir] * 4
      // Overflow bug: when facing up, also offset left by 4
      if (pacDir equals DIR_UP) {
        targetX = targetX - 4
      }
    } else if (this.name equals "inky") {
      // Inky: Complex - vector from Blinky through point 2 ahead of Pac-Man, doubled
      let aheadX = pacX + dirDX[pacDir] * 2
      let aheadY = pacY + dirDY[pacDir] * 2
      // Overflow bug when facing up
      if (pacDir equals DIR_UP) {
        aheadX = aheadX - 2
      }
      // Double the vector from Blinky to the ahead point
      targetX = aheadX + (aheadX - blinkyX)
      targetY = aheadY + (aheadY - blinkyY)
    } else if (this.name equals "clyde") {
      // Clyde: Shy - chase if far, scatter if close
      let dist = distanceSquared(this.tileX, this.tileY, pacX, pacY)
      if (dist > 64) {  // 8 tiles = 64 squared
        targetX = pacX
        targetY = pacY
      } else {
        targetX = this.scatterTargetX
        targetY = this.scatterTargetY
      }
    }

    return [targetX, targetY]
  }

  // Choose best direction using spec algorithm
  // Per spec: "When entering a new tile, ghost looks ahead to the NEXT tile"
  chooseBestDirection(targetX, targetY, currentMode, globalMode) {
    // If eyes, head to ghost house entrance
    if (this.isEyes) {
      targetX = 13
      targetY = 11
    }

    // Current tile where ghost is making decision
    let currentX = this.tileX
    let currentY = this.tileY

    // Check if in no-up zone (restricts upward turns in scatter/chase)
    let canTurnUp = true
    if ((currentMode equals MODE_SCATTER or currentMode equals MODE_CHASE) and not this.isEyes) {
      canTurnUp = not isNoUpZone(currentX, currentY)
    }

    // Evaluate all directions: UP, LEFT, DOWN, RIGHT (priority order per spec)
    let bestDir = this.direction
    let bestDist = 999999
    let reverseDir = oppositeDir(this.direction)
    let foundValid = false

    // Direction priority: UP > LEFT > DOWN > RIGHT
    let testDirs = [DIR_UP, DIR_LEFT, DIR_DOWN, DIR_RIGHT]
    let i = 0
    while (i < 4) {
      let testDir = testDirs[i]
      let shouldTest = true

      // Skip reverse direction (ghosts never voluntarily reverse)
      if (testDir equals reverseDir) {
        shouldTest = false
      }

      // Skip up if in no-up zone
      if (testDir equals DIR_UP and not canTurnUp) {
        shouldTest = false
      }

      if (shouldTest) {
        let testX = currentX + dirDX[testDir]
        let testY = currentY + dirDY[testDir]

        // Check if this direction is walkable
        let canWalk = isWalkableForGhost(testX, testY)

        // Eyes can go through ghost door
        if (this.isEyes) {
          let cellType = getCell(testX, testY)
          if (cellType equals 5 or cellType equals 4) {
            canWalk = true
          }
        }

        // Regular ghosts can exit through door but not enter from outside
        if (not this.isEyes and not this.isInHouse) {
          if (getCell(testX, testY) equals 5) {
            canWalk = false
          }
        }

        if (canWalk) {
          let dist = distanceSquared(testX, testY, targetX, targetY)
          // Use strictly less than to maintain priority order (first match wins on tie)
          if (dist < bestDist) {
            bestDist = dist
            bestDir = testDir
            foundValid = true
          }
        }
      }

      i = i + 1
    }

    // If no valid direction found, allow reverse as last resort
    if (not foundValid) {
      bestDir = reverseDir
    }

    return bestDir
  }

  // Move the ghost
  move() {
    this.tileX = this.tileX + dirDX[this.direction]
    this.tileY = this.tileY + dirDY[this.direction]

    // Tunnel wrap
    if (this.tileX < 0) { this.tileX = COLS - 1 }
    if (this.tileX >= COLS) { this.tileX = 0 }
  }

  // Reverse direction (called on mode change)
  reverse() {
    this.direction = oppositeDir(this.direction)
  }

  // Send to ghost house as eyes
  becomeEyes() {
    this.isEyes = true
    this.mode = MODE_EYES
  }

  // Respawn from ghost house
  respawn(startX, startY) {
    this.tileX = startX
    this.tileY = startY
    this.isEyes = false
    this.isInHouse = true
    this.isActive = false
    this.dotCounter = 0
  }

  // Exit ghost house
  exitHouse() {
    this.isInHouse = false
    this.isActive = true
    this.tileX = 13
    this.tileY = 11
    this.direction = DIR_LEFT
  }
}

// ============================================
// GAME STATE
// ============================================

// Pac-Man state
let pacX = 13
let pacY = 23
let pacDir = DIR_LEFT
let pacNextDir = DIR_LEFT
let mouthOpen = true

// Score and lives
let score = 0
let lives = 3
let level = 1
let dotsEaten = 0

// Ghost chain scoring
let ghostsEatenThisPower = 0
let ghostPoints = [200, 400, 800, 1600]

// Mode control
let globalMode = MODE_SCATTER
let modeTimer = 0
let modePhase = 0
let frightTimer = 0
let frightFlash = false

// Ghost house control
let globalDotCounter = 0
let useGlobalCounter = false
let inactivityTimer = 0
let activeGhostIndex = 0  // Which ghost's personal counter is active

// Fruit control
let fruitActive = false
let fruitTimer = 0
let fruitX = 13
let fruitY = 17

// Game state
let gameState = STATE_READY
let stateTimer = 0

// Ghosts array
let ghosts = []

// Score popup
let scorePopup = 0
let scorePopupX = 0
let scorePopupY = 0
let scorePopupTimer = 0

// Audio state
let sirenPlaying = false
let lastChompTime = 0
let chompCounter = 0

// ============================================
// INITIALIZATION
// ============================================

function initGhosts() {
  // Create 4 ghosts with their personalities
  // Constructor args: name, colorName, tileX, tileY, direction, mode,
  //                   scatterTargetX, scatterTargetY, isInHouse, dotCounter, dotLimit, isActive, isEyes

  let inkyLimit = inkyDotLimit[getLevelIndex(level)]
  let clydeLimit = clydeDotLimit[getLevelIndex(level)]

  // Blinky: starts outside ghost house, active immediately
  let blinky = new Ghost("blinky", "red", 13, 11, DIR_LEFT, MODE_SCATTER, 25, -3, false, 0, 0, true, false)

  // Pinky: starts in center of ghost house
  let pinky = new Ghost("pinky", "pink", 13, 14, DIR_UP, MODE_SCATTER, 2, -3, true, 0, 0, false, false)

  // Inky: starts left side of ghost house
  let inky = new Ghost("inky", "cyan", 11, 14, DIR_UP, MODE_SCATTER, 27, 32, true, 0, inkyLimit, false, false)

  // Clyde: starts right side of ghost house
  let clyde = new Ghost("clyde", "orange", 15, 14, DIR_UP, MODE_SCATTER, 0, 32, true, 0, clydeLimit, false, false)

  ghosts = [blinky, pinky, inky, clyde]
}

function initLevel() {
  initMap()
  initGhosts()

  pacX = 13
  pacY = 23
  pacDir = DIR_LEFT
  pacNextDir = DIR_LEFT

  dotsEaten = 0
  globalMode = MODE_SCATTER
  modeTimer = 0
  modePhase = 0
  frightTimer = 0
  inactivityTimer = 0
  activeGhostIndex = 1  // Pinky is first to exit
  useGlobalCounter = false
  globalDotCounter = 0

  fruitActive = false
  fruitTimer = 0

  ghostsEatenThisPower = 0
}

function resetAfterDeath() {
  pacX = 13
  pacY = 23
  pacDir = DIR_LEFT
  pacNextDir = DIR_LEFT

  // Reset ghost positions
  ghosts[0].tileX = 13
  ghosts[0].tileY = 11
  ghosts[0].isActive = true
  ghosts[0].isInHouse = false
  ghosts[0].direction = DIR_LEFT

  ghosts[1].tileX = 13
  ghosts[1].tileY = 14
  ghosts[1].isActive = false
  ghosts[1].isInHouse = true
  ghosts[1].dotCounter = 0

  ghosts[2].tileX = 11
  ghosts[2].tileY = 14
  ghosts[2].isActive = false
  ghosts[2].isInHouse = true
  ghosts[2].dotCounter = 0

  ghosts[3].tileX = 15
  ghosts[3].tileY = 14
  ghosts[3].isActive = false
  ghosts[3].isInHouse = true
  ghosts[3].dotCounter = 0

  globalMode = MODE_SCATTER
  modeTimer = 0
  modePhase = 0
  frightTimer = 0
  ghostsEatenThisPower = 0

  // Activate global counter after death
  useGlobalCounter = true
  globalDotCounter = 0
  activeGhostIndex = 1
}

// ============================================
// GHOST HOUSE LOGIC
// ============================================

function updateGhostHouse() {
  // Inactivity timer - force release if Pac-Man isn't eating
  let inactivityLimit = 240  // 4 seconds
  if (level >= 5) {
    inactivityLimit = 180  // 3 seconds
  }

  if (inactivityTimer > inactivityLimit) {
    // Force next ghost to exit
    let i = 0
    while (i < 4) {
      if (ghosts[i].isInHouse and not ghosts[i].isActive) {
        ghosts[i].exitHouse()
        inactivityTimer = 0
        i = 4  // break
      }
      i = i + 1
    }
  }

  // Check if any ghost in house should exit
  if (useGlobalCounter) {
    // Global counter mode (after death)
    if (globalDotCounter >= 7 and ghosts[1].isInHouse) {
      ghosts[1].exitHouse()
    }
    if (globalDotCounter >= 17 and ghosts[2].isInHouse) {
      ghosts[2].exitHouse()
    }
    // Global counter deactivates when Clyde reaches 32 and is still inside
    if (globalDotCounter >= 32 and ghosts[3].isInHouse) {
      useGlobalCounter = false
    }
  } else {
    // Personal counter mode
    let i = 1  // Start from Pinky (index 1)
    while (i < 4) {
      if (ghosts[i].isInHouse and not ghosts[i].isActive) {
        if (ghosts[i].dotCounter >= ghosts[i].dotLimit) {
          ghosts[i].exitHouse()
        }
      }
      i = i + 1
    }
  }
}

// ============================================
// MODE TIMING
// ============================================

function getScatterTime(phase) {
  let idx = getLevelIndex(level)
  if (phase equals 0) { return scatterTime1[idx] }
  if (phase equals 2) { return scatterTime2[idx] }
  if (phase equals 4) { return scatterTime3[idx] }
  return scatterTime4[idx]
}

function getChaseTime(phase) {
  let idx = getLevelIndex(level)
  if (phase equals 1) { return chaseTime1[idx] }
  if (phase equals 3) { return chaseTime2[idx] }
  return chaseTime3[idx]
}

function updateModeTimer() {
  if (frightTimer > 0) {
    // Frightened mode pauses the scatter/chase timer
    frightTimer = frightTimer - 1

    // Flash warning near the end
    let idx = getSpeedIndex(level)
    let totalFright = frightDuration[idx]
    if (totalFright > 0) {
      let flashStart = totalFright / 3
      if (frightTimer < flashStart) {
        frightFlash = (frightTimer / 8) % 2 equals 0
      } else {
        frightFlash = false
      }
    }

    if (frightTimer <= 0) {
      // End frightened mode - no reversal
      frightTimer = 0
      frightFlash = false
      ghostsEatenThisPower = 0
    }
    return
  }

  modeTimer = modeTimer + 1

  // Determine current mode duration
  let modeDuration = 0
  if (modePhase % 2 equals 0) {
    // Scatter phase
    modeDuration = getScatterTime(modePhase)
    if (globalMode not equals MODE_SCATTER) {
      globalMode = MODE_SCATTER
    }
  } else {
    // Chase phase
    modeDuration = getChaseTime(modePhase)
    if (globalMode not equals MODE_CHASE) {
      globalMode = MODE_CHASE
    }
  }

  // Check for phase transition
  if (modeTimer >= modeDuration and modePhase < 7) {
    modeTimer = 0
    modePhase = modePhase + 1

    // Reverse all active ghosts on mode change
    let i = 0
    while (i < 4) {
      if (ghosts[i].isActive and not ghosts[i].isEyes and frightTimer <= 0) {
        ghosts[i].reverse()
      }
      i = i + 1
    }
  }
}

// ============================================
// INPUT HANDLING
// ============================================

function handleInput() {
  if (pressed("up")) {
    pacNextDir = DIR_UP
  }
  if (pressed("down")) {
    pacNextDir = DIR_DOWN
  }
  if (pressed("left")) {
    pacNextDir = DIR_LEFT
  }
  if (pressed("right")) {
    pacNextDir = DIR_RIGHT
  }
}

// ============================================
// PAC-MAN MOVEMENT
// ============================================

function movePacman() {
  // Try to change to desired direction
  let nextX = pacX + dirDX[pacNextDir]
  let nextY = pacY + dirDY[pacNextDir]

  if (isWalkable(nextX, nextY)) {
    pacDir = pacNextDir
  }

  // Move in current direction
  let moveX = pacX + dirDX[pacDir]
  let moveY = pacY + dirDY[pacDir]

  if (isWalkable(moveX, moveY)) {
    pacX = moveX
    pacY = moveY
  }

  // Tunnel wrap
  if (pacX < 0) { pacX = COLS - 1 }
  if (pacX >= COLS) { pacX = 0 }

  // Animate mouth
  mouthOpen = not mouthOpen
}

// ============================================
// DOT EATING
// ============================================

function eatDots() {
  let cell = getCell(pacX, pacY)

  if (cell equals 2) {
    // Small dot
    setCell(pacX, pacY, 0)
    score = score + 10
    dotsEaten = dotsEaten + 1
    inactivityTimer = 0

    // Play chomp sound (alternating to create waka-waka effect)
    chompCounter = chompCounter + 1
    if (chompCounter % 2 equals 0) {
      sound.play("chomp")
    }

    // Update dot counters
    if (useGlobalCounter) {
      globalDotCounter = globalDotCounter + 1
    } else {
      // Find active ghost in house and increment their counter
      let i = 1
      while (i < 4) {
        if (ghosts[i].isInHouse and not ghosts[i].isActive) {
          ghosts[i].dotCounter = ghosts[i].dotCounter + 1
          i = 4  // break
        }
        i = i + 1
      }
    }

    // Check for fruit spawn
    if (dotsEaten equals 70 or dotsEaten equals 170) {
      fruitActive = true
      fruitTimer = 600  // ~10 seconds
    }

  } else if (cell equals 3) {
    // Power pellet / Energizer
    setCell(pacX, pacY, 0)
    score = score + 50
    dotsEaten = dotsEaten + 1
    inactivityTimer = 0

    // Play power pellet sound and stop siren
    sound.play("eatpill")
    sound.stop("siren")
    sirenPlaying = false

    // Activate frightened mode
    let idx = getSpeedIndex(level)
    frightTimer = frightDuration[idx]
    ghostsEatenThisPower = 0
    frightFlash = false

    // Reverse all active ghosts
    let i = 0
    while (i < 4) {
      if (ghosts[i].isActive and not ghosts[i].isEyes) {
        ghosts[i].reverse()
      }
      i = i + 1
    }
  }

  // Extra life at 10,000 points
  let prevScore = score - 10
  if (cell equals 3) {
    prevScore = score - 50
  }
  if (score >= 10000 and prevScore < 10000) {
    lives = lives + 1
    sound.play("extralive")
  }
}

// ============================================
// FRUIT LOGIC
// ============================================

function updateFruit() {
  if (fruitActive) {
    fruitTimer = fruitTimer - 1
    if (fruitTimer <= 0) {
      fruitActive = false
    }

    // Check if Pac-Man eats fruit
    if (pacX equals fruitX and pacY equals fruitY) {
      let fruitIdx = level - 1
      if (fruitIdx > 12) { fruitIdx = 12 }
      let points = fruitPoints[fruitIdx]
      score = score + points
      fruitActive = false

      // Show score popup
      scorePopup = points
      scorePopupX = fruitX
      scorePopupY = fruitY
      scorePopupTimer = 60
    }
  }
}

// ============================================
// GHOST AI
// ============================================

function updateGhosts() {
  // Get Blinky position for Inky's targeting
  let blinkyX = ghosts[0].tileX
  let blinkyY = ghosts[0].tileY

  let i = 0
  while (i < 4) {
    let ghost = ghosts[i]

    if (ghost.isActive or ghost.isEyes) {
      // Determine target based on mode
      let targetX = ghost.scatterTargetX
      let targetY = ghost.scatterTargetY

      if (ghost.isEyes) {
        // Eyes return to ghost house entrance
        targetX = 13
        targetY = 14

        // Use pathfinding to get back
        ghost.direction = ghost.chooseBestDirection(targetX, targetY, MODE_EYES, MODE_EYES)
        ghost.move()

        // Check if reached house center
        if (ghost.tileX equals 13 and (ghost.tileY equals 14 or ghost.tileY equals 13)) {
          ghost.isEyes = false
          ghost.isInHouse = true
          ghost.isActive = false
          ghost.tileY = 14
          ghost.dotCounter = 0
        }
      } else if (frightTimer > 0) {
        // Frightened: pseudo-random movement
        let randDir = random(0, 3)
        let validDir = ghost.direction
        let tries = 0
        while (tries < 4) {
          let testDir = (randDir + tries) % 4
          let testX = ghost.tileX + dirDX[testDir]
          let testY = ghost.tileY + dirDY[testDir]
          if (isWalkableForGhost(testX, testY) and testDir not equals oppositeDir(ghost.direction)) {
            validDir = testDir
            tries = 4  // break
          } else {
            tries = tries + 1
          }
        }
        ghost.direction = validDir
        ghost.move()
      } else if (globalMode equals MODE_CHASE) {
        // Chase mode: use ghost's personality
        let target = ghost.getChaseTarget(pacX, pacY, pacDir, blinkyX, blinkyY)
        targetX = target[0]
        targetY = target[1]
        ghost.direction = ghost.chooseBestDirection(targetX, targetY, globalMode, globalMode)
        ghost.move()
      } else {
        // Scatter mode: go to corner
        targetX = ghost.scatterTargetX
        targetY = ghost.scatterTargetY

        // Cruise Elroy: Blinky targets Pac-Man even in scatter
        if (ghost.name equals "blinky") {
          let dotsLeft = countDotsRemaining()
          let idx = getSpeedIndex(level)
          if (dotsLeft <= elroy1Dots[idx]) {
            targetX = pacX
            targetY = pacY
          }
        }

        ghost.direction = ghost.chooseBestDirection(targetX, targetY, globalMode, globalMode)
        ghost.move()
      }
    }

    i = i + 1
  }
}

// ============================================
// COLLISION DETECTION
// ============================================

function checkCollisions() {
  let i = 0
  while (i < 4) {
    let ghost = ghosts[i]

    if (ghost.isActive and not ghost.isEyes) {
      if (pacX equals ghost.tileX and pacY equals ghost.tileY) {
        if (frightTimer > 0) {
          // Eat ghost!
          ghost.becomeEyes()
          sound.play("eatghost")

          let points = ghostPoints[ghostsEatenThisPower]
          score = score + points
          ghostsEatenThisPower = ghostsEatenThisPower + 1
          if (ghostsEatenThisPower > 3) {
            ghostsEatenThisPower = 3
          }

          // Show score popup
          scorePopup = points
          scorePopupX = ghost.tileX
          scorePopupY = ghost.tileY
          scorePopupTimer = 30
        } else {
          // Pac-Man dies!
          sound.stop("siren")
          sirenPlaying = false
          return true
        }
      }
    }

    i = i + 1
  }

  return false
}

// ============================================
// DRAWING FUNCTIONS
// ============================================

function drawMap() {
  let y = 0
  while (y < ROWS) {
    let x = 0
    while (x < COLS) {
      let cell = getCell(x, y)
      let px = x * CELL_SIZE
      let py = y * CELL_SIZE

      if (cell equals 1) {
        // Wall
        color("blue")
        fill()
        rect(px, py, CELL_SIZE - 1, CELL_SIZE - 1)
      } else if (cell equals 2) {
        // Small dot
        color("white")
        fill()
        circle(px + 6, py + 6, 1)
      } else if (cell equals 3) {
        // Power pellet (flashing)
        if ((modeTimer / 10) % 2 equals 0) {
          color("white")
          fill()
          circle(px + 6, py + 6, 3)
        }
      } else if (cell equals 5) {
        // Ghost door
        color("pink")
        fill()
        rect(px, py + 4, CELL_SIZE, 2)
      }

      x = x + 1
    }
    y = y + 1
  }
}

function drawPacman() {
  color("yellow")
  fill()
  let px = pacX * CELL_SIZE + 6
  let py = pacY * CELL_SIZE + 6
  circle(px, py, 5)

  // Draw mouth
  if (mouthOpen) {
    color("black")
    fill()
    if (pacDir equals DIR_RIGHT) {
      triangle(px, py, px + 6, py - 3, px + 6, py + 3)
    } else if (pacDir equals DIR_LEFT) {
      triangle(px, py, px - 6, py - 3, px - 6, py + 3)
    } else if (pacDir equals DIR_DOWN) {
      triangle(px, py, px - 3, py + 6, px + 3, py + 6)
    } else if (pacDir equals DIR_UP) {
      triangle(px, py, px - 3, py - 6, px + 3, py - 6)
    } else {
      triangle(px, py, px + 6, py - 3, px + 6, py + 3)
    }
  }
}

function drawGhost(ghost) {
  let px = ghost.tileX * CELL_SIZE + 6
  let py = ghost.tileY * CELL_SIZE + 6

  // Determine color
  let ghostColor = ghost.colorName

  if (ghost.isEyes) {
    // Just draw eyes
    color("white")
    fill()
    circle(px - 2, py - 2, 2)
    circle(px + 2, py - 2, 2)
    color("blue")
    fill()
    // Pupil direction
    let pupilDX = dirDX[ghost.direction]
    let pupilDY = dirDY[ghost.direction]
    circle(px - 2 + pupilDX, py - 2 + pupilDY, 1)
    circle(px + 2 + pupilDX, py - 2 + pupilDY, 1)
    return
  }

  if (frightTimer > 0 and not ghost.isEyes) {
    if (frightFlash) {
      ghostColor = "white"
    } else {
      ghostColor = "darkblue"
    }
  }

  // Body
  color(ghostColor)
  fill()
  circle(px, py - 1, 5)
  rect(px - 5, py - 1, 10, 6)

  // Wavy bottom
  triangle(px - 5, py + 5, px - 3, py + 5, px - 4, py + 3)
  triangle(px - 1, py + 5, px + 1, py + 5, px, py + 3)
  triangle(px + 3, py + 5, px + 5, py + 5, px + 4, py + 3)

  // Eyes
  if (frightTimer > 0) {
    // Frightened eyes (simple)
    color("white")
    fill()
    circle(px - 2, py - 2, 1)
    circle(px + 2, py - 2, 1)
  } else {
    // Normal eyes with pupils
    color("white")
    fill()
    circle(px - 2, py - 2, 2)
    circle(px + 2, py - 2, 2)
    color("blue")
    fill()
    let pupilDX = dirDX[ghost.direction]
    let pupilDY = dirDY[ghost.direction]
    circle(px - 2 + pupilDX, py - 2 + pupilDY, 1)
    circle(px + 2 + pupilDX, py - 2 + pupilDY, 1)
  }
}

function drawGhosts() {
  let i = 0
  while (i < 4) {
    drawGhost(ghosts[i])
    i = i + 1
  }
}

function drawFruit() {
  if (fruitActive) {
    let px = fruitX * CELL_SIZE + 6
    let py = fruitY * CELL_SIZE + 6

    // Simple fruit representation based on level
    if (level equals 1) {
      // Cherry (red)
      color("red")
      fill()
      circle(px - 2, py + 2, 3)
      circle(px + 2, py + 2, 3)
      color("green")
      line(px - 2, py - 1, px, py - 4)
      line(px + 2, py - 1, px, py - 4)
    } else if (level equals 2) {
      // Strawberry
      color("red")
      fill()
      triangle(px, py + 4, px - 4, py - 2, px + 4, py - 2)
      color("green")
      fill()
      rect(px - 2, py - 4, 4, 2)
    } else if (level <= 4) {
      // Peach/Orange
      color("orange")
      fill()
      circle(px, py, 5)
    } else if (level <= 6) {
      // Apple
      color("red")
      fill()
      circle(px, py, 5)
      color("green")
      fill()
      rect(px - 1, py - 6, 2, 2)
    } else if (level <= 8) {
      // Grapes
      color("purple")
      fill()
      circle(px - 2, py - 1, 2)
      circle(px + 2, py - 1, 2)
      circle(px, py + 2, 2)
    } else if (level <= 10) {
      // Galaxian
      color("yellow")
      fill()
      triangle(px, py - 4, px - 4, py + 4, px + 4, py + 4)
    } else if (level <= 12) {
      // Bell
      color("yellow")
      fill()
      circle(px, py - 2, 4)
      rect(px - 4, py, 8, 4)
    } else {
      // Key
      color("cyan")
      fill()
      circle(px, py - 3, 3)
      rect(px - 1, py, 2, 6)
    }
  }
}

function drawHUD() {
  // Score
  color("white")
  text(5, 380, "SCORE: " + score)

  // Level
  text(120, 380, "LVL: " + level)

  // Lives
  text(200, 380, "LIVES: " + lives)

  // Score popup
  if (scorePopupTimer > 0) {
    color("cyan")
    let popX = scorePopupX * CELL_SIZE
    let popY = scorePopupY * CELL_SIZE
    text(popX, popY, "" + scorePopup)
    scorePopupTimer = scorePopupTimer - 1
  }
}

function drawReadyScreen() {
  clear()
  drawMap()
  drawPacman()
  drawGhosts()

  color("yellow")
  text(130, 200, "READY!")

  drawHUD()
}

function drawDeathAnimation() {
  clear()
  drawMap()

  // Simple death animation - Pac-Man shrinks
  let progress = stateTimer / 60
  if (progress > 1) { progress = 1 }

  color("yellow")
  fill()
  let px = pacX * CELL_SIZE + 6
  let py = pacY * CELL_SIZE + 6
  let radius = 5 * (1 - progress)
  if (radius > 0) {
    circle(px, py, radius)
  }

  drawHUD()
}

function drawLevelComplete() {
  clear()

  // Flash maze
  if ((stateTimer / 15) % 2 equals 0) {
    color("blue")
  } else {
    color("white")
  }

  let y = 0
  while (y < ROWS) {
    let x = 0
    while (x < COLS) {
      let cell = getCell(x, y)
      if (cell equals 1) {
        let px = x * CELL_SIZE
        let py = y * CELL_SIZE
        fill()
        rect(px, py, CELL_SIZE - 1, CELL_SIZE - 1)
      }
      x = x + 1
    }
    y = y + 1
  }

  drawPacman()
  drawHUD()
}

function drawGameOver() {
  clear()
  color("red")
  text(110, 180, "GAME OVER")
  color("white")
  text(100, 210, "Final Score: " + score)
  text(100, 240, "Level: " + level)
}

// ============================================
// GAME STATE MACHINE
// ============================================

function updateGame() {
  if (gameState equals STATE_READY) {
    // Play intro music at start of ready state
    if (stateTimer equals 0) {
      sound.stop("siren")
      sirenPlaying = false
      sound.play("intro")
    }

    stateTimer = stateTimer + 1
    if (stateTimer > 120) {  // 2 seconds
      gameState = STATE_PLAYING
      stateTimer = 0
    }
    drawReadyScreen()

  } else if (gameState equals STATE_PLAYING) {
    // Start siren if not playing and not in frightened mode
    if (not sirenPlaying and frightTimer <= 0) {
      sound.loop("siren")
      sirenPlaying = true
    }

    // Resume siren when frightened mode ends
    if (frightTimer equals 1 and sirenPlaying equals false) {
      sound.loop("siren")
      sirenPlaying = true
    }

    handleInput()
    movePacman()
    eatDots()
    updateFruit()
    updateModeTimer()
    updateGhostHouse()
    updateGhosts()
    inactivityTimer = inactivityTimer + 1

    // Check collisions
    if (checkCollisions()) {
      gameState = STATE_DEATH
      stateTimer = 0
      sound.play("die")
    }

    // Check win condition
    if (countDotsRemaining() equals 0) {
      gameState = STATE_LEVEL_COMPLETE
      stateTimer = 0
      sound.stop("siren")
      sirenPlaying = false
    }

    // Draw
    clear()
    drawMap()
    drawFruit()
    drawPacman()
    drawGhosts()
    drawHUD()

  } else if (gameState equals STATE_DEATH) {
    stateTimer = stateTimer + 1
    drawDeathAnimation()

    if (stateTimer > 90) {
      lives = lives - 1
      if (lives <= 0) {
        gameState = STATE_GAME_OVER
      } else {
        resetAfterDeath()
        gameState = STATE_READY
        stateTimer = 0
      }
    }

  } else if (gameState equals STATE_LEVEL_COMPLETE) {
    stateTimer = stateTimer + 1
    drawLevelComplete()

    // Play intermission music
    if (stateTimer equals 1) {
      sound.play("intermission")
    }

    if (stateTimer > 120) {
      level = level + 1
      initLevel()
      gameState = STATE_READY
      stateTimer = 0
    }

  } else if (gameState equals STATE_GAME_OVER) {
    drawGameOver()
  }
}

// ============================================
// MAIN GAME LOOP
// ============================================

initLevel()

looplimit(1000000)

while (gameState not equals STATE_GAME_OVER) {
  updateGame()
  sleep(17)  // ~60 FPS
}

// Final game over screen
drawGameOver()
