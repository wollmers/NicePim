<div id="patterns_howto" style="display\: none;">
<h3>Patterns how-to</h3>
<table class="invisible" cellpadding="3" cellspacing="0" width="100%" style="background-color: green;">
<tr>
<th class="th-norm" width="20%">Metasymbols</th>
<th class="th-dark" width="*">Description</th>
</tr>
<tr>
<td class="main info_bold" colspan="2"><b>left part of pattern\:</b></td>
</tr>
<tr>
<td class="main info_bold"><font color="blue">*</font></td>
<td class="main info_bold">any characters: <i>1, a, 123, abc, _@!#sdf3 ...</i></td>
</tr>
<tr>
<td class="main info_bold"><font color="blue">#</font></td>
<td class="main info_bold">any number: <i>1, 0, -5, 1/6, 3.2 ...</i></td>
</tr>
<tr>
<td class="main info_bold" colspan="2">If you want to use <font color="blue">*</font> and <font color="blue">#</font> in your patterns - quote them with <font color="blue">%</font>. Fo\
r example: <font color="blue">*</font> - is any characters, <font color="blue">%*</font> - is simple *, <font color="blue">#%#</font> - is any number# etc.</td>
</tr>
<tr>
<td class="main info_bold" colspan="2"><b>right part of pattern\:</b></td>
</tr>
<tr>
	<td class="main info_bold"><font color="blue">$&lt;number&gt;</font></td>
<td class="main info_bold">each metasymbol in the left part of pattern has its number<br>(we have <font color="blue">first # second * third # fourth</font>=<font color="blue">$1$2$3</f\
ont>, so, <font color="blue">#</font> - is <font color="blue">$1</font>, <font color="blue">*</font> - is <font color="blue">$2</font>, <font color="blue">#</font> - is <font co\
lor="blue">$3</font>)</td>
</tr>
<tr>
<td class="main info_bold" colspan="2"><b>Some examples\:</b></td>
</tr>
<tr>
<td class="main info_bold">#*-*#*=$1 - $4</td>
<td class="main info_bold">may be used for values\: <b>12 mm - 24 mm</b> converts to <b>12 - 24</b></td>
</tr>
<tr>
<td class="main info_bold">#,#=$1.$2</td>
<td class="main info_bold">may be used for values\: <b>1,4</b> converts to <b>1.4</b></td>
</tr>
<tr>
<td class="main info_bold">*#&deg; to #&deg; C*=$2 - $3</td>
	<td class="main info_bold">may be used for values\: <b>Temperature is\: 0&deg; to 10&deg; C</b> converts to <b>0 - 10</b></td>
</tr>
</table>
</div>
