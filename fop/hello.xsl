<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!-- Page layout information -->
  <xsl:template match="/">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <fo:layout-master-set>
        <fo:simple-page-master master-name="main" page-height="29.7cm" page-width="21cm" font-family="sans-serif" margin-top="1.0cm" margin-bottom="1.2cm" margin-left="1.8cm" margin-right="1.8cm">
          <fo:region-body margin-top="0cm" margin-bottom="0cm"/>
          <fo:region-before extent="0cm"/>
        </fo:simple-page-master>
      </fo:layout-master-set>
      <fo:page-sequence master-reference="main">
        <fo:flow flow-name="xsl-region-body">
          <xsl:apply-templates select="GetExtractByIdResponse/Extract"/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
  <xsl:template match="GetExtractByIdResponse/Extract">
    <fo:block>
Hallo <xsl:value-of select="ConcernedTheme/Code"/>
</fo:block>
  </xsl:template>
</xsl:stylesheet>
