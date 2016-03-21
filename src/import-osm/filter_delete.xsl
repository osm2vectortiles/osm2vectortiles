<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:template match="/">
      <osmChange>
         <xsl:attribute name="timestamp">
            <xsl:value-of select="osmChange/@timestamp" />
         </xsl:attribute>
         <xsl:for-each select="osmChange/delete">
            <xsl:copy-of select="." />
         </xsl:for-each>
      </osmChange>
   </xsl:template>
</xsl:stylesheet>
