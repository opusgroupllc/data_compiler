<h1>USASpending.gov</h1>

<cfoutput>
	<form
		name="data_form"
		action="#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending"
		method="post"
		class="form-inline"
	>
		<input type="hidden" name="data_form_submitted" id="data_form_submitted" value="1"/>

		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<div class="form-group">
						<label for="detail">Detail Level</label>
						<select name="detail" id="detail" class="form-control">
							<option value="s" #form.detail IS 's' ? 'selected' : ''#>Summary</option>
							<option value="l" #form.detail IS 'l' ? 'selected' : ''#>Low</option>
							<option value="m" #form.detail IS 'm' ? 'selected' : ''#>Medium</option>
							<option value="b" #form.detail IS 'b' ? 'selected' : ''#>Basic</option>
							<option value="c" #form.detail IS 'c' ? 'selected' : ''#>Complete</option>
						</select>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<label for="max_records">Max Records to Return</label>
						<select name="max_records" id="max_records" class="form-control">
							<option value="10" #form.max_records IS '10' ? 'selected' : ''#>10</option>
							<option value="25" #form.max_records IS '25' ? 'selected' : ''#>25</option>
							<option value="50" #form.max_records IS '50' ? 'selected' : ''#>50</option>
							<option value="100" #form.max_records IS '100' ? 'selected' : ''#>100</option>
							<option value="250" #form.max_records IS '250' ? 'selected' : ''#>250</option>
							<option value="500" #form.max_records IS '500' ? 'selected' : ''#>500</option>
							<option value="750" #form.max_records IS '750' ? 'selected' : ''#>750</option>
							<option value="1000" #form.max_records IS '1000' ? 'selected' : ''#>1000</option>
						</select>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<label for="stateCode">State Code</label>
						<input type="text" name="stateCode" id="stateCode" maxlength="2" size="2" value="#form.stateCode#" class="form-control"/>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<label for="company_name">Company Name</label>
						<input type="text" name="company_name" id="company_name" maxlength="100" size="50" value="#form.company_name#" class="form-control"/>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<label for="mod_agency">Mod Agency</label>
						<input type="text" name="mod_agency" id="mod_agency" maxlength="4" size="4" value="#form.mod_agency#" class="form-control"/>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<label for="maj_agency_cat">Major Agency</label>
						<input type="text" name="maj_agency_cat" id="maj_agency_cat" maxlength="2" size="2" value="#form.maj_agency_cat#" class="form-control"/>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<label for="fiscal_year">Fiscal Year</label>
						<input type="text" name="fiscal_year" id="fiscal_year" maxlength="2" size="2" value="#form.fiscal_year#" class="form-control"/>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div class="form-group">
						<input type="submit" name="btn_submit" id="btn_submit" value="Get Data" class="form-control"/>
					</div>
				</td>
			</tr>
		</table>
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

			<cfchart
				format="png"
				chartwidth="700"
				chartheight="500"
				url="javascript: void(0); "
				tipStyle="mouseOver"
				pieSliceStyle="solid"
			>
				<cfif listFindNoCase("l,m", form.detail)>
					<cfchartseries
						type="pie"
						query="request.objData"
						itemcolumn="mod_parent"
						valuecolumn="obligatedamount"
					/>
				<cfelseif form.detail IS "b">
					<cfchartseries
						type="pie"
						query="request.objData"
						itemcolumn="recipientname"
						valuecolumn="dollarsobligated"
					/>
				<cfelseif form.detail IS "c">
					<cfchartseries
						type="pie"
						query="request.objData"
						itemcolumn="vendorname"
						valuecolumn="obligatedamount"
					/>
				</cfif>
			</cfchart>


		</cfif>
		<!--- <cfdump var="#request.objData#"/> --->
	</cfif>
</cfoutput>