<h1>USASpending.gov</h1>

<cfoutput>
	<cfset variables.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending"/>
	<cfinclude template="../includes/data_form.cfm"/>

	<div style="float: right; ">
		<cfif isDefined("form.data_form_submitted") AND val(form.data_form_submitted)>
			<cfif form.detail IS 's'>
				<cfloop list="#structKeyList(request.objData)#" index="variables.i">
					chart loading...
					<br />
				</cfloop>
			<cfelse>
				<cfif listFindNoCase("l,m", form.detail)>
					<cfset variables.strChartTitle = "Obligated Amount by Mod Parent"/>
				<cfelseif form.detail IS "b">
					<cfset variables.strChartTitle = "Dollars Obligated by Recipient Name"/>
				<cfelseif form.detail IS "c">
					<cfset variables.strChartTitle = "Obligated Amount by Vendor Name"/>
				<cfelse>
					<cfset variables.strChartTitle = ""/>
				</cfif>
				<cfchart
					format="png"
					title="#variables.strChartTitle#"
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
		</cfif>
	</div>
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
		</cfif>
	</cfif>
</cfoutput>