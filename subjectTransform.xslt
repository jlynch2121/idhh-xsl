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
  
  <!-- 
    Template for splitting coordinated subject values using recursive nested replace methods on values containing double dashes
    Does not replace an exhaustive list of delimiters
    Will be applied only to CPL, UIUC, ISU, and DePaul and only catches delimiters specific to these institutions' subject metadata
  -->
  <xsl:template match="dc:subject">
    <xsl:element name="dc:subject">
      <xsl:choose>
        <xsl:when test="contains(., '--')">
          <xsl:variable name="normalizedString" select="replace(replace(replace(., ' -- ', '; '), ' --', '; '), '--', '; ')"/>
          <xsl:value-of select="$normalizedString"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
