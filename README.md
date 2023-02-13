# Homework Assignment 3

## Learning Outcomes

After completion of this assignment, you should be able to:

- Prototype an application in Ruby.

- Work with object-oriented and data structures in Ruby.

- Understand event-driven scripting in Ruby.

## Getting Started

To complete this homework assignment, you will need Ruby3. Install it from [here](https://www.ruby-lang.org/en/documentation/installation/) if you do not already have it. You can also find instructions to install Ruby in the lecture notes from the first lecture on Ruby.

Download or clone this repository to your local system. Use the following command:

`$ git clone <ssh-link>`

After you clone, you will see a directory of the form *cise337-hw3-ruby-\<username\>*, where *username* is your GitHub username.

In this directory, you will find two Ruby files:
- *run_game.rb*
- *treasure_hunt.rb*.

You will write your code in the *treasure_hunt.rb* file. The *tests* directory has the test cases for this homework. You can use the test cases as specifications to guide your code. Your goal should be to pass all the tests.

## How to read the test cases

As mentioned previously, the *treasure_hunt_test.rb* file in the directory *tests* contains the test cases. Each test case is a method prefixed with *test_*. In each of these methods, you will find assert/refute statements that need to be true/false for the test to pass. These asserts compare the expected result with the result obtained by invoking certain methods or referencing certain attributes in your implementation. If a test fails, the name of the failing test will be reported with an error message. You can use the error message from the failing test to diagnose and fix your errors.

*Do not change the test file. If you do then you won't receive any credit for this homework assignment*.

## Problem Specification

In this assignment, we will develop the prototype of a treasure hunt game.

The game takes place in an underground cave full of interconnected rooms. One of the rooms has treasure hidden in it, which is protected by a guard. Anyone attempting to enter the treasure room without killing the guard will get killed by the guard. Other rooms may have other types of hazards in them. The goal is to reach the treasure room avoiding the hazardous rooms. If a player reaches the treasure room and kills the guard, they win. If they encounter a hazard in their search for treasure, they die or are set back.

A player in this game can take only two actions: move to adjacent rooms, or to shoot arrows into adjacent rooms in an attempt to kill the guard protecting the treasure. Until the player knows where the treasure is, most of the time a player will end up moving from room to room to understand the cave’s layout.

Assume that in one instance of this game, the cave has 20 rooms and each room as a unique room number 1-20. Assume the player enters room 1 in the beginning. Here is an example of how the game may proceed.

```
You are in room 1.
Exits go to: 2, 8, 5
-----------------------------------------
What do you want to do? (m)ove or (s)hoot? m
Where? 2
```

Room 1 has three exits, i.e., rooms 2,8, and 5 adjacent to it in the cave. The player can either move to any of the exits or can shoot into the exits from room 1.

```
-----------------------------------------
You are in room 2.
Exits go to: 1, 10, 3
-----------------------------------------
What do you want to do? (m)ove or (s)hoot? m
Where? 10
-----------------------------------------
You are in room 10.
Exits go to: 2, 11, 9
```

Suppose the player chooses to move to room 2 by pressing `m`. In room 2, the player can see the exits and can again choose to either move or shoot. Let's say the player chooses to move to room 10. This way, after every move, a player can begin to understand the topography of the cave. At this point, the player knows that they can go from room 1 to room 2 to room 10.

Play continues in this fashion until the player encounters a hazard.

```
You are in room 10.
Exits go to: 2, 11, 9
What do you want to do? (m)ove or (s)hoot? m
Where? 11
-----------------------------------------
You are in room 11.
Exits go to: 10, 8, 20
-----------------------------------------
What do you want to do? (m)ove or (s)hoot? m
Where? 20
-----------------------------------------
You are in room 20.
You feel a cold wind blowing from a nearby cavern.
Exits go to: 11, 19, 17
```

In this case, the player has managed to get close to a room with a bottomless pit,
which is detected by the presence of cold wind emanating from one of the adjacent
rooms. Since hazards are sensed indirectly, the player needs a sensing mechanism to detect the rooms with hazards. Based on the topography of the cave known so far, the
only two rooms with potential hazards are rooms 17 and 19. One of them might be
safe or both might have hazards.

At this point, the player might guess a safe room. However, that would be too
risky. The wise thing to do would be to backtrack and try another route:

```
What do you want to do? (m)ove or (s)hoot? m
Where? 11
-----------------------------------------
You are in room 11.
Exits go to: 10, 8, 20
-----------------------------------------
What do you want to do? (m)ove or (s)hoot? m
Where? 8
-----------------------------------------
You are in room 8.
You smell something terrible nearby
Exits go to: 11, 1, 7
```

Changing directions worked! On entering room 8, the terrible smell suggests that
the guard protecting the treasure is nearby. Spending years in the cave has given
the guard a peculiar stench. Luckily, the player has already visited rooms 1 and 11.
Hence, the only other adjacent room 7 must contain the treasure:

```
What do you want to do? (m)ove or (s)hoot? s
Where? 7
-----------------------------------------
YOU KILLED THE GUARD! GOOD JOB, BUDDY!!!
```

The game ends there.

The player could have encountered other hazards in a room such as giant bats, which would have moved the player to a random room. Since such factors are randomized, every time this game is played a new cave map would be encountered.

### Implementation Details

You need to implement this game by defining methods in the following classes defined in *treasure_hunt.rb*:

- A *Room* class to manage hazards and connections between rooms.
- A *Cave* class to navigate the topography of the cave.
- A *Player* class to handle the player's moves and senses.

#### Modeling A Room

The *Room* class must have the following **readable** attributes:

- *number*. A unique number to identify the room.
- *hazards*. A list of hazards the room may contain.
- *neighbors*. A list of neighbors adjacent to the room in the cave.

The *Room* class must have the following methods:

- *add(hazard)* for adding a hazard to the list of hazards in the room. A hazard is just a string (e.g., 'bats') or a symbol (e.g., :bats).
- *has?(hazard)* to check if a hazard is in the room. It should return *true* if the hazard is in the room and *false* otherwise.
- *remove(hazard)* for removing an existing hazard from the room. Removing a non-existent hazard should result in a *ValueError* exception.
- *empty?* for checking if the room has hazards. Should return *true* if room has no hazards and *false* otherwise.
- *safe?* for checking if the room is safe. A room is considered safe if it has no hazards and none of its neighbors have hazards. Should return *true* if a room is safe and *false* otherwise.
- *connect(other_room)* for connecting rooms in a cave. This method should add this room as a neighbor of *other_room* and vice-versa.
- *exits* for identifying the rooms adjacent to this room in the cave. The method should return a list of numbers indicating all the adjacent rooms. Should return empty list if the room has no adjacent rooms.
- *neighbor(number)* for getting a room adjacent to this room in the cave. The method should return a room with room number *number* adjacent to this room. Should return *Nil* if no room with *number* is adjacent to this room.
- *random_neighbor* for getting a random room adjacent to this room in the cave. The method should return a random room from the list of rooms adjacent to this room. If the room has no neighbors, then the method should raise an *IndexError*.

A *Room class* stub has been provided for you in *treasure_hunt.rb*. Your job is to complete the class definition based on the requirements outlined above.

#### Modeling The Cave

Although this game can be played with any arbitrary cave layout, we will make
things simpler to better focus on designing the steps of the game. Hence, we will
assume a dodecahedron cave layout. In this layout, a room is placed at each node of the graph,
and the edges form the connections between rooms.

The *Cave* class must have the following attributes:

- *edges* a list of lists [x,y], where x and y are room numbers. The list [x,y] indicates that room x is adjacent to room y and vice-versa. For the purpose of simplicity, you can assume that the cave has room numbers 1 to 20 (inclusive). The instance variable has already been defined for you in the *Cave* class stub.
- *rooms* a dictionary with room number N as key and and an object Room(N) as the corresponding value.

Further, the layout of the cave should be initialized with the rooms connected to its neighbors when an instance of class *Cave* is initialized.

The *Cave* class must have the following methods:

- *add_hazard(h, n)* should add a hazard *h* to *n* random rooms in the cave. For example, if *n* is 3, then the hazard *h* should be added to 3 random rooms in the cave. If hazard *h* already exists in a room then select another room; do not add it to the room.
- *random_room* should return a random room in the cave. You can use *Array.sample* to select a random element from an array.
- *room_with(hazard)* should return a room in the cave with the *hazard*. Should return *Nil* if no room with the *hazard* exists in the cave.
- *move(hazard, frm, to)* should move the *hazard* from room indicated by *frm* to another room in the cave indicated by *to*. If the *hazard* does not exist in the *frm* room, then raise a *ValueError*. After the operation, the *hazard* should be in the *to* room and not in the *frm* room.
- *room(n)* should return a room in the cave with the room number *n* or *nil* if the room does not exist.
- *entrance* should return a room in the cave that is safe. Recall that a room is safe if it has no hazards and none of its neighbors have any hazards.

A *Cave class* stub has been provided for you in *treasure_hunt.rb*. Your job is to complete the class definition based on the requirements outlined above.

#### Modeling A Player

Most events in this treasure hunt game are triggered by conditions based on the player’s location. For example, imagine that the player is in Room 1 and the neighboring rooms are rooms 2,3, and 4. Suppose room 2 has the guard, room 3 has bats, and room 4 is empty. With this setup, the player will sense the hazards in the adjacent rooms, resulting in the following messages in the console:

```
You are in room 1.
You hear a rustling sound nearby
You smell something terrible nearby
Exits go to: 2, 3, 4
```

Next, the player will enter or shoot arrows into an adjacent room. Based on their action, following outcomes are possible:

- The player will encounter the guard upon entering room 2 and will get killed.
- The player will encounter bats upon entering room 3, who will whisk them away to a random room in the cave.
- The player will not encounter any hazards upon entering room 4.
- The player will kill the guard if they shoot into room 2, which will allow them to enter the room and steal the treasure in the next action.
- The player will miss if they shoot into rooms 3 or 4 as neither have the guard. Hence, the guard will wake up and may move to another room in the cave. If the room happens to be the room in which the player currently is, then the guard will kill them.    

By now, you must have realized that the player’s events can be easily generalized
as follows:
- A player can sense hazards.
- A player can encounter hazards.
- A player can perform actions on neighboring rooms such as move to a neighboring room or shoot an arrow into the next room.

With these requirements, we can now model the Player class as an event-driven object that handles each event type or requirement listed above. The only state it explicitly needs to maintain is a reference to the room they are currently in; everything else can be managed externally via callback methods.

To model the event-driven behavior of a Player class, we will first define the following attributes in the *Player* class:

- The *senses* dictionary where the key is a hazard and the callback is a method that will be executed when the player senses a hazard.
- The *encounters* dictionary where the key is a hazard and the callback is a method that will be executed when the player encounters a hazard.
- The *actions* dictionary where the key is a player action and the callback is a method that will be executed when the player performs that action (e.g., move to a neighboring room).
- The *room* attribute to record the room the player is currently in.

Only the *room* attribute should be *readable* from outside the class.

Next, we will define the following methods in the *Player* class to model the event-driven behavior of  player:

- *sense(hazard, &callback)* should record the callback event associated with the hazard in the attribute *senses*. The event is triggered when a player senses a hazard in a neighboring room.
- *encounter(hazard, &callback)* should record the callback event associated with the hazard in *encounters*. This event is triggered when a player encounters a hazard in the room that the player enters.
- *action(act, &callback)* should record the callback associated with the player's act in *actions*. This event is triggered when a player performs an action (such as shoot an arrow to a room).
- *enter(room)* should change the player's current room to the room the player is entering indicated by the *room* argument. If the room the player is entering has hazards, then they should encounter the first hazard that they are defined to run into in the *encounters* attribute.
- *explore_room* should allow a player to explore the neighbors of the current room. Exploring a room involves sensing all hazard in adjacent rooms.
- *act(action, destination)* should allow a player to perform an action on a destination room. For example, move the player to the destination room, where move is an action.

A *Player class* stub has been provided for you in *treasure_hunt.py*. Your job is to complete the class definition based on the requirements outlined above.

#### Playing The Game

To help you imagine the game, this repository contains some starter code in *run_game.rb* and the classes *Narrator* and *Console* in *treasure_hunt.rb*. On running the *run_game.rb* script, a player enters the cave when expression the `player.enter(cave.entrance)` in *run_game.rb* is evaluated. The script then calls the *Narrator* class's *tell_story()* method to repeatedly display a message to the user and take input. The method terminates when the player is killed or when the player kills the guard.

The *run_game.rb* script also defines an instance of the cave's layout, player senses, encounters, and actions. In this layout, the cave has exactly one room with a guard (:guard), three rooms with bats (:bats), and three rooms with a bottomless pit (:pit). If a player encounters a guard, the guard is startled (:startle). Startling a guard can have several consequences (actions). The guard can stay where they are or can move to another room. If the room happens to be the player's room, the player is killed and the games ends. If a player encounter a room with a bat, the bat flies them to a random room in the cave. If they encounter a pit, they fall into it, get killed and the game ends. A player can either make a "move" action, which will take them to a new room in the cave or they can "shoot" an arrow into a room which they suspect to house the guard. If they kill the guard with an arrow, the game ends and the player wins.

If you correctly implement the *Cave*, *Room*, and *Player* classes, you should be able to run the game from *run_game.rb* and play it.

## Submitting Code to GitHub

You can submit code to your GitHub repository as many times as you want till the deadline. After the deadline, any code you try to submit will be rejected. To submit a file to the remote repository, you first need to add it to the local git repository in your system, that is, directory where you cloned the remote repository initially. Use following commands from your terminal:

`$ cd /path/to/cise337-hw3-ruby-<username>` (skip if you are already in this directory)

```
$ git add treasure_hunt.rb
```

To submit your work to the remote GitHub repository, you will need to commit the file (with a message) and push the file to the repository. Use the following commands:

`$ git commit -m "<your-custom-message>"`

`$ git push`

Every time you push code to the GitHub remote repository, the test file in the *tests* directory will run and you will see either a green tick or a red cross in your repository. Green tick indicates all tests passed. Red cross indicates some tests failed. Click on the red cross and open up the report to view which tests failed. Diagnose and fix the failed tests and push to the remote repository again. Repeat till all tests pass or you run out of time!

## Running Test Cases Locally

It may be convenient to run the test cases locally before pushing to the remote repository. To run a test locally use the following command:

`$ ruby tests/<test-file>`

If you want to see more verbose outputs see the help menu to explore different test runner options.

`ruby tests/treasure_hunt_test.rb --runner console --help`

This command assumes that you are in the local repository directory and ruby is correctly installed and configured.
