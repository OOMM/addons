#OOMM
##⚡ DEO Tracking
![alt tag](https://github.com/OOMM/addons/blob/master/DEO_Tracking.jpg)
> Track Lord Season Begins

Automatically tracks procs for weapon enchants, set bonuses, rings, and trinkets. Add new buff tracking by adding the following under the appropriate spec to Spells.lua
```lua
DEOSpells["Nightmare Fire"] = { 
  spid = 162919, 
  itemid = 112320, 
  cd = 115, 
  originType = "equipment" 
}
```

###BUGS
* check for weapon enchant

###TODO
* simplify the enabled tracking
* add support for debuff tracking
* add more examples to readme
* research all class bonuses and trinkets to look for additional tracking types
* movable with slash command

###FEATURES
* build slots for non-equipment?
* add support for multiple buff for a single aura (heroism)
* add support for debuff check (heroism)
* add support for item (potion)
* in game config: add/render tracked items

##🔮 DEO Text Hide
![alt tag](https://github.com/OOMM/addons/blob/master/DEO_Text_Hide.jpg)
> Too much clutter

Hide keybind and macro text from buttons.
###BUGS

###TODO
* add slash command toggle

###FEATURES

##💊 DEO Additions
![alt tag](https://github.com/OOMM/addons/blob/master/DEO_Additions.jpg)
> Lil things here and there

Contains:

* Raid Marker Icon for the Player Unit Frame

###BUGS

###TODO

###FEATURES
* dungeon map
