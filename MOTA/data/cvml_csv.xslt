<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text"/>
<xsl:variable name="sep" select="' '" />
<xsl:template match="/">
      <xsl:for-each select="result/frame">
    <xsl:for-each select="objectlist/object">
        <xsl:value-of select="../../@number"/>
        <xsl:copy-of select="$sep" />
        <xsl:value-of select="@id"/>
        <xsl:copy-of select="$sep" />
        <xsl:value-of select="box/@xc"/>
        <xsl:copy-of select="$sep" />
        <xsl:value-of select="box/@yc"/>
        <xsl:copy-of select="$sep" />
        <xsl:value-of select="box/@w"/>
        <xsl:copy-of select="$sep" />
        <xsl:value-of select="box/@h"/>
        <xsl:value-of select="'&#xA;'"/>
    </xsl:for-each>
      </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
