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

		<!--- <div class="multi_series_line_chart">
			#renderD3MultiSeriesLineChart(
				strChartId = "sb_multi_series_line_chart"
				, strSmallBusinessCategory = "smallBus"
				, strValueColumnX = "signeddate"
				, strValueColumnY = "obligatedamount"
				, bolWrapValuesWithQuotesX = true
				, intChartWidth = 1000
				, intChartHeight = 500
			)#
		</div> --->
		<div id="donut_charts_container">
			<cfset variables.iCount = 0/>
			<cfloop list="smallBus,8a,womanOwned,smallDisAdv,disabledVetOwned,HUBZone" index="variables.i">
				<cfset variables.iCount++/>
				<cfset variables.stcDonutArguments = {
					strChartId = "sb_donut_#variables.i#"
					, strSmallBusinessCategory = variables.i
					, strLabelColumn = "small_business_category_txt"
					, strValueColumn = "total_obligated_amount_nbr"
					, intChartWidth = variables.stcDonutSettings.intChartWidth
					, intChartHeight = variables.stcDonutSettings.intChartHeight
					, strInnerRadius = variables.stcDonutSettings.strInnerRadius
					, strOuterRadius = variables.stcDonutSettings.strOuterRadius
				}/>
				<cfif variables.i IS "smallBus">
					<cfset variables.stcDonutArguments.lstColorList = "FF9900,000000"/>
					<cfset variables.stcDonutArguments.strDonutLabel = "Small Business"/>
				<cfelseif variables.i IS "8a">
					<cfset variables.stcDonutArguments.lstColorList = "0040FF,000000"/>
					<cfset variables.stcDonutArguments.strDonutLabel = "8A"/>
				<cfelseif variables.i IS "womanOwned">
					<cfset variables.stcDonutArguments.lstColorList = "B20000,000000"/>
					<cfset variables.stcDonutArguments.strDonutLabel = "Woman Owned"/>
				<cfelseif variables.i IS "smallDisAdv">
					<cfset variables.stcDonutArguments.lstColorList = "008C00,000000"/>
					<cfset variables.stcDonutArguments.strDonutLabel = "Small Disadvantaged Business"/>
				<cfelseif variables.i IS "disabledVetOwned">
					<cfset variables.stcDonutArguments.lstColorList = "FF9999,000000"/>
					<cfset variables.stcDonutArguments.strDonutLabel = "Disabled Veteran Owned"/>
				<cfelseif variables.i IS "HUBZone">
					<cfset variables.stcDonutArguments.lstColorList = "73B9FF,000000"/>
					<cfset variables.stcDonutArguments.strDonutLabel = "HUBZone"/>
				</cfif>
				<div class="donut_chart" style="#listFind('1,4', variables.iCount) ? 'clear: left; ' : ''#">
					#renderD3DonutChart(argumentCollection = variables.stcDonutArguments)#
					<!--- <div class="donut_label">
						<cfif variables.i IS "smallBus">
							<cfset variables.strDonutLabel = "Small Business"/>
						<cfelseif variables.i IS "8a">
							<cfset variables.strDonutLabel = "8A"/>
						<cfelseif variables.i IS "womanOwned">
							<cfset variables.strDonutLabel = "Woman Owned"/>
						<cfelseif variables.i IS "smallDisAdv">
							<cfset variables.strDonutLabel = "Small Disadvantaged Business"/>
						<cfelseif variables.i IS "disabledVetOwned">
							<cfset variables.strDonutLabel = "Disabled Veteran Owned"/>
						<cfelseif variables.i IS "HUBZone">
							<cfset variables.strDonutLabel = "HUBZone"/>
						</cfif>
					</div> --->
				</div>
			</cfloop>
		</div>

		<div class="data_table_div">
			<!--- #renderDataTable(
				qryData = request.stcData.objData
			)# --->
		</div>
	</cfif>

</cfoutput>
<!--- <cfdump var="#request.stcData#" metaInfo="true"/> --->