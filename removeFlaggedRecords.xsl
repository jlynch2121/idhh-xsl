<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:default="http://www.openarchives.org/OAI/2.0/"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' 
xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0" 
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:oai_qdc="http://worldcat.org/xmlschemas/qdc-1.0/"
xmlns:oaiProvenance="http://www.openarchives.org/OAI/2.0/provenance">
  
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  
  <!-- 
     This section is the Identity transform that generates a document equal to the input document.
     It also "removes" any records from the feed that contain dc:relation with the text notdpla 
  -->
  <xsl:template match="node()|@*">
    <xsl:if test="not(./dc:relation='notdpla')">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
      </xsl:if>
  </xsl:template>
</xsl:stylesheet>
