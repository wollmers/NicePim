{
name: email_editor_journal;
class: default;

lang_text: %%lang%% Marketing texts;
lang_text_4active:  %%lang%% Marketing texts for active products:;

email_body_text:
Period\: %%period%%
%%texts%%

%%texts4active%%
;

email_body_html:
<table width=100% cellpadding="3" cellspacing="1" width="100%" bgcolor='#999999'>
<tr><td colspan=2 bgcolor="#D8D8D8"><b>Period\: %%period%%</b></td></tr>
<tr><td colspan=2 bgcolor="#FFFFFF"><br><br></td></tr>
%%texts4active%%

%%texts%%

</table>

}