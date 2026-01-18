<h1>2-Player Pong (8086 Assembly)</h1>

<p>
A simple two-player Pong game written entirely in 8086 Assembly.
No libraries, no graphics engines — just interrupts, video memory, and raw keyboard input.
</p>

<p>
This project was created as a learning exercise to understand how games work at a very low level
using real-mode DOS and text-mode graphics.
</p>

<hr>

<h2>Game Overview</h2>

<p>
This is a classic local multiplayer Pong game where two players control paddles on opposite sides
of the screen. The ball bounces between paddles and walls, scores are tracked live, and the first
player to reach 5 points wins.
</p>

<p>
All rendering is done by directly writing to video memory at <code>0xB800</code>, and all movement
and input handling is controlled through hardware interrupts.
</p>

<hr>

<h2>Features</h2>

<ul>
  <li>Local two-player gameplay</li>
  <li>Smooth paddle movement using keyboard interrupts</li>
  <li>Ball movement controlled by timer interrupt</li>
  <li>PC speaker sound effects for hits and misses</li>
  <li>Live score display</li>
  <li>Game over screen with winner announcement</li>
  <li>Restart option after the game ends</li>
</ul>

<hr>

<h2>Controls</h2>

<h3>Player 1 (Left Paddle)</h3>
<ul>
  <li><strong>W</strong> – Move up</li>
  <li><strong>S</strong> – Move down</li>
</ul>

<h3>Player 2 (Right Paddle)</h3>
<ul>
  <li><strong>Up Arrow</strong> – Move up</li>
  <li><strong>Down Arrow</strong> – Move down</li>
</ul>

<h3>General Controls</h3>
<ul>
  <li><strong>Space Bar</strong> – Start the game</li>
  <li><strong>R</strong> – Restart after game over</li>
  <li><strong>Esc</strong> – Exit the game</li>
</ul>

<hr>

<h2>Technical Details</h2>

<ul>
  <li><strong>Language:</strong> 8086 Assembly</li>
  <li><strong>Execution Mode:</strong> Real Mode (DOS)</li>
  <li><strong>Graphics:</strong> Text mode using direct access to video memory (0xB800)</li>
  <li><strong>Keyboard Input:</strong> Custom INT 9 handler</li>
  <li><strong>Timing and Ball Movement:</strong> Timer interrupt (INT 8)</li>
  <li><strong>Sound:</strong> PC speaker via hardware I/O ports</li>
</ul>

<p>
Core concepts used include interrupt hooking and restoration, direct memory access,
simple collision detection, and a basic game loop with controlled screen redraws.
</p>

<hr>

<h2>Learning Objectives</h2>

<ul>
  <li>Understand keyboard and timer interrupts</li>
  <li>Practice real-time input handling</li>
  <li>Learn how rendering works without libraries</li>
  <li>Apply low-level logic to build a complete game</li>
</ul>

<hr>

<h2>Authors</h2>

<ul>
  <li><strong>Eman Fatima</strong> – 24L-3008</li>
  <li><strong>Fatima Kamran</strong> – 24L-3027</li>
</ul>

<hr>

<h2>Usage</h2>

<p>
You are free to explore, modify, and learn from this project. Possible improvements include
adjusting ball speed, changing paddle size, modifying the winning score, or adding an AI player.
</p>

<p>
This project is intended strictly for educational purposes.
</p>

<hr>

<h2>Final Notes</h2>

<p>
Building a real time game in pure assembly is challenging, but it provides strong insight into
how software interacts directly with hardware. This project demonstrates how a complete game
can be built using only interrupts, memory, and logic.
</p>
