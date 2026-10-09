<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Output is XML (not HTML): this simulates sending data to a second university system -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <learners>
            <xsl:for-each select="academicRecords/students/student">
                <learner>
                    <registrationNumber><xsl:value-of select="@id"/></registrationNumber>
                    <fullName><xsl:value-of select="name"/></fullName>
                    <degreeProgramme><xsl:value-of select="programme"/></degreeProgramme>
                    <academicPerformance>
                        <xsl:choose>
                            <xsl:when test="gpa &gt;= 3.70">Excellent</xsl:when>
                            <xsl:when test="gpa &gt;= 3.30">Very Good</xsl:when>
                            <xsl:when test="gpa &gt;= 3.00">Good</xsl:when>
                            <xsl:when test="gpa &gt;= 2.00">Satisfactory</xsl:when>
                            <xsl:otherwise>At Risk</xsl:otherwise>
                        </xsl:choose>
                    </academicPerformance>
                </learner>
            </xsl:for-each>
        </learners>
    </xsl:template>

</xsl:stylesheet>
