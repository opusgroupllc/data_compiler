<h1>USASpending.gov</h1>

<cfoutput>
	<form name="data_form" action="#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending" method="post">
		<input type="hidden" name="data_form_submitted" id="data_form_submitted" value="1"/>

		<select name="detail" id="detail">
			<option value="s" #form.detail IS 's' ? 'selected' : ''#>Summary</option>
			<option value="l" #form.detail IS 'l' ? 'selected' : ''#>Low</option>
			<option value="m" #form.detail IS 'm' ? 'selected' : ''#>Medium</option>
			<option value="b" #form.detail IS 'b' ? 'selected' : ''#>Basic</option>
			<option value="c" #form.detail IS 'c' ? 'selected' : ''#>Complete</option>
		</select>

		<input type="submit" name="btn_submit" id="btn_submit" value="Get Data"/>
	</form>
	<hr/>
	<cfif isDefined("form.data_form_submitted") AND val(form.data_form_submitted)>

		<cfdump var="#request.xmlXMLResponse#"/>
	</cfif>
</cfoutput>