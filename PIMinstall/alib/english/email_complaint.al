{
 name: email_complaint;
 rows_number: 40;
 
 history_text_body_to_respondent: Complaint history updated, id = %%id%%;
 history_subject_to_respondent: Complaint %%id%%: %%status%%;
 history_text_body_to_editor: Complaint history updated, id = %%id%%;
 history_subject_to_editor: Complaint %%id%%: %%status%%;
 history_text_body_to_sender_waiting: Complaint history updated, id = %%id%%;
 history_subject_to_sender_waiting: Complaint %%id%%: %%status%%;
 history_text_body_to_sender_close: Complaint history updated, id = %%id%%;
 history_subject_to_sender_close: Complaint %%id%%: %%status%%;
 
 post_text_body: New complaint posted, id = %%id%%;
 post_subject: Complaint %%id%%: new;

 updated_text_body: New complaint posted, id = %%id%%;
 updated_subject: Complaint %%id%%: new;
 
 history_header:
  <table border=0 width="740" align=center><tr>
 <td align=left><b>History log</b></td>
 </tr></table>
 
 history_begin:
  <table class="complaint_table1" cellpadding=1 cellspacing=1 border=0 width="740" align=center>
 <tr><td>
 <table class="complaint_table2" cellpadding=1 cellspacing=1 border=0 width="740" align=center>


 history_end:
   </table>
 </td></tr>
 </table>


 history_row:
   <tr>
     <td  class="complaint_td1" rowspan=2 width=200 valign=top>
			<table class="complaint_table2" cellpadding=1 cellspacing=1 border=0 width=100%>
			<tr><td><b>Author</b></td><td>%%history_from_name%%&nbsp;(%%history_from_email%%)</td></tr>
      <tr><td><b>Status</b></td><td>%%history_status%%</td></tr>
      <tr><td><b>Date</b></td><td><i> %%history_date%%</i></td></tr>
			</table>
     </td>
     <td class="complaint_td2" valign=top>
      <b>Subject</b> <i>%%history_subj%%</i>
     </td>
		</tr>
		<tr>
		 <td class="complaint_td2" valign=top>
		  <div align='justify'>%%history_mess%%</div>
		 </td>
		</tr>

body:
 <html>
 <title>ICEcat complaint history</title>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <LINK  href="%%icecat_hostname%%main.css" rel=stylesheet type=text/css>
 <body>
 <table border=0 width="740" align=center><tr>
 <td align=left><b>Complaint details</b></td>
 </tr></table>
 <table class="complaint_table1" cellpadding=1 cellspacing=1 border=0 width="740" align=center>
  <tr>
	 <td class=complaint_td1 rowspan=2 width=200 valign=top>
	 <table class="complaint_table2" cellpadding=1 cellspacing=1 border=0>
	   <tr><td><b>Editor</b></td><td>%%to_name%%&nbsp;</td></tr>
		 <tr><td><b>From</b></td><td>%%from_name%%(%%from_email%%)&nbsp;</td></tr>
		 <tr><td><b>Company</b></td><td>%%company%%&nbsp;</td></tr>
		 <tr><td><b>Product</b></td><td> %%prodid%%(%%supplier_name%%)</td></tr>
		 <tr><td><b>Status</b></td><td> %%status%%</td></tr>
		 <tr><td><b>Date</b></td><td><i>%%date%%</i></td></tr>		 
	 </table>
	 </td>
	 <td class="complaint_td2" valign=top>
	   <b>Subject:</b> %%subject%%
	 </td>
	</tr>
	<tr>
	 <td class="complaint_td2" valign=top>
		<div align='justify'>%%message%%</div>
	 </td>
	</tr>
 </table>
 <br>
 
 %%history_header%%
 %%history_begin%%
 %%history_rows%%
 %%history_end%%

 </body></html>
}
