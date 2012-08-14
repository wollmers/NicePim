{
name: product_update_localizations_howto;

body:

<center><h2>Patterns how-to</h2></center>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pattern's syntax looks like a <a href="http://search.cpan.org/search?query=perlre&mode=all">Perl regular expression</a> (metasymbols and modificators), but a bit simple\:
<table border="0" cellpadding="15" cellspacing="0" width="100%"><tr><td>

      <table border="0" cellpadding="3" cellspacing="0" width="100%">

<tr>
<th class="th-norm" width="20%">Modificators</th>
<th class="th-dark" width="*">Meaning</th>
</tr>
<td class="main info_bold" align="center">\{n\}</td>
<td class="main info_bold">
Match exactly n times
</td>
</tr>
<tr>
<td class="main info_bold" align="center">*</td>
<td class="main info_bold">
Match 0 or more times
</td>
</tr>
<tr>
<td class="main info_bold" align="center">+</td>
<td class="main info_bold">
Match 1 or more times
</td>
</tr>
<tr>
<td class="main info_bold" align="center">?</td>
<td class="main info_bold">
Match 0 or 1 times
</td>
</tr>
<tr>
<th class="th-norm">Metasymbols</th>
<th class="th-dark">Meaning</th>
</tr>
<tr>
<td class="main info_bold" align="center">\</td>
<td class="main info_bold">
Quote the next metacharacter
</td>
</tr>
<tr>
<td class="main info_bold" align="center">^</td>
<td class="main info_bold">
Match the beginning of the line
</td>
</tr>
<tr>
<td class="main info_bold" align="center">.</td>
<td class="main info_bold">
Match any character (expect newline)
</td>
</tr>
<tr>
<td class="main info_bold" align="center">$</td>
<td class="main info_bold">
Match the end of the line (or before newline at the end)
</td>
</tr>
<tr>
<td class="main info_bold" align="center">|</td>
<td class="main info_bold">
Alternation
</td>
</tr>
<tr>
<td class="main info_bold" align="center">()</td>
<td class="main info_bold">
Grouping
</td>
</tr>
<tr>
<td class="main info_bold" align="center">[]</td>
<td class="main info_bold">
Character class
</td>
</tr>
<tr>
<td class="main info_bold" align="center">\w</td>
<td class="main info_bold">
Match a "word" character (alphanumeric plus "_")
</td>
</tr>
<tr>
<td class="main info_bold" align="center">\d</td>
<td class="main info_bold">
Match a digit character
</td>
</tr>
</table>
</td></tr>
</table>
<i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Examples:</i><br>
<table border="0" cellpadding="15" cellspacing="0" width="100%"><tr><td>

      <table border="0" cellpadding="3" cellspacing="0" width="100%">

<tr>
<th class="th-norm" width="20%">Pattern</th>
<th class="th-dark" width="*">Meanings</th>
</tr>
<tr><td class="main info_bold" align="center"><b>\w</b></td><td class="main info_bold"><i>a, b, c, d, e, f, g, 1, 2, 3, 4, 5, 6, _...</i></td></tr>
<tr><td class="main info_bold" align="center"><b>\w*</b></td><td class="main info_bold"><i>a, aa, ab, abcdefg, 1, 12, a1, _a1, _a1b2, ___abcde12345...</i></td></tr>
<tr><td class="main info_bold" align="center"><b>\w\{3\}bcd</b></td><td class="main info_bold"><i>aaabcd, bcdbcd, 123bcd, ___bcd...</i></td></tr>
<tr><td class="main info_bold" align="center"><b>abcd\w*</b></td><td class="main info_bold"><i>abcd, abcda, abcdabcd, abcdefg ,abcd1 ,abcd12...</i></td></tr>
<tr><td class="main info_bold" align="center"><b>[xyz-]+\d\{3\}</b></td><td class="main info_bold"><i>x123, y456, z987, -x306, xxy--z-x631...</i></td></tr>
</table>
</td></tr>
</table>

}
