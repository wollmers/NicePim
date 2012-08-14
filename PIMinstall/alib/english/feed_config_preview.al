{
name: feed_config_preview;
csv_cell: <td class="main info_bold" style="border: 1px solid gray;">%%cell%%</td>
csv_row: <tr>%%csv_cell%%</tr>

csv_header_row: <tr class="feed_config_preview_header">%%csv_cell%%</tr>

csv_err_row: <tr class="feed_config_preview_err">%%csv_cell%%</tr>

body:
<div style=" text-align: center;" class="feed_caption" >Pricelist preview</div>
<div class="feed_config_preview_cont" align="center" >
<table class="feed_config_preview_tbl" cellpadding="0" cellspacing="0">
	%%csv_row%%
</table>
</div>
}
