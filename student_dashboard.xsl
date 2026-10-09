<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Lookup keys: find a lecturer by id, and all enrolments for a course code -->
    <xsl:key name="lecturerById" match="lecturer" use="@id"/>
    <xsl:key name="enrolmentsByCourse" match="enrolment" use="@courseCode"/>

    <!-- ============ MAIN TEMPLATE: builds the whole page ============ -->
    <xsl:template match="/">
        <html>
        <head>
            <meta charset="UTF-8"/>
            <title>University Academic Dashboard</title>
            <style>
                body { font-family: Arial, Helvetica, sans-serif; background: #f3f5f9; color: #222; margin: 0; padding: 24px; }
                .wrap { max-width: 1000px; margin: 0 auto; }
                h1 { color: #1f3a6e; margin-bottom: 2px; }
                .sub { color: #666; margin-top: 0; margin-bottom: 20px; }
                h2 { color: #1f3a6e; border-bottom: 2px solid #2e5395; padding-bottom: 4px; margin-top: 34px; }
                table.cards { border-collapse: separate; border-spacing: 10px 0; margin: 0 -10px 10px -10px; }
                table.cards td { background: #fff; border: 1px solid #d5dbe8; border-radius: 6px; padding: 12px 22px; text-align: center; }
                .num { font-size: 26px; font-weight: bold; color: #2e5395; display: block; }
                .lbl { font-size: 12px; color: #666; }
                table.data { border-collapse: collapse; width: 100%; background: #fff; }
                table.data th { background: #2e5395; color: #fff; text-align: left; padding: 8px 10px; font-size: 13px; }
                table.data td { padding: 7px 10px; border-bottom: 1px solid #e3e7ef; font-size: 13px; }
                table.data tr:nth-child(even) td { background: #f8f9fc; }
                .badge { padding: 2px 9px; border-radius: 10px; font-size: 12px; font-weight: bold; }
                .excellent { background: #d9f2e1; color: #17653a; }
                .verygood { background: #dcebfa; color: #1b4f8c; }
                .good { background: #e8f1d6; color: #4b6b17; }
                .satisfactory { background: #fdf0d2; color: #8a5d00; }
                .atrisk { background: #fadcdc; color: #a11d1d; }
                .note { color: #666; font-size: 12px; margin-top: 6px; }
                .empty { color: #a11d1d; font-style: italic; }
            </style>
        </head>
        <body>
        <div class="wrap">
            <h1>University Academic Dashboard</h1>
            <p class="sub">
                <xsl:value-of select="academicRecords/@university"/> &#8226;
                Academic records <xsl:value-of select="academicRecords/@year"/>
            </p>

            <!-- ========== Summary cards (XPath functions: count, sum, div) ========== -->
            <table class="cards"><tr>
                <td><span class="num"><xsl:value-of select="count(academicRecords/students/student)"/></span><span class="lbl">Students</span></td>
                <td><span class="num"><xsl:value-of select="count(academicRecords/programmes/programme)"/></span><span class="lbl">Programmes</span></td>
                <td><span class="num"><xsl:value-of select="count(academicRecords/courses/course)"/></span><span class="lbl">Courses</span></td>
                <td><span class="num"><xsl:value-of select="count(academicRecords/lecturers/lecturer)"/></span><span class="lbl">Lecturers</span></td>
                <td><span class="num"><xsl:value-of select="format-number(sum(academicRecords/students/student/gpa) div count(academicRecords/students/student), '0.00')"/></span><span class="lbl">Average GPA</span></td>
                <td><span class="num"><xsl:value-of select="count(academicRecords/students/student[gpa &lt; 2.00])"/></span><span class="lbl">At Risk</span></td>
            </tr></table>

            <!-- ========== TASK 2: Student performance table (sorted by GPA, highest first) ========== -->
            <h2>1. Student Performance Dashboard</h2>
            <table class="data">
                <tr>
                    <th>ID</th><th>Student</th><th>Programme</th><th>Year</th><th>GPA</th><th>Performance</th>
                </tr>
                <xsl:for-each select="academicRecords/students/student">
                    <!-- primary sort: GPA descending; secondary sort: name A-Z to break ties -->
                    <xsl:sort select="gpa" data-type="number" order="descending"/>
                    <xsl:sort select="name" data-type="text" order="ascending"/>
                    <tr>
                        <td><xsl:value-of select="@id"/></td>
                        <td><xsl:value-of select="name"/></td>
                        <td><xsl:value-of select="programme"/></td>
                        <td><xsl:value-of select="academicYear"/></td>
                        <td><xsl:value-of select="gpa"/></td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="gpa &gt;= 3.70"><span class="badge excellent">Excellent</span></xsl:when>
                                <xsl:when test="gpa &gt;= 3.30"><span class="badge verygood">Very Good</span></xsl:when>
                                <xsl:when test="gpa &gt;= 3.00"><span class="badge good">Good</span></xsl:when>
                                <xsl:when test="gpa &gt;= 2.00"><span class="badge satisfactory">Satisfactory</span></xsl:when>
                                <xsl:otherwise><span class="badge atrisk">At Risk</span></xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
            <p class="note">Excellent &#8805; 3.70 &#8226; Very Good 3.30&#8211;3.69 &#8226; Good 3.00&#8211;3.29 &#8226; Satisfactory 2.00&#8211;2.99 &#8226; At Risk &lt; 2.00</p>

            <!-- ========== TASK 3: Data Science students with GPA >= 3.50 ==========
                 Filtering is done directly in the XPath predicate (not xsl:if) so that only the
                 matching nodes ever enter the loop; xsl:if is used only for the "nothing found" message. -->
            <h2>2. Data Science Students with GPA &#8805; 3.50</h2>
            <xsl:variable name="topDS" select="academicRecords/students/student[programme='Data Science' and gpa &gt;= 3.50]"/>
            <xsl:if test="count($topDS) = 0">
                <p class="empty">No Data Science students currently meet the 3.50 GPA threshold.</p>
            </xsl:if>
            <xsl:if test="count($topDS) &gt; 0">
                <table class="data">
                    <tr><th>Student ID</th><th>Name</th><th>GPA</th><th>Academic Year</th></tr>
                    <xsl:for-each select="$topDS">
                        <xsl:sort select="gpa" data-type="number" order="descending"/>
                        <tr>
                            <td><xsl:value-of select="@id"/></td>
                            <td><xsl:value-of select="name"/></td>
                            <td><xsl:value-of select="gpa"/></td>
                            <td><xsl:value-of select="academicYear"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p class="note"><xsl:value-of select="count($topDS)"/> of <xsl:value-of select="count(academicRecords/students/student[programme='Data Science'])"/> Data Science students qualify.</p>
            </xsl:if>

            <!-- ========== Course catalogue: template-based processing (apply-templates) ========== -->
            <h2>3. Course Catalogue</h2>
            <table class="data">
                <tr><th>Code</th><th>Course</th><th>Credits</th><th>Lecturer</th><th>Enrolled</th><th>Average Marks</th></tr>
                <xsl:apply-templates select="academicRecords/courses/course">
                    <xsl:sort select="@code" data-type="text"/>
                </xsl:apply-templates>
            </table>
        </div>
        </body>
        </html>
    </xsl:template>

    <!-- ============ COURSE TEMPLATE: one table row per course ============ -->
    <xsl:template match="course">
        <tr>
            <td><xsl:value-of select="@code"/></td>
            <td><xsl:value-of select="title"/></td>
            <td><xsl:value-of select="@credits"/></td>
            <td><xsl:value-of select="key('lecturerById', @lecturerId)/name"/></td>
            <td><xsl:value-of select="count(key('enrolmentsByCourse', @code))"/></td>
            <td><xsl:value-of select="format-number(sum(key('enrolmentsByCourse', @code)/marks) div count(key('enrolmentsByCourse', @code)), '0.00')"/></td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
