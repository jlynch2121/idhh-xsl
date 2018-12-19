<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:default="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0"
  xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oai_qdc="http://worldcat.org/xmlschemas/qdc-1.0/"
  xmlns:oaiProvenance="http://www.openarchives.org/OAI/2.0/provenance">

   <!-- 
       This section is the Identity transform that generates a document equal to the input document.
	-->

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node() | @*">

    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>

  </xsl:template>
  
  <!-- 
    This code matches to each dc:type field in record, normalizes delimiters to semicolons
    It then tokenizes delimited values, passing each token to a template that will try to match it to a DCMI Type
    It will simply pass a non-delimited value to the template that will attempt to match it to a DCMI Type
  -->
  <xsl:template match="dc:type">
    <xsl:variable name="typeValue" select="normalize-space(replace(., ',', ';'))"/>
    <xsl:choose>
      <xsl:when test="contains($typeValue, ';')">
        <xsl:for-each select="tokenize($typeValue, ';')">
          <xsl:if test="not(.='')">
            <xsl:call-template name="dcmiTypeVocab">
              <xsl:with-param name="rawType" select="normalize-space(.)"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="dcmiTypeVocab">
          <xsl:with-param name="rawType" select="$typeValue"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
    <!-- 
      Need to think of a way to eliminate duplicate field/value pairs, which will often be produced by the current code. 
      For example, if a field contains 'text; newspaper', this will create two fields, each containing 'Text'.
    -->
  <xsl:template name="dcmiTypeVocab">
    <xsl:param name="rawType"/>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:choose>
    <!-- 
      Not sure if we should keep emptying fields of these values as MJ has been doing before or transform them. 
      If type fields containing this data are normally extra type fields for file format metadata, then transforms 
      will likely often result in duplicate values. Need to figure out if there is a significant number of the values 
      this is designed to catch and understand how they appear, esp. either alone or together. Try looking for 
      blank values in JSON.
    -->
      <xsl:when test="contains(lower-case($rawType), 'pdf') or
        contains(lower-case($rawType), 'jp') or
        contains(lower-case($rawType), 'tiff') or
        lower-case($rawType) = 'tif' or
        lower-case($rawType) = 'image/tif' or
        contains(lower-case($rawType), 'cpd') or
        lower-case($rawType) = 'n/a' or
        lower-case($rawType) = 'na' or
        contains(lower-case($rawType), 'gif') or
        contains(lower-case($rawType), 'mp3') or
        contains(lower-case($rawType), 'm4v')">
      </xsl:when>
      <!-- should map be converted to Image? -->
      <!-- Note there are a few issues with match to 'photo', including a handful items identified as photocopies that may actually be text. Similar issue with 'print' -->
      <xsl:when test="contains(lower-case($rawType), 'still') or 
        contains(lower-case($rawType), 'photo') or 
        contains(lower-case($rawType), 'map') or 
        lower-case($rawType) = concat('children', $apos, 's art') or 
        $rawType = 'image' or
        contains(lower-case($rawType), 'postcard') or 
        contains(lower-case($rawType), 'engraving') or
        contains(lower-case($rawType), 'lithograph') or
        contains(lower-case($rawType), 'etching') or
        contains(lower-case($rawType), 'print') or
        contains(lower-case($rawType), 'portrait') or
        contains(lower-case($rawType), 'drawing') or
        contains(lower-case($rawType), 'tint') or
        contains(lower-case($rawType), 'poster') or
        contains(lower-case($rawType), 'sketch') or
        contains(lower-case($rawType), 'visual')">
        <xsl:element name="dc:type">
          <xsl:text>Image</xsl:text>
        </xsl:element>
      </xsl:when>
      <!-- What to do with various items containing 'book'? Some appear to be physical objects, others text -->
      <xsl:when test="$rawType = 'text' or
        contains(lower-case($rawType), 'written') or
        contains(lower-case($rawType), 'newspaper') or
        contains(lower-case($rawType), 'typeset') or
        contains(lower-case($rawType), 'document') or
        contains(lower-case($rawType), 'monograph') or
        contains(lower-case($rawType), 'letter') or
        contains(lower-case($rawType), 'script') or
        contains(lower-case($rawType), 'pamphlet') or
        contains(lower-case($rawType), ' book') or
        contains(lower-case($rawType), 'yearbook') or
        lower-case($rawType) = 'book' or
        contains(lower-case($rawType), 'bill')">
        <xsl:element name="dc:type">
          <xsl:text>Text</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains(lower-case($rawType), 'physical') or
        contains(lower-case($rawType), 'realia')">
        <xsl:element name="dc:type">
          <xsl:text>Physical Object</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains(lower-case($rawType), 'sound') or
        contains(lower-case($rawType), 'audio')">
        <xsl:element name="dc:type">
          <xsl:text>Sound</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains(lower-case($rawType), 'moving') or
        contains(lower-case($rawType), 'video')">
        <xsl:element name="dc:type">
          <xsl:text>Moving Image</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="dc:type">
          <xsl:value-of select="$rawType"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
