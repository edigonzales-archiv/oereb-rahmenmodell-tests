<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:data="http://schemas.geo.admin.ch/swisstopo/OeREBK/15/ExtractData"
    
    version="2.0" >
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="firstPage" page-height="297mm" page-width="210mm">
                    <fo:region-body margin-top="25mm" />
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="firstPage">
                <fo:flow flow-name="xsl-region-body">
                    <xsl:apply-templates/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    <xsl:template match="data:Extract">
        <fo:block-container font-size="12pt" margin-left="5mm" margin-bottom="5mm">
            <xsl:apply-templates select="CreationDate"/>
        </fo:block-container>
    </xsl:template>
    <xsl:template match="CreationDate">
        <fo:block>
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>