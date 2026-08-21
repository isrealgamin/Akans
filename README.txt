Akans - playable Akan culture for Mount & Blade II: Bannerlord (War Sails)
==========================================================================

WHAT THIS IS
------------
An XML-only module (no DLL needed) that adds the Akan culture as a
playable, selectable culture. It adds:
- The Akan culture, selectable at the culture selection screen when starting
  a new sandbox campaign (is_main_culture=true), with Akan name lists,
  banner, character-creation equipment and education stages.
- A full Akan troop roster: Akan Freeman -> Maroon Soldier line,
  Akan Warrior -> Maroon Ranged -> Maroon Ranged upgrade line,
  Akan Jawwal Recruit mercenaries, plus town guard / scout / skirmisher
  militia.
- All Akan notables, town/village NPCs, party templates, equipment rosters
  and dialog strings.
- An Akan lord template (akan_rebel_lord), so Akan-culture lords can still
  be generated for rebellions and for a player-founded Akan kingdom.

This module is purely ADDITIVE - it does not modify, overwrite or reassign
any native game data (no settlement ownership changes, no native troop or
hero overrides, no XSLT patches).

NO MAROON KINGDOM
-----------------
Earlier versions shipped a Maroon Warlords kingdom (Cudjoe, Zea, Joejoe,
Nyla, Accompong, Akosua, Naquan, Yaa across three clans) plus a
BoklahomaGang clan. These were REMOVED because they crashed the game at
campaign start.

Root cause: every one of the 73 native noble clans, across all 8 native
kingdoms, owns at least one settlement at campaign start. The Maroon
clans owned none - the XSLT meant to hand them castle_A7 was misnamed
(akan_settlements.xslt against path="akan_settlements"), so it never
applied. A noble kingdom with zero settlements has no native precedent
and did not survive world initialisation.

To restore a Maroon kingdom later, it needs real fiefs: a correctly named
settlements.xslt (base name must match the path= in its XmlName
registration) transferring one or more settlements to a Maroon clan, plus
initial_home_settlement pointing at a settlement that clan actually owns.

You can still found an Akan kingdom in-game as the player.

INSTALL
-------
1. Copy the "Akans" folder into:
   ...\Mount & Blade II Bannerlord\Modules\
2. In the launcher, enable "Akans" and place it BELOW Native, SandBoxCore,
   SandBox, CustomBattle and the War Sails (NavalDLC) modules.
3. Start a new campaign and pick Akan on the culture selection screen.

NOTES / FIXES MADE
------------------
- Troop cultures were changed from darshi to akan so they belong to the new
  culture.
- ~325 dangling item/character/template references were repaired (items and
  NPCs that did not exist in the game at all, e.g. aserai_villager_shoes,
  infantry_sabre), re-pointed at their real native equivalents.
- akan_party_templates.xml used the wrong schema entirely
  (<partyTemplate>/<stack character=...>); rewritten to the native
  <MBPartyTemplate>/<PartyTemplateStack troop=...> form.
- Localisation was never being loaded: added Languages/language_data.xml
  and Languages/EN/language.xml, and corrected the comment-strings
  registration from id="strings" to id="GameText".
- Culture available_ship_hulls was empty; populated with the same hulls
  NavalDLC gives Aserai.
- Oversized banner_key values (16 layers) were trimmed to 12, the maximum
  seen anywhere in native data.
- Requires the War Sails DLC (NavalDLC). No other mods are required.
