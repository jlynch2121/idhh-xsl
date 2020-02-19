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
    Creates the dcterms field for provider for CARLI collections
    Creates edm field for the Intermediate Provider for CARLI. 
  -->
  <xsl:template match="dcterms:isPartOf">
    
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
    
    <xsl:variable name="s" select="normalize-space(.)"/>
    
    <xsl:choose>
      <xsl:when test="contains($s, ') (')">
        <xsl:variable name="i"
          select="substring-before(substring-after($s,') ('),')')"/>
        <xsl:if test="contains($i,'Academy') or
          contains($i,'College') or
          contains($i,'Institute') or
          contains($i,'Library') or
          contains($i,'Museum') or
          contains($i,'Seminary') or
          contains($i,'School') or
          contains($i,'Union') or
          contains($i,'University')">
          <xsl:element name="dcterms:provenance">
            <xsl:value-of select="$i"/>
          </xsl:element>
        </xsl:if>
      </xsl:when>
      <xsl:when test="contains($s, '(')">
        <xsl:variable name="i"
          select="substring-before(substring-after($s,'('),')')"/>
        <xsl:if test="contains($i,'Academy') or
          contains($i,'College') or
          contains($i,'Institute') or
          contains($i,'Library') or
          contains($i,'Museum') or
          contains($i,'Seminary') or
          contains($i,'School') or
          contains($i,'Union') or
          contains($i,'University')">
          <xsl:element name="dcterms:provenance">
            <xsl:value-of select="$i"/>
          </xsl:element>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    
    <edm:hasMet xmlns:edm="http://www.europeana.eu/schemas/edm/">CARLI Digital Collections</edm:hasMet>
    
  </xsl:template>
  
  <!-- Creates the edm field for the Intermediate Provider for IDA. -->
  <xsl:template match="dcterms:provenance">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <edm:hasMet xmlns:edm="http://www.europeana.eu/schemas/edm/">Illinois Digital Archives</edm:hasMet>
  </xsl:template>
  
  <!-- Creates the edm field for the Intermediate Provider for certain records contributed by DPPL. -->
  <xsl:template match="dcterms:provenance">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:if test="not(.='Des Plaines Public Library')">
      <edm:hasMet xmlns:edm="http://www.europeana.eu/schemas/edm/">Des Plaines Public Library</edm:hasMet>
    </xsl:if>
  </xsl:template>
  
  <!-- 
    Creates the dcterms field for Provider and edm field for the Intermediate Provider for Madison Historical. 
    Change will unite CARLI and Madison Historical collections contributed by SIUE but will need to be approved by SIUE. 
  -->
  <xsl:template match="dc:title">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <dcterms:provenance>Madison Historical</dcterms:provenance>
    <edm:hasMet xmlns:edm="http://www.europeana.eu/schemas/edm/">Southern Illinois University Edwardsville</edm:hasMet>
  </xsl:template>
</xsl:stylesheet>