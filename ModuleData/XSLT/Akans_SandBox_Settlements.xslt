<?xml version="1.0" encoding="utf-8"?>
<!-- Gives the BoklahomaGang (Faction.clan_khuzait_19, Maroons module) a fief.

     Runs against the *merged* Settlements document (SandBox + NavalDLC +
     akan_settlements), so the module never ships a copy of the native
     settlements.xml and stays compatible with War Sails' repositioning pass.

     WHY THIS IS NEEDED
     Every one of the 98 clans in SandBox/spclans.xml marked is_noble="true"
     owns at least one settlement at campaign start - there is no native
     precedent for a landless noble clan, and the last attempt at a Maroon
     kingdom died in world initialisation for exactly that reason (see
     README.txt). clan_khuzait_19 is is_noble="true" tier="5" and owns nothing,
     so it needs a fief here.

     WHY castle_K7 (Simira Castle)
     Its owner can spare it: clan_khuzait_7 also holds castle_K5, so it stays
     landed after the transfer. clan_khuzait_19's initial_home_settlement in
     Maroons/spclans.xml points at castle_K7, so the two must stay in sync.
     Do NOT retarget this at castle_K8 / Erzenur Castle (clan_khuzait_9),
     town_A7 / Askar (clan_aserai_5) or any other single-fief clan - each of
     those owners holds exactly one settlement, so retargeting just moves the
     landless-noble crash onto the donor.

     Faction.clan_maroon_1 needs no transfer: it owns castle_M1 from
     akan_settlements.xml, plus the two villages bound to it. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="no" indent="yes" />

  <!-- identity: copy everything through unchanged -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Simira Castle: clan_khuzait_7 -> clan_khuzait_19 -->
  <xsl:template match="Settlement[@id='castle_K7']/@owner">
    <xsl:attribute name="owner">Faction.clan_khuzait_19</xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
