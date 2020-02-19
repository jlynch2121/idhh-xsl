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
    Template matches language data
    For all fields that do not normally contain commas (e.g., 'Greek, Modern'), passes values to delimiter normalization template
    Tokenizes delimited values and passes them to lanugage normalization template, which will attempt to match values to an ISO language name
    Passes non-delimited values to language normalization template
  -->
  <xsl:template match="dc:language">
    <xsl:variable name="normalizedString">
      <xsl:choose>
        <xsl:when test="contains(lower-case(.),'greek') and
          contains(lower-case(.),'modern')">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="normalizeDelimiters">
            <xsl:with-param name="rawString" select="."/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($normalizedString, ';')">
        <xsl:for-each select="tokenize($normalizedString, ';')">
          <xsl:if test="not(.='')">
            <xsl:call-template name="normLang">
              <xsl:with-param name="rawLang" select="normalize-space(.)"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="normLang">
          <xsl:with-param name="rawLang" select="$normalizedString"/>
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
    Template for normalizing language
    Removes special characters (currently removes question mark ['?'])
    Deletes some commonly occurring invalid language values
    Attempts to match raw string with special characters removed to ISO 639 language names
   -->
  <xsl:template name="normLang">
    <xsl:param name="rawLang"/>
    <xsl:variable name="noSpecChars" select="replace($rawLang, '\?', '')"/>
    <xsl:variable name="lowercaseLang" select="lower-case($noSpecChars)"/>
    <xsl:choose>
      <xsl:when test="contains($lowercaseLang, 'image') or
        contains($lowercaseLang, 'photo') or
        contains($lowercaseLang, 'n/a') or
        contains($lowercaseLang, 'na') or
        contains($lowercaseLang, 'none')">
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'eng' or
        $lowercaseLang = 'en' or
        $lowercaseLang = 'en-english' or
        contains($lowercaseLang, '/eng') or
        $lowercaseLang = 'englsih' or
        contains($lowercaseLang, 'eng-us')">
        <xsl:element name="dc:language">
          <xsl:text>English</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'lat' or
        $lowercaseLang = 'la' or
        $lowercaseLang = 'laitn'">
        <xsl:element name="dc:language">
          <xsl:text>Latin</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'fre' or
        $lowercaseLang = 'fr'">
        <xsl:element name="dc:language">
          <xsl:text>French</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'ger' or
        $lowercaseLang = 'de'">
        <xsl:element name="dc:language">
          <xsl:text>German</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'swe' or
        $lowercaseLang = 'sv'">
        <xsl:element name="dc:language">
          <xsl:text>Swedish</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'spa' or
        $lowercaseLang = 'es' or
        $lowercaseLang = 'esp'">
        <xsl:element name="dc:language">
          <xsl:text>Spanish</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'jpn' or
        $lowercaseLang = 'ja'">
        <xsl:element name="dc:language">
          <xsl:text>Japanese</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'ita' or
        $lowercaseLang = 'it'">
        <xsl:element name="dc:language">
          <xsl:text>Italian</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'chi' or
        $lowercaseLang = 'zh'">
        <xsl:element name="dc:language">
          <xsl:text>Chinese</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'rus' or
        $lowercaseLang = 'ru'">
        <xsl:element name="dc:language">
          <xsl:text>Russian</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'swe' and
        $lowercaseLang = 'eng'">
        <xsl:element name="dc:language">
          <xsl:text>Swedish; English</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'vie' or
        $lowercaseLang = 'vi'">
        <xsl:element name="dc:language">
          <xsl:text>Vietnamese</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'eng' and
        $lowercaseLang = 'spa'">
        <xsl:element name="dc:language">
          <xsl:text>English; Spanish</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseLang, 'algonq')">
        <xsl:element name="dc:language">
          <xsl:text>Algonquian</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'dan' or
        $lowercaseLang = 'da'">
        <xsl:element name="dc:language">
          <xsl:text>Danish</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'ara' or
        $lowercaseLang = 'ar' or 
        contains($lowercaseLang, 'arabic')">
        <xsl:element name="dc:language">
          <xsl:text>Arabic</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="(contains($lowercaseLang, 'greek') and 
        contains($lowercaseLang, 'modern')) or 
        $lowercaseLang = 'gre' or 
        $lowercaseLang = 'el'">
        <xsl:element name="dc:language">
          <xsl:text>Greek, Modern (1453-)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseLang, 'greek') and 
        contains($lowercaseLang, 'ancient')">
        <xsl:element name="dc:language">
          <xsl:text>Ancient Greek (to 1453)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseLang, 'qu') and 
        contains($lowercaseLang, 'ch')">
        <xsl:element name="dc:language">
          <xsl:text>Quechua</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseLang = 'ltz' and
        $lowercaseLang = 'lb'">
        <xsl:element name="dc:language">
          <xsl:text>Luxembourgish</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="dc:language">
          <xsl:value-of select="$noSpecChars"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
