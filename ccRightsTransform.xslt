<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:default="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0"
  xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oai_qdc="http://worldcat.org/xmlschemas/qdc-1.0/"
  xmlns:oaiProvenance="http://www.openarchives.org/OAI/2.0/provenance">

  <!-- Identity transform that generates a document equal to the input document. -->
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node() | @*">
    <xsl:copy><xsl:apply-templates select="node() | @*"/></xsl:copy>
  </xsl:template>
  
  <!-- Creates the edm field for standardized rights for NIU's CC licenses. -->
  <xsl:template match="dc:rights">
    <xsl:variable name="s" select="normalize-space(.)"/>
    <xsl:analyze-string select="$s"
      regex=".*(https:.*creativecommons\.org/*.*0/).*">
      
      <xsl:matching-substring>
        <xsl:element name="edm:rights" xmlns:edm="http://www.europeana.eu/schemas/edm/">
          <xsl:value-of select="regex-group(1)"/>
        </xsl:element>
      </xsl:matching-substring>
      
      <xsl:non-matching-substring>
        <xsl:element name="dc:rights">
          <xsl:value-of select="$s"/>
        </xsl:element>
      </xsl:non-matching-substring>
      
    </xsl:analyze-string>
    
  </xsl:template>
</xsl:stylesheet>