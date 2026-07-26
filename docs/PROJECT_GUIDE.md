# Capture the Flag

## Basic Rules

## Objective

Each player competes individually. The goal is to:

1. Enter the central circle.
2. Take the flag.
3. Leave the circle completely while still carrying the flag.

The first player to achieve this wins the match.

---

## Match Start

- A single flag is located exactly at the center of the map.
- All players spawn at random positions outside the circle.
- No player starts with the flag.
- The match begins when the server sends the start signal.

---

## Movement

Players can move freely across the map using the controls configured on the keyboard.

Some concepts that may be sent or received from players (usually more):

- Name
- Position
- Direction
- Player state
- Collision / Interaction / Action

---

# Flag Capture

When a player is close enough to the flag, they can press the interaction key (for example **E**, although this can be entirely arbitrary depending on the project).

If the flag is free:

- It immediately becomes owned by that player.

From that moment on:

- The flag is no longer on the ground.
- The flag follows the player.

---

## Flag Theft

If a player owns the flag, any other player can steal it from them.

### Conditions

- Must be close enough to the carrier.
- Must press the interaction key.

If both conditions are met:

- The flag immediately changes owner.

### Rules

- No waiting period.
- No immunity.
- The theft is instantaneous.
- If multiple players are nearby, only the first one is validated; the others must press the key again to steal from the new carrier.

---

# Victory Condition

A player wins when:

1. They have the flag.
2. They completely cross the circle boundary to the outside.

Touching the edge is not enough.

They must be entirely outside the central playing area.

When this happens:

- The server announces the winner.
- The match ends for all players.

---

# Project Implementation

- This project will be developed individually.
- The project may be developed in any programming language.
- The project may use any library the language allows, as well as sockets.
- The graphical interface may be developed with whichever technology the student prefers, as long as it meets the basic requirements of Capture the Flag.
- The project must behave as a server or client for another game.
- It must support **N** connected users (limit of **100**).
- Any artificial intelligence may be used to support learning the programming language or a specific implementation.

---

## Implementation Limitations

- No more than **4 projects** may be developed in the same programming language.
- No more than **2 projects** may use the same connection or graphics library. The exception is using basic sockets.
- When the project is configured as a **server**, it must only display the game of all players. Only when configured as a **client** connected to a server will it be possible to play from that machine.

---

## Recommendations

- Use **Broadcast** for general communication, allowing discovery of available servers, starting new matches, and running a **Countdown** to confirm the game start.
- All validations to determine a winner must run on the **server**. Clients only react to events or flags sent by the server to update the game state.
- All players must see the movement of all other players on all connected clients, not only on the server.

---

# Deliverable

- Functional game.
- Server with:
  - Multiplayer support.
  - Player visualization.
  - Game validation.
- Client with:
  - Automatic server discovery.
  - Ability to join matches that have not yet started.
  - State validation.
  - Visualization of all connected players.

## Graphical Environment

May be implemented as:

- Web
- 3D
- 2D
- ASCII
- Etc.

---

## Connection Support

- Must support multiple connections.
- Must be able to support up to **100 connections**.
- The actual limit will depend on the number of projects submitted.
- All projects must be able to connect to each other. It is not possible for only some projects to be compatible. If only a minority manages to communicate correctly, those projects will receive a grade of **zero**.
- In this assignment there are no groups; the group is the entire class.
