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
    Matches to each dc:format and dcterms:medium fields in record
    Tokenizes delimited values, passing each token to a template that deploys subsequent normalization templates
    Non-delimited values are passed to the normalization-deploying template
  -->
  <xsl:template match="dc:format|dcterms:medium">
    <xsl:choose>
      <xsl:when test="contains(., ';')">
        <xsl:for-each select="tokenize(., ';')">
          <xsl:call-template name="delAndNorm">
            <xsl:with-param name="toDelAndNorm" select="."/>
            <xsl:with-param name="formatOrType" select="'format'"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="delAndNorm">
          <xsl:with-param name="toDelAndNorm" select="."/>
          <xsl:with-param name="formatOrType" select="'format'"/>
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
          <xsl:call-template name="aatFormat">
            <xsl:with-param name="rawFormat" select="normalize-space($testedForDel)"/>
          </xsl:call-template>
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
        contains($lowercase, 'mp4') or
        contains($lowercase, 'm4v') or
        contains($lowercase, 'wav') or
        contains($lowercase, 'boys in blue logan') or
        contains($lowercase, 'ill.') or
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
       Template for normalizing format and medium
       Capitalizes all format and medium values; removes all other case
       Catches most extent values creates a new dcterms:extent field for values
       Matches raw format data with an AAT value 
  -->
  <xsl:template name="aatFormat">
    <xsl:param name="rawFormat"/>
    <xsl:variable name="capFormat" select="concat(upper-case(substring($rawFormat,1,1)),
      lower-case(substring($rawFormat, 2)))"/>
    <xsl:variable name="lowercaseFormat" select="lower-case($rawFormat)"/>
    <xsl:choose>
      <xsl:when test="contains($lowercaseFormat, 'size') or 
        contains($lowercaseFormat, 'height') or 
        contains($lowercaseFormat, 'width') or 
        contains($lowercaseFormat, 'depth') or 
        contains($lowercaseFormat, 'weight') or 
        contains($lowercaseFormat, 'diameter')">
        <xsl:element name="dcterms:extent">
          <xsl:value-of select="$rawFormat"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'photo'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Photographs</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'negative' or
        $lowercaseFormat = 'negatives' or
        (contains($lowercaseFormat, 'negative') and 
        contains($lowercaseFormat, 'photo') and 
        not(contains($lowercaseFormat, 'color')) and 
        not(contains($lowercaseFormat, 'black')))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Negatives (photographs)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'photograph' or
        $lowercaseFormat = 'photograph (all forms)'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Photographs</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Image</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'black') and 
        contains($lowercaseFormat, 'print') and 
        not(contains($lowercaseFormat, 'color'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white prints (photographs)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'black') and 
        contains($lowercaseFormat, 'negative')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white negatives</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'print'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Prints (visual works)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'photo') and 
        contains($lowercaseFormat, 'print') and 
        not(contains($lowercaseFormat, 'color')) and 
        not(contains($lowercaseFormat, 'black')) and 
        not(contains($lowercaseFormat, 'negative')) and 
        not(contains($lowercaseFormat, 'paper'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Photographic prints</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'water')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Watercolors (paintings)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'black') and 
        contains($lowercaseFormat, 'photo') and 
        contains($lowercaseFormat, 'mat board')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white photographs; Mat board</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="(contains($lowercaseFormat, 'black') or
        contains($lowercaseFormat, 'b &amp; w') or
        contains($lowercaseFormat, 'b&amp;w') or 
        contains($lowercaseFormat, 'b and w')) and
        contains($lowercaseFormat, 'photo') and
        not(contains($lowercaseFormat, 'print')) and
        not(contains($lowercaseFormat, 'negative')) and
        not(contains($lowercaseFormat, 'photography'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white photographs</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'color') and
        contains($lowercaseFormat, 'negative')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Color negatives</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'drawing' or
        (contains($lowercaseFormat, 'color') and contains($lowercaseFormat, 'drawing')) or
        (contains($lowercaseFormat, 'drawing') and contains($lowercaseFormat, 'visual')) or
        (contains($lowercaseFormat, 'mono') and contains($lowercaseFormat, 'drawing'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Drawings (visual works)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'etching')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Etchings (prints)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'engraving')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Engravings (prints)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'music') and 
        contains($lowercaseFormat, 'text')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Sheet music</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'correspondence'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Correspondence</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Text</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'survey'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Surveys (documents)</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Text</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'digital'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Digital images</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'manuscript' or
        $lowercaseFormat = 'manuscripts'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Manuscripts (documents)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'architectural') and 
        contains($lowercaseFormat, 'drawing')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Architectural drawings (visual works)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'photo') and 
        contains($lowercaseFormat, 'color') and 
        contains($lowercaseFormat, 'print')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Color prints (photographs)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'newspaper') and 
        not(contains($lowercaseFormat, 'article')) and 
        not(contains($lowercaseFormat, 'clipping'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Newspapers</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'periodical')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Periodicals</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Text</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'woodcut')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Woodcuts (prints)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'genealog')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Genealogies (histories)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'fraktur')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Frakturs (documents)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'letter' or
        $lowercaseFormat = 'letters' or
        (contains($lowercaseFormat, 'manuscript') and contains($lowercaseFormat, 'letter'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Letters (correspondence)</xsl:text>
        </xsl:element>
      </xsl:when>
        <xsl:when test="contains($lowercaseFormat, 'postcard')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Postcards</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Image</xsl:text>
        </xsl:element>
      </xsl:when>
        <xsl:when test="contains($lowercaseFormat, 'gelatin') and 
          contains($lowercaseFormat, 'silver')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Gelatin silver prints</xsl:text>
        </xsl:element>
      </xsl:when>
        <xsl:when test="contains($lowercaseFormat, 'black') and 
          contains($lowercaseFormat, 'color') and 
          not(contains($lowercaseFormat, 'print')) and 
          not(contains($lowercaseFormat, 'water'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white photographs; Color photographs</xsl:text>
        </xsl:element>
      </xsl:when>
        <xsl:when test="contains($lowercaseFormat, 'print') and 
          contains($lowercaseFormat, 'material') and 
          contains($lowercaseFormat, 'other')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Printed materials (other)</xsl:text>
        </xsl:element>
      </xsl:when>
        <xsl:when test="contains($lowercaseFormat, 'glass') and 
          contains($lowercaseFormat, 'negative')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Glass plate negatives</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'wood'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Wood (plant material)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'albumen') and 
        contains($lowercaseFormat, 'print')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Albumen prints</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'artist') and 
        contains($lowercaseFormat, 'rendering')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Renderings (drawings)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'photography'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Photography (process)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'reel') and 
        contains($lowercaseFormat, 'audio')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Open reel audiotapes</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'print') and 
        contains($lowercaseFormat, 'publication')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Publications (documents)</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Text</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'illustrated work')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Illustrated works (documents)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'color') and 
        contains($lowercaseFormat, 'photo') and 
        not(contains($lowercaseFormat, 'hand')) and 
        not(contains($lowercaseFormat, 'digital'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Color photographs</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Image</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'map') and 
        not(contains($lowercaseFormat, 'maple'))">
        <xsl:element name="dcterms:medium">
          <xsl:text>Maps (documents)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'paint'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Paint (coating)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'military document')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Military records</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'pamphlet')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Pamphlets</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'pastel (chalk)')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Pastels (crayons)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'silk'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Silk (textile)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'vertical file')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Vertical files</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'photo') and 
        contains($lowercaseFormat, 'print') and 
        contains($lowercaseFormat, 'paper')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Photographic prints; Paper</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'aerial') and 
        contains($lowercaseFormat, 'photo')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Aerial photographs</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'photo') and 
        contains($lowercaseFormat, 'color') and 
        contains($lowercaseFormat, 'hand')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Hand coloring; Color photographs</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'artwork')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Works of art</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'painting' or
        $lowercaseFormat = 'paintings'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Paintings (visual works)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'audio') and 
        contains($lowercaseFormat, 'cassette')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Audiocassettes</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'color') and 
        contains($lowercaseFormat, 'photo') and 
        contains($lowercaseFormat, 'digital')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Color photographs; Digital photographs</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'diar')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Diaries</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'collage' or
        $lowercaseFormat = 'collages'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Collages (visual works)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'digital photo' or
        $lowercaseFormat = 'digital photograph'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Digital photographs</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'photogravure')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Photogravures (prints)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="(contains($lowercaseFormat, 'black') or
        contains($lowercaseFormat, 'b &amp; w') or
        contains($lowercaseFormat, 'b&amp;w') or
        contains($lowercaseFormat, 'b and w')) and
        contains($lowercaseFormat, 'photography')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white photography</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'business') and
        contains($lowercaseFormat, 'correspond')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Commercial correspondence</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'newsletter')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Newsletters</xsl:text>
        </xsl:element>
        <xsl:element name="dc:type">
          <xsl:text>Text</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'fabric' or
        $lowercaseFormat = 'fabrics'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Cloth</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'string' or
        $lowercaseFormat = 'strings'">
        <xsl:element name="dcterms:medium">
          <xsl:text>String (fiber product)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($lowercaseFormat, 'black') and
        contains($lowercaseFormat, 'color') and
        contains($lowercaseFormat, 'print')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Black-and-white prints (photographs); Color prints (photographs)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'oil painting' or
        contains($lowercaseFormat, 'oil paintings')">
        <xsl:element name="dcterms:medium">
          <xsl:text>Oil paintings (visual works)</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$lowercaseFormat = 'book'">
        <xsl:element name="dcterms:medium">
          <xsl:text>Books</xsl:text>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="dcterms:medium">
          <xsl:value-of select="$capFormat"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Attempts to match raw type data with a DCMI Type value -->
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
