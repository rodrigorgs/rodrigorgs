<xsl:stylesheet version = '1.0'
     xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
<!--
     version = '2.0'
     xmlns:dyn="http://exslt.org/dynamic"
     extension-element-prefixes="dyn">
-->

<!--
********************************************
ROOT
********************************************
-->
<xsl:template match="/gxl/graph">
	<xsl:text>
INCLUDE "conformance.hi.ta" :

FACT TUPLE :
	</xsl:text>
	<xsl:apply-templates select="node" mode="instance"/>
<xsl:text>

</xsl:text>
	<xsl:apply-templates select="edge"/>
<xsl:text>

FACT ATTRIBUTE :

</xsl:text>
	<xsl:apply-templates select="node" mode="attribute"/>
</xsl:template>

<!--
********************************************
NODE TYPES (instances)
********************************************
-->
<xsl:template match="node" mode="instance">
$INSTANCE <xsl:value-of select="@id"/><xsl:text> </xsl:text> <xsl:value-of select="attr[@name='type']/string"/>

</xsl:template>

<!--
********************************************
RELATIONS
********************************************
-->
<xsl:template match="edge">
	<xsl:variable name="type" select="attr[@name='type']/string"/>
	<xsl:variable name="ent1" select="@from"/>
	<xsl:variable name="ent2" select="@to"/>
<xsl:value-of select="concat($type, ' ', $ent1, ' ', $ent2)"/>
<xsl:text>
</xsl:text>
</xsl:template>

<!--
********************************************
NODE ATTRIBUTES
********************************************
-->
<xsl:template match="node" mode="attribute">
<xsl:value-of select="@id"/><xsl:text> { </xsl:text>
  label = "<xsl:value-of select="attr[@name='label']/string"/>"
  shortlabel = "<xsl:value-of select="attr[@name='shortlabel']/string"/>"
<xsl:text>}

</xsl:text>
</xsl:template>
<!--
<xsl:template match="node[@id]/attr[@name='type']/string[text()='package']">
	<xsl:value-of select="attr[@name='label']/string/text()"/>
</xsl:template>
-->

</xsl:stylesheet>
