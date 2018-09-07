# The Adventures of Varg
    Varg = Virtual Alternate Reality Game, also Wolf, in Norwegian and Swedish

<!-- TOC -->

- [The Adventures of Varg](#the-adventures-of-varg)
- [What is Varg?](#what-is-varg)
    - [General overview](#general-overview)
    - [ARG elements](#arg-elements)
- [Misc Mechanics](#misc-mechanics)
    - [Character profiles and maps](#character-profiles-and-maps)
    - [Dynamic ARG content difficulty](#dynamic-arg-content-difficulty)
        - [Loot item level scaling](#loot-item-level-scaling)
        - [World Quest scaling](#world-quest-scaling)
        - [Mythic dungeon / Mythic+ scaling](#mythic-dungeon--mythic-scaling)
        - [Raiding rewards](#raiding-rewards)

<!-- /TOC -->

# What is Varg?
Varg is a rogue-lite game with ARG elements, implemented as an addon inside World Of Warcraft. The "virtual" part of the name stems from the fact this is basically a game within a game, an ARG inside an already virtual world. Hence, Virtual Alternate Reality Game.


## General overview
Varg is played through a text-console type interface, as most rogue-likes are. Undecided at this point whether there should be an actual map on-screen (ASCII style), or whether it's purely a text based experience, along the lines of the classic Zork. Graphical tiles would be possible, but would require a *lot* of work, and would probably be a worse experience anyhow.

The player starts by creating a character, very much in the rogue-like manner of giving a name, picking some base traits and skill points, perhaps picking some deities or other interesting choices. All of these would be somewhat WoW-themed, things like deities could be notable Gods or God-like creatures from WoW lore. Or, perhaps slight word-plays on them, as to not literally rip off the existing wow names. The same idea applies to enemies, items, areas, all sorts of things you might find in the game in general.


## ARG elements
Essentially the main point of the game, is that there are a lot of ARG-elements in relation to the World Of Warcraft character that you are actually playing. Doing interesting things in WoW, could lead to benefits (or disadvantages for that matter) for your Varg character.

Note that all the activities should be current content for WoW. That is, it shouldn't be completely trivial to just boost your Varg character to high heavens by doing trivial content (for your character) in WoW.

Some brainstorm ideas:

* World Quests could earn your Varg character some XP.
* WoW loot drops could earn you chances at bonus loot in Varg. Like loot crates.
* Doing PVP could earn you prestige, making you a more feared enemy in the world of Varg (Social/Charisma skill).
* Dying in WoW could lead to a loss of XP or some kind of downside in Varg. This should have diminishing returns in case you are dying over and over again in WoW for some reason, maybe with a grace period...
* Doing Follower missions in WoW could also give Varg XP.
* [ambitious] Exploring areas / zones in WoW could unlock or generate new areas in Varg. Easy enough to overcome the issue of zones already being discovered by the WoW character by simply tracking it separately and starting at nothing. Your starting zone would be themed on where you are in WoW at the time of creating your new Varg character.
* Easter eggs and special places could be a thing. For example, creating a new Varg character while inside Deadmines could unlock a unique Pirate trait or class, only possible to create while inside the Deadmines.
* Achievements would be possible. These could be purely rooted in Varg activities, or they could be ARG-themed, such as getting an achievement for killing a difficult enemy in Varg while inside a Heroic or Mythic WoW raid instance! Also, achievements could pop up in /g, with a clickable link system similar to how WeakAuras work, for a completely custom achievement system tied to Varg.
* Maybe certain WoW NPC's, when targeted, can offer special things to occur in Varg, like special events.



# Misc Mechanics

## Character profiles and maps

Varg characters, and perhaps randomly generated maps (if they are a thing), would default to being specific to the character you are currently logged in to. You might have the option to create a global character, playable from any of your WoW characters, but with reduced rewards because of the potential to exploit this a lot. Obviously it's trivial to exploit literally anything since the Varg game data is stored in plain text in the WoW folder, but at least the smallest effort to discourage it will stop most people from ruining the fun for themselves.


## Dynamic ARG content difficulty

Since Varg requires the WoW character to complete "current" content, the definition of what is current for any one character needs to be somewhat flexible. While it is reasonable to expect Varg to require an update once every major WoW content patch and expansion, and thus the defintion of "current" content can be updated by hand, it's not really a good, flexible way to do it.

Instead, what Varg considers relevant content will be adjusted automatically based on a number of things.

### Loot item level scaling

Since WoW loot will give chances for loot in Varg, but should only work on "relevant" content for any one character, it needs to accomodate what the character is actually doing. If a character only does random dungeon content and never attains high ilevel loot on a regular basis, it would be very unfair to "require" a fixed high level of loot.

Likewise, for a player who does weekly raiding or M+, it would be too easy if the required item level for Varg progress was set too low, since they are likely to acquire a lot of high level loot on a regular basis.

To accomodate BOTH of these scenarios, the required ilevel for WoW drops will scale smoothly to fit whatever the individual WoW character is actually seeing on a regular basis.

The starting point should probably be fixed per WoW expansion, starting at a reasonable minimum, and then scaling to fit the character as more data points are collected. This base minimum will likely be the base ilevel of Heroic dungeons for that expansion.

The ilevel requirement scaling works by adjusting the minimum every time a new item is looted. The item must be Bind On Pickup of Rare quality or higher (maybe greens too?). The item must be an armor piece, accessory (trinket, rings, neck) or a weapon, and the loot caches in Varg will reflect this. See ## ARG Loot Caches for details on loot caches.

The minimum does not jump immediately to whatever the player just looted, rather it checks whether the new item was significantly higher than the current minimum, and makes a small adjustment towards that higher level. Likewise if a player loots an item that is lower ilevel than the current minimum, and within a certain teshold (to avoid abuse), the minimum will make a small adjustment downwards again. This should allow the system to accomodate a character that has a period of high ilevel loot, followed by a long period of low ilevel loot, or vice versa. The rewards will not scale immediately, but given a reasonable period of time (a few days? a week?), the player will start earning Varg caches for the items they are looting once again.

    Technical:

    This is probably best implemented as a moving average of the ilevel of the last n eligible items you've looted, with a relatively small window size. This means that anomalous spikes and drops has little effect, but a consistent trend will lead to change pretty quickly (within n cycles, if the window size is n). This could be weighted towards the front or the back of the window to alter it's response.


### World Quest scaling

World quests starting in Battle for Azeroth won't change significantly in terms of difficulty, so the Varg rewards will largely be the same. This makes sense anyway, since world quests are mostly time sinks, and can't be exploited for easy Varg XP (nor loot, after a certain point) anyway.

Special or elite WQ's will give better rewards. The general distinctions are, sorted from high to low XP reward;

1. World boss quests
2. Elite / rare mob kill quests
3. Normal world quests, pet battle quests, and crafting quests.

### Mythic dungeon / Mythic+ scaling

Probably will simply reward a base amount of XP on completion, with a bonus based on difficulty. Hard to exploit, since there's a significant time investment regardless. The reward per M+ level should scale fairly slowly, perhaps 5% per level. Maybe there should also be a first-time dungeon clear reward, per difficulty. This would count Mythic, including all M+ levels, as one difficulty. Alternatively, each time you complete a Mythic dungeon, as long as it was a higher than your previous best, should also count as a "new" difficulty and reward you as such.

### Raiding rewards

Raiding should inherently be quite rewarding thanks to loot. But it would also be easy to add an XP reward for every raid boss killed, perhaps multiplied by difficulty - with LFR boss kills essentially rewarding the same as a world quest (about the same time investment).

Perhaps first-time kills of a boss, per difficulty, should reward a one-time big XP reward also? This means there's basically a limited collection of high reward objectives for the player to complete, per character.