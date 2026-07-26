# **CTF Protocol Standard - CC8 2026**

| Specification Data Sheet |                                                               |
| :----------------------- | :------------------------------------------------------------ |
| **Field**                | **Detail**                                                    |
| **Document version**     | 1.2.0                                                         |
| **Protocol version (v)** | 1                                                             |
| **Status**               | Active (Class agreement)                                      |
| **Last modified**        | 2026-07-25                                                    |
| **Change history**       | See section **7. Change Control** at the end of the document. |

## **ABSTRACT**

This document defines the standard protocol for the Capture The Flag (CTF) competition of the CC8 2026 class. It establishes the technical communication foundations, the JSON message format, and the game rules to guarantee interoperability among various software projects.

## **TERMINOLOGY**

The keywords in this specification are normative:

- **MUST / MUST NOT:** Absolute requirements for compatibility. Any project that does not comply with a **MUST** is incompatible with the rest of the class.
- **RECOMMENDED:** Suggested practices for stability.
- **Coalescence:** The server's ability to omit outdated states in favor of the most recent one for slow clients.

## **1. CONNECTION**

**Connection Diagram:**

```
Client (UDP:8888) --discover--> Local Network (Broadcast)
Server (UDP:Auto) <--server_info-- Client (Unicast)
Client (TCP:tcp_port) --join--> Server
```

### **1.1 Transport**

### **1.1 Transport**

Defines the technology responsible for moving bytes between participating machines and the delivery guarantees it offers. All class projects must agree on the same transport so that their connections are compatible with each other.
A hybrid scheme is established:

> - **TCP:** For all match communication (join, move, take flag, game state, end of match). Guarantees that messages arrive complete and in the order they were sent.
> - **UDP:** Exclusively for server discovery on the local network (covered in section 1.3).

Requirements for each project:

> - Use the basic sockets that the language already provides, without external connection libraries (for example: socket in Python, net in Go, TcpClient in C#, net in Node —never ws—, POSIX/Winsock in C++, StreamPeerTCP in Godot, dart:io in Dart).
> - In client mode, open a single TCP connection to the server and use it for all game message exchange.
> - In server mode, accept and maintain up to 100 simultaneous TCP client connections.
> - Additionally, maintain a separate UDP socket dedicated only to discovery.

### **1.2 Ports**

Establishes the port numbers on which servers listen, both for discovery and for the match. Separating both ports prevents server discovery from interfering with ongoing game traffic.
Two types of ports are defined:

> - **Discovery port (UDP):** Fixed and the same for all class projects: **8888**. Every server must listen there without exception.
> - **Game port (TCP):** Each server chooses it freely (for example, 8889) and it does not need to match across projects.

Requirements for each project:

> - The server must announce its TCP port inside the discovery response message, since the client does not know it beforehand.
> - The client first asks on the fixed UDP port (8888), reads the TCP port that the server indicates, and uses that port to open the game connection.
> - No project should hardcode someone else's TCP port: it is always obtained dynamically from the discovery response (or from the manual fallback `IP:port`, section 1.3).

### **1.3 Server Discovery**

Describes the procedure by which a client locates available servers on the local network without knowing their IP addresses beforehand. This mechanism depends on the UDP port defined in section 1.2.
Discovery follows two paths:

> 1. **Automatic (UDP broadcast):** The client sends a query to the entire network and each active server responds individually.
>    - The client does not know the server's IP, so it sends the request packet to **both** broadcast addresses: the limited one (**255.255.255.255:8888**) and its subnet broadcast (for example, **192.168.1.255:8888**, calculated from its own IP and mask). Many routers do not forward 255.255.255.255; sending to both maximizes the probability of discovery.
>    - The client's UDP socket MUST enable the `SO_BROADCAST` option before sending.
>    - This packet is sent to all devices connected to that local network.
>    - The server examines the source IP of the request packet (the client's IP) to know where to respond.
>    - The server sends a response packet directly to the client's IP.
>    - Upon receiving the response, the client checks the source IP of the packet (which is the server's real IP on the LAN) and displays it in the list.
> 2. **Manual (fallback):** The client allows typing the server's IP directly, for cases where broadcast does not work (router or WiFi that blocks it). In this mode, the client sends the same `discover` message via **unicast** to `IP:8888` (broadcast may be blocked, but UDP unicast works). As an additional fallback, the client MUST also accept the `IP:port` format to connect directly via TCP without going through discovery.

Requirements for each project:

> - The client must send via broadcast —to 255.255.255.255:8888 **and** to its subnet broadcast— a message of the type:
>   {"type": "discover", "v": 1}
> - The server must respond directly to the sender with:
>   {"type": "server_info", "v": 1, "name": "...", "tcp_port": 8889, "state": "lobby", "players": 3}
> - The `state` field of `server_info` only admits two values: `"lobby"` if the server accepts new players at this moment, and `"playing"` in any other case (countdown, match in progress, or results pause).
> - A `discover` with `v` different from 1 is silently discarded (no response). A UDP datagram that is not valid JSON is also silently discarded (there is no connection to which to return an `error`).
> - The server MUST open its UDP discovery socket with `SO_REUSEADDR` (and `SO_REUSEPORT` where the platform allows it), to tolerate fast restarts and local testing with more than one process on the same machine.
> - The client must display the list of servers found and allow the user to choose one.
> - The client must include, without exception, the option for manual connection by IP as a fallback to broadcast (see Manual path above).

## **2. THE LANGUAGE OF MESSAGES**

**Framing Diagram:**

```
[JSON Message 1]\n[JSON Message 2]\n[Part of JSON 3...]
```

### **2.1 Message delimitation (framing)**

Specifies the rule that makes it possible to identify where one message ends and where the next begins. This point is essential because TCP delivers data as a continuous stream of bytes, with no natural separation between messages: two messages may arrive stuck together in a single read, or a single one may arrive split across two different reads.
The following rule is defined:

> - **One message = one line:** Each message is a complete JSON text, followed by the newline character (\n).
> - The JSON of a message cannot contain internal line breaks: it must always be written "flattened" on a single line (no indentation or pretty formatting).
> - The newline (\n) is exclusively the separator between messages; it must never appear inside a field's content.

Mandatory procedure for reading messages:

> 1. Accumulate the bytes arriving through the socket in a buffer (a temporary container).
> 2. Every time a \n appears inside that buffer, cut there: everything accumulated BEFORE the \n is a complete message.
> 3. Convert that cut text into a JSON object (parse).
> 4. Whatever remains AFTER the \n is kept in the buffer, because it may be the beginning of the next message (or still incomplete).
> 5. Repeat as long as the connection remains open.

_Important clarification:_ This rule applies only to messages sent over TCP. Discovery messages, sent over UDP, are transmitted as complete packets in a single step and do not require the \n character nor the buffering process.

Additional framing rules:

> - The sender never includes the `\r` character (carriage return) in its messages. The receiver MAY tolerate a `\r` immediately before the `\n` (Windows line endings) and MUST discard it before parsing.
> - No message may exceed `message_max_size` (64 KB) including the trailing `\n`; the limit also applies to UDP datagrams. A TCP message that exceeds it is rejected with `MESSAGE_TOO_LARGE` and the connection is closed; a UDP datagram that exceeds it is silently discarded.

### **2.2 Format and encoding**

Defines the language in which messages are written and the character encoding used, so that all projects interpret the same information identically, regardless of the programming language they are written in.

> - **Format:** JSON. Every protocol message must be a valid JSON object, not free text or a format invented by each project.
> - **Encoding:** UTF-8. All text (player names, error reasons, etc.) must be encoded and decoded in UTF-8 at both ends of the connection.
> - **Mandatory identifier field:** Every message, without exception, must include a field called "type" as text (string), whose value identifies which message it is. No message may omit it. Example: {"type": "join", ...}.
> - **Numeric values:** Position and direction fields (x, y, dir) are represented as numbers, never as text (example: "x": -1, not "x": "-1").
> - **Flat structure:** Messages should not nest more than two levels deep (for example, config inside welcome is acceptable; a third level inside config is not), in order to keep parsing simple in all languages.
> - **Version:** The `v` field, where applicable (`discover`, `server_info`, `join`), MUST be exactly the integer `1`. No other message carries `v`.
> - **Unknown fields:** The receiver MUST silently ignore any field not documented in this standard (tolerant reading). This allows adding optional fields in the future without breaking other projects.
> - **Processing order (server):** The server processes incoming messages one at a time, in the order they arrive over TCP, and applies each one completely before evaluating the next. This arrival order is the official order of the match and the only tiebreaker rule (see section 5.3).

### **2.3 Message catalog**

#### **Catalog overview**

| Type        | Direction | Phase             | Purpose                           | Main fields                       |
| :---------- | :-------- | :---------------- | :-------------------------------- | :-------------------------------- |
| discover    | C → UDP   | Any               | Search for servers on the network | v                                 |
| server_info | S → UDP   | Any               | Advertise the found server        | v, name, tcp_port, state, players |
| join        | C → S     | Lobby             | Join the match                    | v, name                           |
| input       | C → S     | Playing           | Communicate movement direction    | dir (dir.x, dir.y)                |
| interact    | C → S     | Playing           | Take or steal the flag            | none                              |
| welcome     | S → C     | Lobby             | Assign identity and constants     | player_id, config                 |
| lobby       | S → C     | Lobby             | List of waiting players           | players                           |
| countdown   | S → C     | Countdown         | Show the countdown                | seconds                           |
| start       | S → C     | Countdown-Playing | Start the match                   | none                              |
| state       | S → C     | Playing           | Replicate the game world          | flag, players                     |
| game_over   | S → C     | Playing-Finished  | Announce the winner               | winner                            |
| error       | S → C     | Any               | Reject an invalid action          | reason                            |

#### **Field detail per message**

**1. Discovery messages (UDP):**

> - **discover** (Client → UDP Broadcast | Phase: any):
>   - v (integer): Protocol version the client speaks.
> - **server_info** (Server → UDP Unicast | Phase: any):
>   - v (integer): Protocol version the server speaks.
>   - name (text): Server name.
>   - tcp_port (integer): TCP port where the game listens.
>   - state (text): "lobby" if it accepts new players at this moment; "playing" in any other phase (countdown, match, or results pause).
>   - players (integer): Number of connected players.

**2. Client-to-server messages (TCP):**

> - **join** (Client → Server | Phase: lobby):
>   - v (integer): Protocol version the client speaks. MUST be exactly `1`; otherwise the server responds `VERSION_MISMATCH` and closes the connection.
>   - name (text): Player name. Rules: after trimming leading and trailing spaces (trim), length between 1 and `name_max_length` (20) UTF-8 characters, with no control characters or line breaks. Names **do not** need to be unique: `player_id` is what distinguishes players. If the name is invalid, the server responds `NAME_INVALID` (without closing) and the client may retry with another name.
> - A second `join` on the same connection is rejected with `INVALID_PHASE` (without closing the connection).
> - A `join` received when the server is in `countdown` or `playing` is rejected with `GAME_STARTED` and the connection is closed (see error table, section 5.1).
> - **input** (Client → Server | Phase: playing):
>   - dir.x (integer): -1 = left, 0 = still, 1 = right.
>   - dir.y (integer): -1 = up, 0 = still, 1 = down.
> - **interact** (Client → Server | Phase: playing):
>   - _No fields:_ Attempts to take the free flag or steal it from the carrier.

**Possible dir (x, y) combinations:**

> - (-1, -1): Up-Left
> - (0, -1): Up
> - (1, -1): Up-Right
> - (-1, 0): Left
> - (0, 0): Still
> - (1, 0): Right
> - (-1, 1): Down-Left
> - (0, 1): Down
> - (1, 1): Down-Right

**3. Server-to-client messages (TCP):**

> - **welcome** (Server → Client | Phase: lobby):
>   - player_id (text): Unique identifier the server assigns to the player.
>   - config.map_size (number): Side of the map in logical units.
>   - config.circle_radius (number): Radius of the central circle.
>   - config.player_radius (number): Radius of the player's body.
>   - config.interact_radius (number): Maximum distance to take or steal the flag.
>   - config.speed (number): Movement speed in units per second.
>   - config.tick_rate (integer): State sends per second.
> - **lobby** (Server → Client | Phase: lobby):
>   - players[].id (text): Identifier of each connected player.
>   - players[].name (text): Visible name of each connected player.
> - **When `lobby` is sent:** (a) to each client immediately after its `welcome`; (b) broadcast to all lobby clients upon every join or leave; (c) broadcast as a **return to lobby** signal when the countdown is aborted (section 5.2) or when the match ends (section 3.1). Receiving a `lobby` outside the lobby phase always means "the server returned to the lobby phase": the client abandons the current screen and displays the waiting room.
> - **countdown** (Server → Client | Phase: countdown):
>   - seconds (integer): Seconds remaining until start (5, 4, 3, 2, 1).
> - **Countdown timing:** The server sends exactly one `countdown` per second, with `seconds` = 5, 4, 3, 2, 1, and sends `start` immediately after the last one. The client MUST NOT send `input` or `interact` before receiving `start`; the server rejects those messages with `INVALID_PHASE`.
> - **start** (Server → Client | Phase: countdown → playing):
>   - _No fields:_ Marks the exact start of the match.
> - **state** (Server → Client | Phase: playing):
>   - flag.owner (text or null): ID of the carrier, or null if the flag is free. The free flag value is always `null` (never 0, never empty string).
>   - flag.x, flag.y (number): Current position of the flag. When `flag.owner` is not `null`, the server MUST transmit the carrier's position (`flag.x` = carrier's `x`, `flag.y` = carrier's `y`) on every send, so that all clients draw the flag attached to the carrier.
>   - players[].id (text): Player identifier.
>   - players[].x, players[].y (number): Current position of that player (1 decimal; half-away-from-zero rounding; clients should not compare positions by exact equality).
> - `players[]` includes **only** the players connected at that instant, including the client itself receiving the message. If an `id` present in one `state` disappears in the next, the client removes that avatar immediately (there is no leave message; see section 5.2).
> - `state` is a **coalescible** message: if a client falls behind, the server may discard pending sends and send only the most recent one. Other messages (`lobby`, `countdown`, `start`, `game_over`, `error`) are never discarded.
> - **game_over** (Server → Client | Phase: playing → finished):
>   - winner (text): ID of the player who won the match.
> - **After `game_over`:** The server keeps TCP connections open, waits `post_game_seconds` (5 seconds, so clients can display the victory screen), reverts its state to `lobby`, and broadcasts an updated `lobby` message. No one needs to reconnect to play another match (see full sequence in section 3.1).
> - **error** (Server → Client | Phase: any):
>   - reason (text): Code of the rejection reason, always in UPPERCASE_WITH_UNDERSCORES and taken from the catalog in section 5.1 (e.g., "GAME_STARTED", "LOBBY_FULL"). Clients must be able to display it to the user as-is.

#### **Agreed constants and limits**

| Category                    | Constant / Limit       | Value      | Meaning                                                                                           |
| :-------------------------- | :--------------------- | :--------- | :------------------------------------------------------------------------------------------------ |
| Constants in welcome.config | map_size               | 1000       | The map measures 1000 x 1000 logical units.                                                       |
|                             | circle_radius          | 300        | The central circle measures 300 units in radius.                                                  |
|                             | player_radius          | 15         | The player's body measures 15 units in radius.                                                    |
|                             | interact_radius        | 40         | Up to 40 units of distance to take or steal the flag.                                             |
|                             | speed                  | 200        | 200 units per second of movement speed.                                                           |
|                             | tick_rate              | 20         | 20 state sends per second.                                                                        |
| Server Constants            | countdown_seconds      | 5          | The countdown lasts 5 seconds before starting.                                                    |
|                             | min_players            | 2          | Minimum players to trigger and maintain the countdown.                                            |
|                             | post_game_seconds      | 5          | Pause after `game_over` before returning to lobby.                                                |
|                             | circle_center          | (500, 500) | Center of the map and of the circle (= `map_size` / 2).                                           |
|                             | spawn_radius_min / max | 350 / 450  | Spawn ring around the center (section 3.3).                                                       |
|                             | victory_distance       | 315        | `circle_radius` + `player_radius`; distance to center that must be exceeded to win (section 3.3). |
|                             | discovery_port (UDP)   | 8888       | Fixed discovery port, the same for the entire class.                                              |
| Protocol Limits             | max_players            | 100        | Maximum players per match (as per the assignment).                                                |
|                             | name_max_length        | 20         | Maximum player name length in characters.                                                         |
|                             | message_max_size       | 64 KB      | Maximum size of an individual message.                                                            |

**The `welcome.config` values are fixed constants, not configurable.** Every class server MUST announce exactly the values in the table (`map_size: 1000`, `circle_radius: 300`, `player_radius: 15`, `interact_radius: 40`, `speed: 200`, `tick_rate: 20`). They are sent inside `welcome` so that the client does not have to hardcode them and so that the message is self-descriptive, but no server may change them: if each server used different speeds, radii, or maps, the same player would move faster or win with different rules depending on who they connect to, and matches between projects would cease to be fair and comparable. They are kept in the message as living documentation of the contract, not as dynamic parameters.

## **3. GAME RULES**

**Lifecycle:**

```
Lobby -> Countdown (5s) -> Playing -> Game Over -> Pause (5s) -> Lobby
```

### **3.1 Match sequence**

> 1. Search for available servers (discovery).
> 2. Lobby / wait for match start.
> 3. Countdown.
> 4. Match start:
>    - Initial player placement (random spawn, outside the circle).
>    - Free player movement.
> 5. Events during the match (occur at any time and any number of times):
>    - Flag capture.
>    - Flag theft.
>    - Exiting the circle with the flag (victory condition).
> 6. End of match / show winner (`game_over`).
> 7. Post-match transition: the server waits `post_game_seconds` (5 s) with TCP connections open, reverts its state to `lobby`, and broadcasts an updated `lobby` message. Clients return to the waiting room without reconnecting and the cycle may repeat from step 2.

### **3.2 Coordinate system**

> - Origin (0,0) located at the top-left corner.
> - The X axis increases to the right.
> - The Y axis increases downward (negative Y is up, positive Y is down).
> - The center of the map and the circle is always (500, 500) (= `map_size` / 2).
> - All distances are calculated using the standard Euclidean distance: `dist(a, b) = √((a.x − b.x)² + (a.y − b.y)²)`.

### **3.3 Domain rules (normative)**

> - **Initial spawn:** Upon sending `start`, the server assigns each player a uniform random position in the ring outside the circle: generates an angle θ ∈ [0, 2π) and a radius R ∈ [350, 450], and computes `x = 500 + R·cos(θ)`, `y = 500 + R·sin(θ)`. This guarantees fair spawns and always outside the circle (the minimum radius 350 is greater than the victory distance 315). Two players may spawn overlapping: **there is no collision between player bodies**; the only interaction between players is theft via `interact`.
> - **Free flag:** At the start of the match, and every time the carrier disconnects, the flag rests at the center: `flag.owner = null`, `flag.x = 500`, `flag.y = 500`.
> - **Capture:** An `interact` from a player at distance ≤ `interact_radius` (40) from the free flag makes them the carrier.
> - **Theft:** Distance is the **only** requirement. Any player at distance ≤ 40 from the carrier may steal the flag with `interact`, regardless of whether either is inside or outside the circle. No waiting period or immunity: theft is instantaneous.
> - **Carried flag:** While there is a carrier, the flag is transmitted at the carrier's exact position (`flag.x`/`flag.y` = player position).
> - **Victory (with mandatory transition):** A player wins when, being the carrier, they go from being **inside or on the edge** of the circle (distance to center ≤ 315) to being **completely outside** (distance to center > 315, where 315 = `circle_radius` + `player_radius`). The server's state machine records, at the moment of each capture or theft, whether the new carrier is inside or outside; whoever steals while already outside does NOT win instantly: they must first re-enter the circle (distance ≤ 315) and exit completely again while keeping the flag. Touching the edge is not enough: distance strictly greater than 315 is required.
> - **Map boundaries:** Each player's position is clamped to the range [15, 985] on both axes (= `player_radius` and `map_size` − `player_radius`).
> - **Movement:** The server integrates the last `dir` received from each player at `speed` (200) units per second in its own simulation step; diagonals are normalized (÷ √2) so that speed is identical in all 8 directions.

## **4. AUTHORITY AND SYNCHRONIZATION**

### **4.1 Authority and validations**

| Action                | What the client sends                | What the server validates                                                                                                                                                                | Result                                            |
| :-------------------- | :----------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------ |
| **Movement**          | Direction dir.x and dir.y            | That the values are -1, 0, 1; that the match is active and the player connected.                                                                                                         | Calculates the new position.                      |
| **Diagonal movement** | Direction on both axes               | Normalizes the direction to avoid higher speed.                                                                                                                                          | Maintains the same speed in all directions.       |
| **Map boundaries**    | Does not send additional information | Checks that the position remains between 15 and 985 on both axes.                                                                                                                        | Clamps the position if it tries to leave the map. |
| **Flag capture**      | interact message                     | That the flag is free and that the distance to the flag is less than or equal to 40.                                                                                                     | Assigns the flag to the player.                   |
| **Flag theft**        | interact message                     | That another player owns the flag and that the distance to the carrier is less than or equal to 40. This is the only requirement: it applies inside or outside the circle (section 3.3). | Changes the flag owner.                           |
| **Victory condition** | Does not send a special message      | That the carrier has gone from distance ≤ 315 to distance > 315 from the center while keeping the flag (section 3.3).                                                                    | Ends the match and declares the winner.           |
| **Message received**  | JSON message                         | That it has type, the required fields, and the correct data types.                                                                                                                       | Processes the message or responds with an error.  |
| **Match phase**       | Corresponding action                 | That the action is allowed in the current phase.                                                                                                                                         | Accepts or rejects the action.                    |

Server implementation notes:

> - **`input` cadence:** The client sends `input` every time its direction changes (including `(0,0)` when releasing keys). It is not mandatory to resend it periodically; the server retains and applies the last direction received until another arrives.
> - **Evaluation within the tick:** In each tick, the server applies movement and the victory condition first, and then processes pending interactions. A carrier who crosses the boundary in that tick wins before any pending theft is evaluated.
> - **Official order:** Messages are processed one at a time in TCP arrival order; this is the only tiebreaker criterion (section 5.3).

### **4.2 State synchronization**

| Aspect                             | Decision                                                                                    |
| :--------------------------------- | :------------------------------------------------------------------------------------------ |
| **Main authority**                 | The server                                                                                  |
| **Official positions**             | Calculated by the server                                                                    |
| **Information sent by the client** | Movement and interaction intentions                                                         |
| **Capture, theft, and victory**    | Validated by the server                                                                     |
| **Boundaries and speed**           | Controlled by the server                                                                    |
| **Client's role**                  | Send actions and display the received state                                                 |
| **`state` messages**               | Coalescible: for a slow client, pending ones are discarded and only the most recent is sent |
| **Other messages**                 | Never discarded or reordered                                                                |

## **5. FAILURE AND DISCONNECTION HANDLING**

### **5.1 Error handling**

General rule: When the server receives an incorrect message, it must:

> 1. Detect the problem.
> 2. Not modify the game state.
> 3. Respond with an error message.
> 4. Keep or close the connection depending on severity.

#### **Common error table**

The `reason` field of the `error` message MUST be exactly one of these codes (in UPPERCASE_WITH_UNDERSCORES). New codes are not invented without updating this standard.

| Code / Error      | When it occurs                                                   | Is the connection closed?        |
| :---------------- | :--------------------------------------------------------------- | :------------------------------- |
| INVALID_JSON      | The received text is not valid JSON.                             | No, unless it occurs repeatedly. |
| UNKNOWN_TYPE      | The type field contains an unknown message.                      | No.                              |
| MISSING_FIELD     | A required field is missing.                                     | No.                              |
| INVALID_FIELD     | A field has an incorrect value or type.                          | No.                              |
| INVALID_PHASE     | The action is not allowed in the current phase.                  | No.                              |
| VERSION_MISMATCH  | Client and server use incompatible versions.                     | Yes.                             |
| LOBBY_FULL        | The server reached the maximum number of players.                | Yes.                             |
| NAME_INVALID      | The name is empty, too long, or not valid.                       | No.                              |
| GAME_STARTED      | A join was received while the server is in countdown or playing. | Yes, after sending the error.    |
| MESSAGE_TOO_LARGE | The message exceeds the maximum allowed size.                    | Yes.                             |
| NOT_JOINED        | The client tries to play before sending join.                    | No.                              |

### **5.2 Disconnections**

| Situation                             | Server action                                                                                                                                                                | Flag state                                    |
| :------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------- |
| **Disconnection in lobby**            | Remove player and update lobby.                                                                                                                                              | Unchanged.                                    |
| **Disconnection in countdown**        | Remove player and check `min_players` (2): if fewer than 2 players remain, the countdown is immediately aborted and a `lobby` message is broadcast (return to waiting room). | Unchanged.                                    |
| **Disconnection during the game**     | Remove player and continue match.                                                                                                                                            | Unchanged if they did not have it.            |
| **Carrier disconnection**             | Remove player.                                                                                                                                                               | Returns to (500,500).                         |
| **Everyone disconnects**              | Restart the match and return to lobby.                                                                                                                                       | Returns to (500,500).                         |
| **Disconnection in post-match pause** | Remove player; the return `lobby` is sent with the already updated list.                                                                                                     | Returns to (500,500) when the cycle restarts. |
| **Server disconnects**                | Clients stop the match.                                                                                                                                                      | No official state exists.                     |

#### **Special disconnection cases**

> - **Explicit TCP close:** Remove session. In `playing`, the player is immediately removed from `state`.
> - **No timeout in v1:** Protocol version 1 does NOT define an inactivity timeout. A client that sends nothing (idle player, or client in lobby/countdown) is never disconnected by the server. Broken connections are detected by TCP itself (close or write error).
> - **Carrier disconnects:** The flag returns to the center: `flag.owner = null`, `flag.x = 500`, `flag.y = 500` in the next `state`.
> - **Server disconnects:** Clients detect the TCP close, stop the match, and display a local "server disconnected" notice. There is no server migration and no protocol message for this case.
> - **Client tries to join mid-match:** Rejected with `GAME_STARTED` during `countdown` and `playing`, and the connection is closed. Reconnection to an ongoing match is outside v1 scope: re-entering is only possible when the server is in `lobby`.

### **5.3 Tiebreaker decisions and domain properties**

| Case                                         | Authoritative rule                                                                                                                                                                                                                                                | Observable result                                                    |
| :------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------- |
| **Two capture free flag**                    | The server processes `interact` messages one at a time in TCP arrival order; the first valid one keeps the flag and the second is evaluated against the already taken flag (fails, unless it is at ≤ 40 from the new carrier, in which case it is a valid theft). | A single `flag.owner` in the next `state`.                           |
| **Several steal from the same carrier**      | Same criterion: the first valid `interact` in arrival order steals; the rest are evaluated against the new carrier and must retry if they do not meet the distance.                                                                                               | A single owner change per processed message.                         |
| **Duplicate attempt by the same player**     | An `interact` from whoever is already the carrier, or that does not meet any condition, has no effect.                                                                                                                                                            | The state does not change; no error is sent.                         |
| **Winner's crossing and theft in same tick** | Movement and victory are evaluated before interactions (section 4.1).                                                                                                                                                                                             | The carrier who crossed wins; theft is not processed.                |
| **Partial frame**                            | The buffer waits for the remaining bytes (section 2.1).                                                                                                                                                                                                           | It is not considered a message until the complete line is assembled. |
| **Slow client**                              | Pending `state` messages are coalesced to the most recent; other messages are preserved (section 4.2).                                                                                                                                                            | Memory does not grow; the client may skip visual states.             |
| **Theft from outside the circle**            | Distance is the only requirement for theft, but victory requires the inside → outside transition while keeping the flag (section 3.3).                                                                                                                            | The thief who was outside does not win instantly.                    |

#### **Properties that must remain true**

> 1. In any `state`, there is at most one non-null `flag.owner`.
> 2. The flag always has exactly one location: at the center (500,500), at the point where it was left free, or at the carrier's position.
> 3. The winner is written once per match: a single `game_over` per round.
> 4. Each received message is processed exactly once and in arrival order; no message mutates the state twice.
> 5. A client cannot win by sending coordinates or declaring victory: positions and victory are calculated solely by the server.
> 6. The same sequence of messages, in the same arrival order, produces the same domain result (determinism).

## **6. SECURITY CONSIDERATIONS**

### **6.1 Absence of Encryption and Authentication**

Protocol v1 transmits information in plain text via JSON messages over TCP/UDP. It does not implement encryption layers (such as TLS/DTLS) or prior user authentication mechanisms (such as JWT tokens or passwords).

- **Network Environment:** It is assumed that the game operates exclusively on a Local Area Network (LAN) or controlled testing environment.
- **Risk:** Any user connected to the same network can intercept traffic (sniffing) or send spoofed packets impersonating another participant's `player_id`. For this standard, this risk is accepted within the project's scope.

### **6.2 Denial of Service (DoS) and Memory Control**

To prevent a malicious or faulty client from exhausting the server's memory or bandwidth resources, the specification imposes three strict barriers:

1. **Message Size Limit (`message_max_size`):** Any incoming message exceeding 64 KB is rejected with `MESSAGE_TOO_LARGE` and causes immediate closure of the TCP socket. In UDP, packets larger than 64 KB are silently discarded.
2. **Name Sanitization (`name_max_length`):** Player names are restricted to a maximum of 20 UTF-8 characters after applying space trimming (`trim`) and removal of control characters or line breaks.
3. **Connection Control (`max_players`):** The server must limit the room to 100 simultaneous connections. Excess `join` requests are rejected with `LOBBY_FULL` and the socket is closed.

### **6.3 Input Validation and JSON Parser Injection**

The server MUST treat all data coming from clients as **untrusted**:

- **Type Injection (Type Confusion):** The parser must verify that coordinates or direction vectors (`dir.x`, `dir.y`) are strictly integer numeric types and not text strings or complex structures.
- **Missing or Unknown Fields:** A message with missing fields is responded to with `MISSING_FIELD` without modifying state. Undocumented fields must be silently ignored to allow extensibility without destabilizing the server.

### **6.4 Match Integrity and Cheat Prevention**

Given that the model is **100% Server-Authoritative**, the client has no capacity to dictate its global position or declare victories:

- **Speed Restriction and Teleportation:** The server does not accept X,Y coordinates from the client; it only accepts `dir` intention vectors strictly restricted to the values `{-1, 0, 1}`. If a client sends values outside this range, the server responds `INVALID_FIELD`.
- **Mandatory Victory Transition:** To prevent a client from simulating having won without completing the path, the server internally validates that the carrier has performed the physical transition from being inside the circle (distance ≤ 315) to being completely outside (distance > 315) while keeping the flag at all times.

## **7. CHANGE CONTROL**

### **7.1 Versioning**

> - This document uses semantic versioning: **MAJOR.MINOR.PATCH**.
> - **MAJOR:** Incompatible changes on the wire (new messages, removed or renamed fields, rules that change another project's behavior). A MAJOR change also increments the protocol's `v` field.
> - **MINOR:** New optional fields or compatible clarifications (all previous projects continue interoperating thanks to the unknown fields rule, section 2.2). Does not change `v`.
> - **PATCH:** Wording corrections, examples, or formatting without behavioral change. Does not change `v`.
> - The `v` field of messages identifies the version of the **protocol on the wire**, not the document's version; it only changes with a MAJOR change.

### **7.2 Procedure for modifying the standard**

> 1. Any student proposes the change to the entire group (official class channel), citing the affected section.
> 2. The change is discussed and approved by class agreement; no one modifies their implementation on their own.
> 3. This document is updated, the version is incremented, and it is recorded in the change table with date and author.
> 4. The new version is notified to the group; all projects update before the following testing day.
> 5. The document lives in a Git repository: each approved version remains as an identifiable commit.

### **7.3 Change history**

| Version | Date       | Changes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Author(s)      |
| :------ | :--------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------- |
| 1.0.0   | 2026-07-18 | Initial draft version. Contained undefined fields in the catalog (flag_version, action_id, input_seq, mode, etc.), 8 s timeout, inconsistent error codes, `flag.owner` with ambiguous values (`null` or `0`), incomplete victory and discovery rules. Used as a base for the group review. **Do not implement.**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | CC8 2026 Class |
| 1.1.0   | 2026-07-25 | Consolidated version. Changes with respect to 1.0.0: (1) removal of ghost fields (flag_version, action_id, input_seq, mode, version++, arrival_ordinal, request_id, match_ended, flag_changed) — all tiebreakers are based on TCP arrival order + sequential server execution; (2) removal of the 8 s timeout (v1 does not define a timeout); (3) unified error catalog in UPPERCASE_WITH_UNDERSCORES, with `GAME_STARTED` as a new code that closes the connection; (4) free `flag.owner` exclusively set to `null` (`0` removed as an option); (5) `min_players=2` and countdown abort via `lobby` broadcast; (6) 5 s post-match transition with return to lobby without reconnection; (7) rejection of joins in countdown/playing with `GAME_STARTED` + close; (8) disconnections inferred by comparing `state.players[]` between consecutive ticks; (9) dual broadcast discovery (255.255.255.255 + subnet) with `SO_BROADCAST`, manual unicast to IP:8888, and IP:port fallback; (10) mandatory `SO_REUSEADDR`/`SO_REUSEPORT` on the server's UDP socket; (11) map center fixed at (500,500), victory formalized as distance transition ≤ 315 → > 315 from center while keeping the flag; (12) distance-based theft as the only requirement (regardless of position inside/outside the circle); (13) flag attached to carrier in `state` (`flag.x/y` = carrier position); (14) ring spawn formula R ∈ [350, 450] with random θ; (15) `welcome.config` constants declared fixed and non-dynamic, with normative justification; (16) warning about `\r\n` in framing; (17) 64 KB limit also applied to UDP datagrams; (18) tolerant reading of unknown fields in all messages; (19) new section 6 (Change Control) with modification procedure and history. **MINOR increment (1.1.0):** v1.0.0 was never ratified or implemented, so there are no existing implementations to break; all changes are clarifications, corrections, and gap-filling. The protocol `v` field remains at 1 (compatible on the wire). | Andrés Tobar   |
| 1.2.0   | 2026-07-25 | Structuring under RFC format. Inclusion of Abstract, Terminology, ASCII Diagrams, and new section 6 (Security Considerations) with absence of encryption, memory control, input validation, and cheat prevention. **MINOR increment (1.2.0):** all changes are compatible with v1; the protocol `v` field remains at 1.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Andrés Tobar   |
