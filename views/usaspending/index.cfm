<h1>USASpending.gov</h1>

<cfoutput>
	<form name="data_form" action="#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending" method="post">
		<input type="hidden" name="data_form_submitted" id="data_form_submitted" value="1"/>

		<label for="detail">Detail Level</label>
		<select name="detail" id="detail">
			<option value="s" #form.detail IS 's' ? 'selected' : ''#>Summary</option>
			<option value="l" #form.detail IS 'l' ? 'selected' : ''#>Low</option>
			<option value="m" #form.detail IS 'm' ? 'selected' : ''#>Medium</option>
			<option value="b" #form.detail IS 'b' ? 'selected' : ''#>Basic</option>
			<option value="c" #form.detail IS 'c' ? 'selected' : ''#>Complete</option>
		</select>
<br />
		<label for="max_records">Max Records to Return</label>
		<select name="max_records" id="max_records">
			<option value="10" #form.max_records IS '10' ? 'selected' : ''#>10</option>
			<option value="25" #form.max_records IS '25' ? 'selected' : ''#>25</option>
			<option value="50" #form.max_records IS '50' ? 'selected' : ''#>50</option>
			<option value="100" #form.max_records IS '100' ? 'selected' : ''#>100</option>
			<option value="250" #form.max_records IS '250' ? 'selected' : ''#>250</option>
			<option value="500" #form.max_records IS '500' ? 'selected' : ''#>500</option>
			<option value="750" #form.max_records IS '750' ? 'selected' : ''#>750</option>
			<option value="1000" #form.max_records IS '1000' ? 'selected' : ''#>1000</option>
		</select>
<br />
		<label for="stateCode">State Code</label>
		<input type="text" name="stateCode" id="stateCode" maxlength="2" size="2" value="#form.stateCode#"/>
<br />
		<label for="fiscal_year">Fiscal Year</label>
		<input type="text" name="fiscal_year" id="fiscal_year" maxlength="2" size="2" value="#form.fiscal_year#"/>
<br /><br />
		<input type="submit" name="btn_submit" id="btn_submit" value="Get Data"/>
	</form>
	<hr/>
	<cfif isDefined("form.data_form_submitted") AND val(form.data_form_submitted)>
		<cfif form.detail IS 's'>
			<cfloop list="#structKeyList(request.objData)#" index="variables.i">
				#renderDataTable(
					qryData = request.objData[variables.i]
					, strTableHeader = variables.i
				)#
				<hr/>
			</cfloop>
		<cfelse>
			#renderDataTable(
				qryData = request.objData
			)#

			<cfchart format="png" chartwidth="1000" chartheight="1000" url="javascript: void(0); ">
				<cfchartseries type="pie" query="request.objData" itemcolumn="mod_parent" valuecolumn="obligatedamount" dataLabelStyle="value"/>
				<!--- <cfchartseries/>
				<cfchartdata/> --->
			</cfchart>


		</cfif>
		<!--- <cfdump var="#request.objData#"/> --->
	</cfif>
</cfoutput>