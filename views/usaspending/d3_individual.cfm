
<!--- <cfdump var="#request.qryBranches#"/> --->
<!--- <cfdump var="#request.qryAgencyCodes#"/> --->
<!--- <cfdump var="#request.qryBranchesAndAgencyCodes#"/> --->
<div id="beta_warning" class="alert alert-warning" role="alert">
	<strong>Warning</strong>:
	This web site is still in beta, and is available only for testing and proof-of-concept.
	Data accuracy cannot be guaranteed 100% at this stage of development.
</div>
<cfoutput>
	<cfinclude template="../includes/data_form.cfm"/>

	<cfif NOT (NOT request.stcError.bolError AND isDefined("request.stcData.stcDonutData"))>
		<cfif len(request.stcError.strErrorMessage)>
			<div class="alert alert-danger" role="alert">#request.stcError.strErrorMessage#</div>
		</cfif>
	<cfelse>
		<cfset variables.stcDonutSettings = {
			intChartWidth = 250
			, intChartHeight = 250
			, strInnerRadius = "120"
			, strOuterRadius = "100"
		}/>
		<div style="float: left; " class="alert alert-success" role="alert">
			#numberFormat(request.stcData.objData.recordCount, "999,999,999,999")# records retrieved.
		</div>

		<cfif val(form.generate_spreadsheet)>
			<cfif request.stcSpreadsheetError.bolSpreadsheetError>
				<div class="alert alert-warning" role="alert">#request.stcSpreadsheetError.strSpreadsheetErrorMessage#</div>
			<cfelse>
				<script>
					window.open("#request.spreadsheet_url#");
				</script>
			</cfif>
		</cfif>

		<div id="charts_container">
			<div class="multi_series_line_chart">
				#renderD3MultiSeriesLineChart2(
					strChartId = "sb_multi_series_line_chart"
					, strValueColumnX = "signeddate"
					, strValueColumnY = "ytd_total_obligated_amount_nbr"
					, strValueColumnTypeX = "date"
					, strValueColumnDataTypeX = "date"
					, strValueColumnDataTypeY = "decimal"
					, bolWrapValuesWithQuotesX = true
					, intChartWidth = 800
					, intChartHeight = 300
					, intTopMargin = 40
					, intRightMargin = 40
					, intBottomMargin = 40
					, intLeftMargin = 100
				)#
			</div>
			<div id="donut_charts_container">
				<cfset variables.iCount = 0/>
				<cfloop list="smallBus,8a,womanOwned,smallDisAdv,disabledVetOwned,HUBZone" index="variables.i">
					<cfset variables.iCount++/>
					<cfset variables.stcDonutArguments = {
						strChartId = "sb_donut_#variables.i#"
						, strSmallBusinessCategory = variables.i
						, lstColorList = "#request.stcBusinessCagoryColors['str#variables.i#']#,#request.stcBusinessCagoryColors.strAllOther#"
						, strLabelColumn = "small_business_category_txt"
						, strValueColumn = "total_obligated_amount_nbr"
						, strValueLabel1 = "Yes:"
						, strValueLabel2 = "No:"
						, strValue1 = request.stcData.stcDonutData["qryData_#variables.i#"]["total_obligated_amount_nbr"][1]
						, strValue2 = request.stcData.stcDonutData["qryData_#variables.i#"]["total_obligated_amount_nbr"][2]
						, intChartWidth = variables.stcDonutSettings.intChartWidth
						, intChartHeight = variables.stcDonutSettings.intChartHeight
						, strInnerRadius = variables.stcDonutSettings.strInnerRadius
						, strOuterRadius = variables.stcDonutSettings.strOuterRadius
					}/>
					<cfif variables.i IS "smallBus">
						<cfset variables.stcDonutArguments.strLabel2 = "Small Business"/>
					<cfelseif variables.i IS "8a">
						<cfset variables.stcDonutArguments.strLabel2 = "8A"/>
					<cfelseif variables.i IS "womanOwned">
						<cfset variables.stcDonutArguments.strLabel2 = "Woman-Owned"/>
					<cfelseif variables.i IS "smallDisAdv">
						<cfset variables.stcDonutArguments.strLabel1 = "Small"/>
						<cfset variables.stcDonutArguments.strLabel2 = "Disadvantaged"/>
						<cfset variables.stcDonutArguments.strLabel3 = "Business"/>
					<cfelseif variables.i IS "disabledVetOwned">
						<cfset variables.stcDonutArguments.strLabel1 = "Disabled"/>
						<cfset variables.stcDonutArguments.strLabel2 = "Veteran-Owned"/>
					<cfelseif variables.i IS "HUBZone">
						<cfset variables.stcDonutArguments.strLabel2 = "HUBZone"/>
					</cfif>
					<div class="donut_chart" style="#listFind('1,4', variables.iCount) ? 'clear: left; ' : ''#">
						#renderD3DonutChart(argumentCollection = variables.stcDonutArguments)#
					</div>
				</cfloop>
			</div>
		</div>

		<div class="data_table_div">
			<!--- #renderDataTable(
				qryData = request.stcData.objData
			)# --->
		</div>
	</cfif>

</cfoutput>
<!--- <cfdump var="#request.stcData#" metaInfo="true"/> --->