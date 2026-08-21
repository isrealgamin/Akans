<?xml version="1.0" encoding="utf-8"?>
<!-- Rewrites ownership of castle_A7 (southwest of the Aserai heartland,
     Perassic-Sea country) to the
     Maroon Warlords clan. Applied to the merged settlements document that is
     built from all modules loaded before this one, so it works without
     shipping a copy of the native settlements.xml. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes"/>
  <!-- identity: copy everything unchanged -->
  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>
  <!-- hand the castle to the Maroon Warlords -->
  <xsl:template match="Settlement[@id='castle_A7']/@owner">
    <xsl:attribute name="owner">Faction.clan_maroon_1</xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
