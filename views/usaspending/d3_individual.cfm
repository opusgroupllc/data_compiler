<h1>USASpending.gov > D3</h1>

<!--- <cfdump var="#request.qryBranches#"/> --->
<!--- <cfdump var="#request.qryAgencyCodes#"/> --->
<!--- <cfdump var="#request.qryBranchesAndAgencyCodes#"/> --->

<cfoutput>
	<cfset variables.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
	<cfinclude template="../includes/data_form.cfm"/>

	<cfif isDefined("request.stcData")>
		<cfset variables.stcDonutSettings = {
			intChartWidth = 250
			, intChartHeight = 250
			, strInnerRadius = "120"
			, strOuterRadius = "100"
		}/>

		<div class="multi_series_line_chart">
			#renderD3MultiSeriesLineChart(
				strChartId = "sb_multi_series_line_chart"
				, strSmallBusinessCategory = "none"
				, strValueColumnX = "signeddate"
				, strValueColumnY = "obligatedamount"
				, bolWrapValuesWithQuotesX = true
				, intChartWidth = 1000
				, intChartHeight = 500
			)#
		</div>
		<cfset variables.iCount = 0/>
		<cfloop list="none,8a,womanOwned,smallDisAdv,disabledVetOwned,HUBZone" index="variables.i">
			<cfset variables.iCount++/>
			<div class="donut_chart" style="#variables.iCount EQ 1 ? 'clear: left; ' : ''#">
				#renderD3DonutChart(
					strChartId = "sb_donut_#variables.i#"
					, strSmallBusinessCategory = variables.i
					, strLabelColumn = "maj_fund_agency_cat"
					, strValueColumn = "obligatedamount"
					, intChartWidth = variables.stcDonutSettings.intChartWidth
					, intChartHeight = variables.stcDonutSettings.intChartHeight
					, strInnerRadius = variables.stcDonutSettings.strInnerRadius
					, strOuterRadius = variables.stcDonutSettings.strOuterRadius
				)#
				<div class="donut_label">
					<cfif variables.i IS "none">
						No Categories
					<cfelseif variables.i IS "8a">
						8A
					<cfelseif variables.i IS "womanOwned">
						Woman Owned
					<cfelseif variables.i IS "smallDisAdv">
						Small Disadvantaged Business
					<cfelseif variables.i IS "disabledVetOwned">
						Disabled Veteran Owned
					<cfelseif variables.i IS "HUBZone">
						HUBZone
					</cfif>
				</div>
			</div>
		</cfloop>

		<div class="data_table_div">
			#renderDataTable(
				qryData = request.stcData.objData_For_MultiSeriesLineChart
			)#
		</div>
	</cfif>

</cfoutput>
<!--- <cfdump var="#request.stcData#" metaInfo="true"/> --->