// Pacman
// Arrow keys to move, eat all dots!

// Grid settings
let cellSize = 12
let cols = 28
let rows = 31

// Map: 0=empty, 1=wall, 2=dot, 3=power
let map = []

// Classic maze layout
let layout = "1111111111111111111111111111"
layout = layout + "1222222222222112222222222221"
layout = layout + "1211112111112112111112111121"
layout = layout + "1311112111112112111112111131"
layout = layout + "1211112111112112111112111121"
layout = layout + "1222222222222222222222222221"
layout = layout + "1211112112111111112112111121"
layout = layout + "1222222112222112222112222221"
layout = layout + "1111112111110110111112111111"
layout = layout + "0000012111110110111112100000"
layout = layout + "1111112110000000000112111111"
layout = layout + "0000012110111001110112100000"
layout = layout + "0000002000100000010002000000"
layout = layout + "1111112110111111110112111111"
layout = layout + "0000012110000000000112100000"
layout = layout + "1111112110111111110112111111"
layout = layout + "1222222222222112222222222221"
layout = layout + "1211112111112112111112111121"
layout = layout + "1322112222222002222222112231"
layout = layout + "1112112112111111112112112111"
layout = layout + "1222222112222112222112222221"
layout = layout + "1211111111112112111111111121"
layout = layout + "1222222222222222222222222221"
layout = layout + "1211112111112112111112111121"
layout = layout + "1211112111112112111112111121"
layout = layout + "1322222222222222222222222231"
layout = layout + "1211112111112112111112111121"
layout = layout + "1211112111112112111112111121"
layout = layout + "1222222222222112222222222221"
layout = layout + "1211112111112112111112111121"
layout = layout + "1111111111111111111111111111"

// Initialize map from layout
function initMap() {
  let i = 0
  while (i < cols * rows) {
    let c = layout[i]
    if (c equals "1") {
      map[i] = 1
    } else if (c equals "3") {
      map[i] = 3
    } else if (c equals "2") {
      map[i] = 2
    } else {
      map[i] = 0
    }
    i = i + 1
  }
}

// Get map cell
function getCell(x, y) {
  if (x < 0 or x >= cols or y < 0 or y >= rows) {
    return 1
  }
  return map[x + y * cols]
}

// Set map cell
function setCell(x, y, val) {
  map[x + y * cols] = val
}

// Pacman
let pacX = 14
let pacY = 23
let pacDX = 0
let pacDY = 0
let nextDX = 0
let nextDY = 0
let mouthOpen = true
let score = 0
let powerTime = 0

// 4 Ghosts - positions and directions
let g1X = 12
let g1Y = 14
let g1DX = 0 - 1
let g1DY = 0

let g2X = 13
let g2Y = 14
let g2DX = 0
let g2DY = 0 - 1

let g3X = 14
let g3Y = 14
let g3DX = 0
let g3DY = 0 - 1

let g4X = 15
let g4Y = 14
let g4DX = 1
let g4DY = 0

// Can move?
function canMove(x, y) {
  if (getCell(x, y) equals 1) {
    return false
  }
  return true
}

// Draw map
function drawMap() {
  let y = 0
  while (y < rows) {
    let x = 0
    while (x < cols) {
      let cell = getCell(x, y)
      let px = x * cellSize
      let py = y * cellSize
      if (cell equals 1) {
        color("blue")
        rect(px, py, cellSize - 1, cellSize - 1)
      } else if (cell equals 2) {
        color("white")
        circle(px + 6, py + 6, 1)
      } else if (cell equals 3) {
        color("white")
        circle(px + 6, py + 6, 3)
      }
      x = x + 1
    }
    y = y + 1
  }
}

// Draw pacman
function drawPacman() {
  color("yellow")
  fill()
  let px = pacX * cellSize + 6
  let py = pacY * cellSize + 6
  circle(px, py, 5)

  if (mouthOpen) {
    color("black")
    fill()
    if (pacDX equals 1) {
      triangle(px, py, px + 6, py - 3, px + 6, py + 3)
    } else if (pacDX equals 0 - 1) {
      triangle(px, py, px - 6, py - 3, px - 6, py + 3)
    } else if (pacDY equals 1) {
      triangle(px, py, px - 3, py + 6, px + 3, py + 6)
    } else if (pacDY equals 0 - 1) {
      triangle(px, py, px - 3, py - 6, px + 3, py - 6)
    } else {
      triangle(px, py, px + 6, py - 3, px + 6, py + 3)
    }
  }
}

// Draw a ghost at position with color
function drawGhostAt(gx, gy, c) {
  let px = gx * cellSize + 6
  let py = gy * cellSize + 6

  if (powerTime > 0) {
    color("darkblue")
  } else {
    color(c)
  }

  fill()
  circle(px, py - 1, 5)
  rect(px - 5, py - 1, 10, 6)

  color("white")
  fill()
  circle(px - 2, py - 2, 2)
  circle(px + 2, py - 2, 2)
}

// Draw all ghosts
function drawGhosts() {
  drawGhostAt(g1X, g1Y, "red")
  drawGhostAt(g2X, g2Y, "cyan")
  drawGhostAt(g3X, g3Y, "pink")
  drawGhostAt(g4X, g4Y, "orange")
}

// Move a single ghost toward target
function moveGhostToward(gx, gy, gdx, gdy, targetX, targetY) {
  let bestDX = gdx
  let bestDY = gdy

  // Try to move toward target
  if (targetX > gx and canMove(gx + 1, gy)) {
    bestDX = 1
    bestDY = 0
  } else if (targetX < gx and canMove(gx - 1, gy)) {
    bestDX = 0 - 1
    bestDY = 0
  } else if (targetY > gy and canMove(gx, gy + 1)) {
    bestDX = 0
    bestDY = 1
  } else if (targetY < gy and canMove(gx, gy - 1)) {
    bestDX = 0
    bestDY = 0 - 1
  } else if (canMove(gx + gdx, gy + gdy)) {
    bestDX = gdx
    bestDY = gdy
  } else if (canMove(gx + 1, gy)) {
    bestDX = 1
    bestDY = 0
  } else if (canMove(gx - 1, gy)) {
    bestDX = 0 - 1
    bestDY = 0
  } else if (canMove(gx, gy + 1)) {
    bestDX = 0
    bestDY = 1
  } else if (canMove(gx, gy - 1)) {
    bestDX = 0
    bestDY = 0 - 1
  }

  return [bestDX, bestDY]
}

// Move all ghosts
function moveGhosts() {
  let targetX = pacX
  let targetY = pacY

  // Ghost 1 - chases pacman
  let result = moveGhostToward(g1X, g1Y, g1DX, g1DY, targetX, targetY)
  g1DX = result[0]
  g1DY = result[1]
  g1X = g1X + g1DX
  g1Y = g1Y + g1DY
  if (g1X < 0) { g1X = cols - 1 }
  if (g1X >= cols) { g1X = 0 }

  // Ghost 2 - aims ahead of pacman
  result = moveGhostToward(g2X, g2Y, g2DX, g2DY, targetX + pacDX * 4, targetY + pacDY * 4)
  g2DX = result[0]
  g2DY = result[1]
  g2X = g2X + g2DX
  g2Y = g2Y + g2DY
  if (g2X < 0) { g2X = cols - 1 }
  if (g2X >= cols) { g2X = 0 }

  // Ghost 3 - random-ish
  result = moveGhostToward(g3X, g3Y, g3DX, g3DY, 14, 14)
  g3DX = result[0]
  g3DY = result[1]
  g3X = g3X + g3DX
  g3Y = g3Y + g3DY
  if (g3X < 0) { g3X = cols - 1 }
  if (g3X >= cols) { g3X = 0 }

  // Ghost 4 - chases pacman
  result = moveGhostToward(g4X, g4Y, g4DX, g4DY, targetX, targetY)
  g4DX = result[0]
  g4DY = result[1]
  g4X = g4X + g4DX
  g4Y = g4Y + g4DY
  if (g4X < 0) { g4X = cols - 1 }
  if (g4X >= cols) { g4X = 0 }
}

// Check collision with any ghost
function checkGhostCollision() {
  if (pacX equals g1X and pacY equals g1Y) { return 1 }
  if (pacX equals g2X and pacY equals g2Y) { return 2 }
  if (pacX equals g3X and pacY equals g3Y) { return 3 }
  if (pacX equals g4X and pacY equals g4Y) { return 4 }
  return 0
}

// Reset ghost to center
function resetGhost(n) {
  if (n equals 1) { g1X = 12 g1Y = 14 }
  if (n equals 2) { g2X = 13 g2Y = 14 }
  if (n equals 3) { g3X = 14 g3Y = 14 }
  if (n equals 4) { g4X = 15 g4Y = 14 }
}

// Count dots
function countDots() {
  let count = 0
  let i = 0
  while (i < cols * rows) {
    if (map[i] equals 2 or map[i] equals 3) {
      count = count + 1
    }
    i = i + 1
  }
  return count
}

// Init
initMap()

// Game loop
let gameOver = false
let won = false

while (not gameOver) {
  // Input - check arrow keys
  if (pressed("up")) {
    nextDX = 0
    nextDY = 0 - 1
  }
  if (pressed("down")) {
    nextDX = 0
    nextDY = 1
  }
  if (pressed("left")) {
    nextDX = 0 - 1
    nextDY = 0
  }
  if (pressed("right")) {
    nextDX = 1
    nextDY = 0
  }

  // Try direction change
  if (canMove(pacX + nextDX, pacY + nextDY)) {
    pacDX = nextDX
    pacDY = nextDY
  }

  // Move pacman
  if (canMove(pacX + pacDX, pacY + pacDY)) {
    pacX = pacX + pacDX
    pacY = pacY + pacDY
  }

  // Tunnel wrap
  if (pacX < 0) { pacX = cols - 1 }
  if (pacX >= cols) { pacX = 0 }

  // Eat dots
  let cell = getCell(pacX, pacY)
  if (cell equals 2) {
    setCell(pacX, pacY, 0)
    score = score + 10
  } else if (cell equals 3) {
    setCell(pacX, pacY, 0)
    score = score + 50
    powerTime = 50
  }

  // Move ghosts
  moveGhosts()

  // Check collision
  let hit = checkGhostCollision()
  if (hit > 0) {
    if (powerTime > 0) {
      score = score + 200
      resetGhost(hit)
    } else {
      gameOver = true
    }
  }

  // Power timer
  if (powerTime > 0) {
    powerTime = powerTime - 1
  }

  // Win check
  if (countDots() equals 0) {
    gameOver = true
    won = true
  }

  // Animate mouth
  mouthOpen = not mouthOpen

  // Draw
  clear()
  drawMap()
  drawPacman()
  drawGhosts()

  // Score display
  color("white")
  text(5, 380, "Score: " + score)

  sleep(120)
}

// End screen
clear()
color("yellow")
if (won) {
  text(120, 180, "YOU WIN!")
} else {
  text(110, 180, "GAME OVER")
}
text(100, 210, "Score: " + score)