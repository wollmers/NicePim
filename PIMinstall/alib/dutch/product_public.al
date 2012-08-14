{
name: product_public;

date_format:%d-%m-%Y;

default_login: None;

cat_div: ---;
any_cat: None;

publish_Y: Yes;
publish_N: No;


body:


  <table>
	 <tr>
	 <td>~Part number~</td>
	 <td>%%prod_id%%</td>
	 </tr>

	 <tr>
	 <td>~Supplier~</td>
	 <td>%%supplier_name%%</td>
	 </tr>

	 <tr>
	 <td>~Category~</td>
	 <td>%%cat_name%% </td>
	 </tr>


	 <tr>
	 <td>~Name~</td>
	 <td>%%name%%</td>
	 </tr>

	 

	</table>





}

{
name: product_public;
class: brief;

date_format:%d-%m-%Y;

default_login: None;

cat_div: ---;
any_cat: None;

low_pic_format: <img src="%%value%%" border=0 hspace=0 vspace=0>

body:
<table border=0 width=100%>
<tr>
<td>
<h2>%%supplier_name%% %%prod_id%%</h2>
<h2>Product details</h2>
</td> 
<td>
 %%low_pic_formatted%%
</td>
</tr>
</table>
}

