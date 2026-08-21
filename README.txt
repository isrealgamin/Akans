Akans - playable Akan culture for Mount & Blade II: Bannerlord (War Sails)
==========================================================================

WHAT THIS IS
------------
An XML-only module (no DLL needed) built from your Maroon Kingdom /
TroopDesigner files. It adds:
- The Akan culture, selectable at the culture selection screen when starting
  a new sandbox campaign (is_main_culture=true), with Akan name lists,
  banner, character-creation equipment and education stages.
- A full Akan troop roster: Akan Freeman -> Maroon Soldier line,
  Akan Warrior -> Maroon Ranged -> Maroon Ranged upgrade line,
  Jawwal Recruit mercenaries, plus town guard / scout / skirmisher militia.
- The Maroon Warlords kingdom (Cudjoe, Zea, Joejoe, Nyla) and clan, now set
  to Akan culture, plus the BoklahomaGang clan from your files.
- All Akan notables, party templates, equipment rosters and dialog strings.
- Starting fief: castle_A7, in the far SOUTHWEST of the Aserai lands by
  the Perassic Sea, is handed to the Maroon Warlords at campaign start via
  an XSLT patch on settlements.xml (version-safe, no native files copied).

INSTALL
-------
1. Copy the "Akans" folder into:
   ...\Mount & Blade II Bannerlord\Modules\
2. In the launcher, enable "Akans" and place it BELOW Native, SandBoxCore,
   SandBox, CustomBattle and the War Sails (NavalDLC) modules.
3. Start a new campaign and pick Akan on the culture selection screen.

NOTES / FIXES MADE
------------------
- Your uploaded Maroon_Kingdom_v1.0.0.zip was empty, so the module was
  rebuilt from the loose XML files you uploaded.
- ~70 dangling references that would have crashed the game were repaired:
  town-life NPCs now point at their Aserai equivalents, missing troops,
  notables, party templates, body properties and default equipment rosters
  were created, and jawwal_tier_2 / spc_jawwal_leader_* references were
  re-pointed at existing troops.
- Troop cultures were changed from darshi to akan so they belong to the new
  culture. The kingdom/clan/lords were switched from aserai to akan.
- Requires the War Sails DLC (NavalDLC). No other mods are required.
