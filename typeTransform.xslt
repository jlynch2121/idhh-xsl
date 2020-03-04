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
    Matches to each dc:format and dcterms:medium fields in record
    Tokenizes delimited values, passing each token to a template that deploys subsequent normalization templates
    Non-delimited values are passed to the normalization-deploying template
  -->
  <xsl:template match="dc:type">
    <xsl:variable name="normalizedString">
      <xsl:call-template name="normalizeDelimiters">
        <xsl:with-param name="rawString" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($normalizedString, ';')">
        <xsl:for-each select="tokenize($normalizedString, ';')">
          <xsl:call-template name="delAndNorm">
            <xsl:with-param name="toDelAndNorm" select="$normalizedString"/>
            <xsl:with-param name="formatOrType" select="'type'"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="delAndNorm">
          <xsl:with-param name="toDelAndNorm" select="$normalizedString"/>
          <xsl:with-param name="formatOrType" select="'type'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
      Template for normalizing semicolons
      Can easily be applied to any field values; is so far applied to type and language.
  -->
  <xsl:template name="normalizeDelimiters">
    <xsl:param name="rawString"/>
    <xsl:variable name="normalizedString" select="normalize-space(replace($rawString, ',', ';'))"/>
    <xsl:value-of select="$normalizedString"/>
  </xsl:template>
  
  <!-- 
      Template for applying delete and normalize templates for type, format, medium values
      Reduces repeated code in the type and format|medium matching templates and allows sheet to run more efficiently
  -->
  <xsl:template name="delAndNorm">
    <xsl:param name="toDelAndNorm"/>
    <xsl:param name="formatOrType"/>
    <xsl:variable name="testedForDel">
      <xsl:call-template name="deleteVal">
        <xsl:with-param name="delTest" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="not(normalize-space($testedForDel)='')">
      <xsl:choose>
        <xsl:when test="$formatOrType = 'type'">
          <xsl:call-template name="dcmiTypeVocab">
            <xsl:with-param name="rawType" select="normalize-space($testedForDel)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <!--<xsl:call-template name="aatFormat">
            <xsl:with-param name="rawFormat" select="normalize-space($testedForDel)"/>
          </xsl:call-template>-->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <!-- 
      Deletes list of values from type, format, and medium fields, including file format, 
      technical digitization metadata, and other frequently occuring non-standard values
    -->
  <xsl:template name="deleteVal">
    <xsl:param name="delTest"/>
    <xsl:variable name="lowercase" select="lower-case($delTest)"/>
    <xsl:choose>
      <xsl:when test="contains($lowercase, 'pdf') or
        contains($lowercase, 'jp') or
        contains($lowercase, 'tiff') or
        contains($lowercase, '.tif') or
        $lowercase = 'tif' or
        $lowercase = 'image/tif' or
        contains($lowercase, 'tagged image') or
        contains($lowercase, 'mpeg') or
        contains($lowercase, 'cpd') or
        $lowercase = 'n/a' or
        $lowercase = 'na' or
        $lowercase = 'none' or
        contains($lowercase, 'gif') or
        contains($lowercase, 'mp3') or
        contains($lowercase, 'm4v') or
        contains($lowercase, 'wav') or
        contains($lowercase, 'boys in blue logan') or
        $lowercase = 'ill.' or
        contains($lowercase, 'book viewer') or
        contains($lowercase, '8 bit') or
        contains($lowercase, 'scan') or
        contains($lowercase, 'colorflex') or
        contains($lowercase, 'dpi') or
        contains($lowercase, 'photoshop')">
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$delTest"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- 
      Template for normalizing type matches raw type data with a DCMI Type value
  -->
  <xsl:template name="dcmiTypeVocab">
    <xsl:param name="rawType"/>
    <xsl:variable name="lowercaseType" select="lower-case($rawType)"/>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:element name="dc:type">
      <xsl:choose>
        <xsl:when test="contains($lowercaseType, 'still') or
          contains($lowercaseType, 'photograph') or
          contains($lowercaseType, 'map') or
          $lowercaseType = concat('children', $apos, 's art') or
          $rawType = 'image' or
          contains($lowercaseType, 'postcard') or
          contains($lowercaseType, 'engraving') or
          contains($lowercaseType, 'book plate') or
          contains($lowercaseType, 'lithograph') or
          contains($lowercaseType, 'etching') or
          contains($lowercaseType, 'print') or
          contains($lowercaseType, 'book label') or
          contains($lowercaseType, 'cartographic') or
          contains($lowercaseType, 'portrait') or
          contains($lowercaseType, 'drawing') or
          contains($lowercaseType, 'tint') or
          contains($lowercaseType, 'poster') or
          contains($lowercaseType, 'sketch') or
          contains($lowercaseType, 'visual') or
          contains($lowercaseType, 'clipping') or
          contains($lowercaseType, 'plan') or
          contains($lowercaseType, 'elevation') or
          contains($lowercaseType, 'negative') or
          contains($lowercaseType, 'book stamp') or
          contains($lowercaseType, 'woodcut') or
          contains($lowercaseType, 'broadside') or
          contains($lowercaseType, 'slide') or
          contains($lowercaseType, 'painting')">
          <xsl:text>Image</xsl:text>
        </xsl:when>
        <xsl:when test="$rawType = 'text' or
          contains($lowercaseType, 'written') or
          contains($lowercaseType, 'newspaper') or
          contains($lowercaseType, 'typeset') or
          contains($lowercaseType, 'document') or
          contains($lowercaseType, 'monograph') or
          contains($lowercaseType, 'letter') or
          contains($lowercaseType, 'script') or
          contains($lowercaseType, 'pamphlet') or
          contains($lowercaseType, ' book') or
          contains($lowercaseType, 'yearbook') or
          $lowercaseType = 'book' or
          contains($lowercaseType, 'notated music') or
          contains($lowercaseType, 'periodical') or
          contains($lowercaseType, 'bill')">
          <xsl:text>Text</xsl:text>
        </xsl:when>
        <xsl:when test="contains($lowercaseType, 'physical') or
          contains($lowercaseType, 'realia') or
          contains($lowercaseType, 'object')">
          <xsl:text>Physical Object</xsl:text>
        </xsl:when>
        <xsl:when test="contains($lowercaseType, 'sound') or
          contains($lowercaseType, 'audio') or
          contains($lowercaseType, 'oral')">
          <xsl:text>Sound</xsl:text>
        </xsl:when>
        <xsl:when test="contains($lowercaseType, 'moving') or
          contains($lowercaseType, 'video')">
          <xsl:text>Moving Image</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$rawType"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
