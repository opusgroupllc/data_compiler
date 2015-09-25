<h1>USASpending.gov > D3</h1>

<cfoutput>
	<cfset variables.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
	<cfinclude template="../includes/data_form.cfm"/>

	<cfif isDefined("request.objData")>
		<cfset variables.stcDonutSettings = {
			intChartWidth = 300
			, intChartHeight = 300
			, strInnerRadius = "140"
			, strOuterRadius = "120"
		}/>
		<div class="donut_chart">
			#renderD3DonutChart(
				strChartId = "sb_donut_uncategorized"
				, strLabelColumn = "mod_parent"
				, strValueColumn = "obligatedamount"
				, intChartWidth = variables.stcDonutSettings.intChartWidth
				, intChartHeight = variables.stcDonutSettings.intChartHeight
				, strInnerRadius = variables.stcDonutSettings.strInnerRadius
				, strOuterRadius = variables.stcDonutSettings.strOuterRadius
			)#
		</div>
		<div class="donut_chart">
			#renderD3DonutChart(
				strChartId = "sb_donut_8A"
				, strLabelColumn = "mod_parent"
				, strValueColumn = "obligatedamount"
				, intChartWidth = variables.stcDonutSettings.intChartWidth
				, intChartHeight = variables.stcDonutSettings.intChartHeight
				, strInnerRadius = variables.stcDonutSettings.strInnerRadius
				, strOuterRadius = variables.stcDonutSettings.strOuterRadius
			)#
		</div>
		<div class="data_table_div">
			#renderDataTable(
				qryData = request.objData
			)#
		</div>
	</cfif>

</cfoutput>
