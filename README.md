#### :crystal_ball: DEO Tracking
![alt tag](https://github.com/OOMM/addons/blob/master/DEO_Tracking.jpg)
> Track Lord Season Begins

Automatically tracks procs for weapon enchants, set bonuses, rings, and trinkets.

Add new buff tracking by adding the following under the appropriate spec to Spells.lua
* Trinket
```lua
DEOSpells["Nightmare Fire"] = { 
  spid = 162919, 
  itemid = 112320, 
  cd = 115, 
  originType = "equipment" 
}
```
* Tier
```lua
DEOSpells["Demon Rush"] = { 
  spid = 188857, 
  itemid = {124156,124167,124173,124179,124162}, 
  numitems = 2, slot = -2, 
  originIcon = "ability_rogue_deadlymomentum", 
  originType = "tier"
}
```
* Enchant
```lua
DEOSpells["Mark of Bleeding Hollow"] = { 
  spid = 173322, 
  rppm = 2.3, 
  slot = 16, 
  originType = "enchant" 
}
```

#### :ring: DEO Text Hide
![alt tag](https://github.com/OOMM/addons/blob/master/DEO_Text_Hide.jpg)
> Too much clutter

* /deo macro show
* /deo macro hide
* /deo keybind show
* /deo keybind hide

#### :pill: DEO Additions
![alt tag](https://github.com/OOMM/addons/blob/master/DEO_Additions.jpg)
> Lil things here and there

Contains:

* Raid Marker Icon for the Player Unit Frame
