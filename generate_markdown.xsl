<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" method="text" indent="yes"/>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="//error">
#### Error report:
        <xsl:for-each select="season/error">
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="season_data"></xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="season_data">
# Season <xsl:value-of select="season/name"/>
### Competition <xsl:value-of select="season/competition"/>
#### Year: <xsl:value-of select="season/date/year"/>. From <xsl:value-of select="season/date/start"/> to <xsl:value-of select="season/date/end"/>
___
___
    <xsl:for-each select="stages/stage">
#### <xsl:value-of select="@phase"/>. From <xsl:value-of select="@start_date"/> to <xsl:value-of select="@end_date"/>
    </xsl:for-each>
___
    <xsl:for-each select="stages/stage/groups/group">
#### Competitors:
      <xsl:for-each select="competitor">
* <xsl:value-of select="name"/>(<xsl:value-of select="country"/>)
      </xsl:for-each>
#### Events:
      <xsl:for-each select="event">
| Date | Local | Visitor |
| --- | --- | --- |
| <xsl:value-of select="//season_data/stages/stage/@start_date"/> | <xsl:value-of select="local/score"/> | <xsl:value-of select="visitor/score"/> |
| | <xsl:value-of select="local/name"/> | <xsl:value-of select="visitor/name"/> |
      </xsl:for-each>
___
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
