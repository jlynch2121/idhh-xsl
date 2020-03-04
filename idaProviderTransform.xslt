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
    Works on only the first instance of the dcterms:provenance field
    Removes URLs from provider values
    Capitalizes proper nouns in provider names
    Creates the edm field for the Intermediate Provider for IDA. 
  -->
  <xsl:template match="dcterms:provenance[1]">
    <xsl:variable name="lcProv" select="lower-case(.)"/>
    <xsl:variable name="remUrl">
      <xsl:choose>
        <xsl:when test="contains($lcProv, 'http')">
          <xsl:value-of select="normalize-space(substring-before($lcProv, 'http'))"/>
        </xsl:when>
        <xsl:when test="contains($lcProv, 'www')">
          <xsl:value-of select="normalize-space(substring-before($lcProv, 'www'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$lcProv"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="dcterms:provenance">
      <xsl:variable name="normProv">
        <xsl:variable name="remSpecChar">
          <xsl:choose>
            <xsl:when test="matches(substring($remUrl, string-length($remUrl)), '^[a-z0-9]+$')">
              <xsl:value-of select="$remUrl"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring($remUrl, 1, string-length($remUrl) - 1)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="tokenize($remSpecChar, ' ')">
          <xsl:choose>
            <xsl:when test=". = 'a' or 
              . = 'an' or 
              . = 'the' or 
              . = 'for' or 
              . = 'of' or 
              . = 'and' or 
              . = 'with' or 
              . = 'materials' or 
              . = 'owned' or 
              . = 'by' or 
              . = 'in' or 
              . = 'cooperation' or 
              . = 'at'">
              <xsl:value-of select="concat(., ' ')"/>
            </xsl:when>
            <xsl:when test=". = 'mclean'">
              <xsl:value-of select="concat('McLean', ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(concat(upper-case(substring(.,1,1)),
                lower-case(substring(., 2))), ' ')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains(., 'Pullman State Historic Site') or
          contains(., 'Donald Horn')">
          <xsl:value-of select="'Pullman State Historic Site'"/>
        </xsl:when>
        <xsl:when test=". = 'Plainfield Public Library District'">
          <xsl:value-of select="'Plainfield Public Library'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(concat(upper-case(substring($normProv,1,1)), substring($normProv, 2)))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <edm:hasMet xmlns:edm="http://www.europeana.eu/schemas/edm/">Illinois Digital Archives</edm:hasMet>
  </xsl:template>
  
  <!-- Removes rest of record's provenance values, if multiple are present -->
  <xsl:template match="dcterms:provenance[position()>1]"/>
  
</xsl:stylesheet>
