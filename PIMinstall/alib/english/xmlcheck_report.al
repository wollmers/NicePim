{

scheduled_files:

<tr align="center">
<td align="left"><font color="green">%%filename%%</font></td>
<td>%%expire%%</td>
<td>%%zerosize%%</td>
<td>%%indexfile%%</td>
<td>%%dtdvalid%%</td>
<td>%%xsdvalid%%</td>
<td>%%checklinks%%</td>
</tr>

expire:
<tr><td><font color="green">%%file%%</font></td><td><font color="red">has expired</font>&nbsp;%%hours%%&nbsp;hours ago</td></tr>

ahead:
<tr><td><font color="green">%%file%%</font></td><td>%%hours%%&nbsp;hours ahead</td></tr>

behind:
<tr><td><font color="green">%%file%%</font></td><td>%%hours%%&nbsp;hours behind</td></tr>

zerosize:
<tr><td><font color="green">%%file%%</font></td><td><font color="red">zero size</font></td></tr>

absentfile:
<tr><td><font color="green">%%file%%</font></td><td><font color="red">is absent</font></td></tr>

dtdvalid:
<tr><td><font color="green" size="-1">%%file%%</font></td><td><font color="red" size="-1">validation falied</font></td><td><i><font size="-1">%%reason%%</font></i></td></tr>

xsdvalid:
<tr><td><font color="green" size="-1">%%file%%</font></td><td><font color="red" size="-1">validation falied</font></td><td><i><font size="-1">%%reason%%</font></i></td></tr>


syntaxerror:
<tr><td><font color="green" size="-1">%%file%%</font></td><td><font color="red" size="-1">syntax error</font></td><td><i><font size="-1">%%reason%%</font></i></td></tr>

checklinks:
<tr><td><nobr><font color="green" size="-1">%%file%%</font></nobr></td><td><font color="red" size="-1">%%error%%</font></td><td><nobr><font size="-1">%%reason%%</font></nobr></td></tr>

body:
<html>

<head><title>XMLCheck Report</title>
</head>

<body>
<h2>XMLCheck Report</h2><br>
<b>Scheduled files are\:</b><br>
<table border="1">
<tr>
<th>XML file</th>
<th>expiration (in hours)</th>
<th>zerosize</th>
<th>files.index.xml</th>
<th>DTD validation</th>
<th>XSD validation</th>
<th>check links</th>
</tr>
	%%scheduled_files%%
</table><br><br>

<b>Total XML files\:&nbsp;<font color="blue">%%total%%</font></b><br>
OK XML files\:&nbsp;<font color="blue">%%ok%%</font><br>
Empty XML files\:&nbsp;<font color="blue">%%empty%%</font><br>
Absent XML files\:&nbsp;<font color="blue">%%absent%%</font><br><br>

<br><b><font color="blue">Expirations\:</font></b><br><br>
<table border="1" align="100%">
<tr>
<th>XML file</th>
<th>expiration</th>
</tr>
%%expire%%
%%ahead%%
%%behind%%
</table>

<br><b><font color="blue">Zero sizes / Absent\:</font></b><br><br>
<table border="1" align="100%">
<tr>
<th>XML file</th>
<th>reason</th>
</tr>
%%absentfile%%
%%zerosize%%
</table>

<br><b><font color="blue">Syntax errors / DTD validation results\:</font></b><br><br>
<table border="1" align="100%">
<tr>
<th>XML file</th>
<th>error</th>
<th>reason</th>
</tr>
%%syntaxerror%%
%%dtdvalid%%
</table>

<br><b><font color="blue">Syntax errors / XSD validation results\:</font></b><br><br>
<table border="1" align="100%">
<tr>
<th>XML file</th>
<th>error</th>
<th>reason</th>
</tr>
%%syntaxerror%%
%%dtdvalid%%
</table>

<br><b><font color="blue">Checking links\:</font></b><br><br>
<table border="1" align="100%">
<tr>
<th>XML file</th>
<th>error</th>
<th>link</th>
</tr>
%%checklinks%%
</table>
</body>

</html>

}
