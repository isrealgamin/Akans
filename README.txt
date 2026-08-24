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

This module is almost entirely ADDITIVE. It overrides no native troop or
hero, and reassigns exactly one native settlement: castle_K7 changes hands
via XSLT/Akans_SandBox_Settlements.xslt (see MAROON KINGDOM below).

MAROON KINGDOM
--------------
The Maroon Warlords kingdom used to live in a separate "Maroons" module that
depended on this one. It has been folded in here, so only ONE mod is needed.
Its four files arrived unchanged as maroon_lords.xml, maroon_heroes.xml,
maroon_clans.xml and maroon_kingdoms.xml, declared last in SubModule.xml so
they still merge after the culture, troops and settlements they depend on.

IF THE OLD "Maroons" MODULE IS STILL INSTALLED, DISABLE IT. With both enabled
every clan, kingdom and lord id below is defined twice.

Three Maroon clans hold fifteen settlements between them:

- Faction.clan_maroon_1 (Cudjoe, Zea, Joejoe, Nyla)
    castle_M1 Gao Castle
      castle_village_M1_1 Faso, castle_village_M1_2 Cudjoes Town
- Faction.clan_maroon_2 "Ti Fitaa" (Naquan Ti Fitaa, Cudjoe's father)
    castle_M4 Kormantse Castle
      castle_village_M4_1 Anomabo, village_M4_1 Adanse
    castle_M2 Abrafo Castle
      castle_village_M2_1 Assin, castle_village_M2_2 Denkyira
- Faction.clan_maroon_3 "Swans Company" (Mad Swan)
    town_M2 Nanny Town
      village_M2_1 Accompong, village_M2_2 Scotts Hall
    castle_M3 Trelawny Keep
      castle_village_M3_1 Moore Town, castle_village_M3_2 Charles Town

Maroons also ships Kingdom.maroon and Faction.clan_khuzait_19
(BoklahomaGang). All three Maroon clans are super_faction="Kingdom.maroon".

Cudjoe is 42 rather than 62, so that Naquan can be his living father at 68
without either of them dying of old age in the first few campaign years.

PLACING NEW SETTLEMENTS
-----------------------
Two constraints govern where a settlement may go on the War Sails map, and
both are easy to violate silently:

- It must be on land. The scene's terrain grid is 16x16 nodes of 65 units
  each, and every <node> in NavalDLC/SceneObj/Main_map/scene.xscene carries
  min_height and max_height. A node whose min_height is above zero is land
  across its whole cell. All twelve settlements added here sit in such
  cells - (13,3), (14,3), (13,4), (14,4), (13,5), (14,5). Do not trust
  max_height alone: it reads high for any cell that merely contains a hill.
- It must be inside the playable area. Terrain runs to x=1040, but no native
  settlement exceeds x=943.5; beyond that is the map's border relief. Every
  position here is at or below x=942.

Native settlements sit a median of 18.9 units apart (min 7.0, max 39.3).
Nothing added here is closer than 16.1 units to anything else.

The earlier version of this kingdom crashed at campaign start. Root cause:
every clan in SandBox/spclans.xml marked is_noble="true" owns at least one
settlement at campaign start - there is no native precedent for a landless
noble clan, and the Maroon clans owned none. That is now fixed on both
sides, and the invariant is worth re-checking after any edit here:
- clan_maroon_1 owns castle_M1 outright, so it needs no native transfer.
- clan_khuzait_19 had no fief anywhere, so the XSLT hands it castle_K7.
  castle_K7 was chosen because its owner, clan_khuzait_7, also holds
  castle_K5 and so stays landed. Retargeting that transfer at a single-fief
  clan (castle_K8/clan_khuzait_9, town_A7/clan_aserai_5, ...) just moves the
  same crash onto the donor.
- Kingdom.maroon and both clans point initial_home_settlement at a
  settlement they actually own.

The map icons for all fifteen Maroon settlements are game_entity nodes in
NavalDLC/SceneObj/Main_map/scene.xscene, named to match the settlement ids,
with positions that must stay in sync with akan_settlements.xml. That is a
BASE-GAME file, so a Steam file-verify or a War Sails patch reverts it and the
settlements silently lose their icons and stop being clickable.

Those fifteen entities (12055 lines, 1206 game_entity nodes counting children) are
kept here, so the edit is recoverable:

    powershell -ExecutionPolicy Bypass -File MapIcons\Restore-MapIcons.ps1

Re-running it is safe. It exits without touching anything if the icons are
already present, copies the scene to scene.xscene.bak before writing, and
refuses to install a result that is not well-formed XML. Verified by restoring
into a pristine copy of NavalDLC/SceneObj/Backups/Main_map/scene.xscene: 41846
entities in, 43070 out, matching the edited scene exactly.

You can also still found an Akan kingdom in-game as the player.

INSTALL
-------
1. Copy the "Akans" folder into:
   ...\Mount & Blade II Bannerlord\Modules\
2. In the launcher, enable "Akans" and place it BELOW Native, SandBoxCore,
   SandBox, CustomBattle and the War Sails (NavalDLC) modules.
3. If you previously used the separate "Maroons" module, DISABLE it. Its
   contents are now part of this one and enabling both double-defines every
   Maroon clan, kingdom and lord.
4. Start a new campaign and pick Akan on the culture selection screen.

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
- Localisation was never being loaded. The comment-strings registration was
  corrected from id="strings" to id="GameText", and the language manifest
  was rewritten to the schema the engine actually reads
  (Native/ModuleData/Languages/language_data.xml): LanguageFile elements are
  direct children of LanguageData, there is no LanguageXmlFiles wrapper, and
  xml_path is relative to the Languages folder. The old manifest had neither
  an id nor a name attribute and pointed at EN/language.xml, whose <Language
  default_language=...> root is not a Bannerlord schema at all. English
  strings now live at Languages/std_akan_strings.xml, matching native, where
  English sits at the Languages root and translations get per-language
  subfolders that each carry their own language_data.xml.
- Culture available_ship_hulls was empty; populated with the same hulls
  NavalDLC gives Aserai.
- Oversized banner_key values (16 layers) were trimmed to 12, the maximum
  seen anywhere in native data.
- Culture was still on the pre-War Sails map. NavalDLC ships
  XSLT/NavalDLC_SandBoxCore_SPCultures.xslt, which moves every native
  culture's start point onto the War Sails map (aserai 300.78,259.99 ->
  367,251; empire -> 776,280; sturgia -> 523,603; vlandia -> 305,414;
  battania -> 397,476; khuzait -> 841,541; nord -> 725,811) and adds
  naval_factor, shipwright, shipyard_worker, fishing_party_template and
  settlement_patrol_template_coastal. The Akan culture had base-map
  coordinates (357.485, 216.349) and none of those attributes; it now
  carries the War Sails Aserai set.
- akan_equipment_sets.xml used <EquipmentSet civilian="true">. The engine
  rejects that form ("This civilian tag should not be used anymore, the
  equipmentSet type should be defined as equipmentType=civilian in the
  .xml file"); all 100 were changed to equipmentType="Civilian". The
  separate <EquipmentRoster civilian="true"> form used inside
  <NPCCharacter><Equipments> is still correct and was left alone.
- Conversation tags FemaleTag and GenerousTag do not exist in the engine;
  corrected to NpcIsFemaleTag and GenerosityTag.
- Removed _replaceWhileMerging from akan_troops.xml (a TroopDesigner
  leftover; no Bannerlord assembly reads it).
- akan_settlements.xml is registered as <XmlName id="Settlements"
  path="akan_settlements"/> and the XSLT as a second node,
  path="XSLT/Akans_SandBox_Settlements", matching how NavalDLC registers
  XSLT/NavalDLC_StoryMode_Settlements. The engine merges every .xml for an
  XmlName first and then applies every .xslt for it, so an .xslt sharing the
  base name of a data file (AD1259 does this) works too.
- Every Akan had an identical face. akan_bodyproperties.xml defined only
  fighter_akan, and its BodyPropertiesMin and BodyPropertiesMax carried the
  SAME key, so the engine had no range to randomise within. It now ships six
  templates (fighter / fighter_young / fighter_female / townsman / townswoman /
  character-creation), each with min and max keys that are the per-parameter
  bounding box of five hand-made Akan faces, so 68-74 of the 128 face
  parameters vary. All twelve keys keep the 003F...CC prefix those faces share
  - that prefix carries the complexion, so do not widen the keys toward the
  native aserai ranges. Afro Hair 1-5, Cornrows, CornrowMohawk and Native
  Braids hair tags are now used (they were available all along, and
  fighter_aserai already uses them).
- The ten adult Akan women had no <face> element at all, so they never got an
  Akan face template; they now use townswoman_akan.
- Added akan_woman_warrior (Akan Warrior Woman), a second upgrade path off
  akan_freeman so she actually appears in parties.
- Requires the War Sails DLC (NavalDLC). The Maroon kingdom no longer needs a
  companion module: the four files that made up "Maroons" now ship here as
  maroon_lords.xml, maroon_heroes.xml, maroon_clans.xml and
  maroon_kingdoms.xml. Disable the old "Maroons" module if it is still
  installed - running both defines every Maroon id twice.