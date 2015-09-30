<!--- All methods in this helper will be available in all handlers,views & layouts --->

<cffunction name="renderDataTable" returnType="string">
	<cfargument name="qryData" type="query" required="true"/>
	<cfargument name="lstColumnNames" type="string" default="#arguments.qryData.getColumnList()#"/>
	<cfargument name="lstColumnHeaders" type="string" default="#arguments.lstColumnNames#"/>
	<cfargument name="strTableHeader" type="string" default=""/>
	<cfargument name="bolShowRowCount" type="boolean" default="true"/>

	<cfif listLen(arguments.lstColumnNames) NEQ listLen(arguments.lstColumnHeaders)>
		<cfthrow message="Must have an equal number of column names and column headers."/>
	</cfif>

	<cfsavecontent variable="local.strHTML">
		<cfoutput>
			<table class="data_table" border="0" cellpadding="0" cellspacing="0">
				<cfif len(trim(arguments.strTableHeader))>
					<tr>
						<th colspan="#listLen(arguments.lstColumnNames) + (arguments.bolShowRowCount ? 1 : 0)#">#arguments.strTableHeader#</th>
					</tr>
				</cfif>
				<tr>
					<cfif arguments.bolShowRowCount>
						<th>&nbsp;</th>
					</cfif>
					<cfloop list="#arguments.lstColumnHeaders#" index="local.strColumnHeader">
						<th>#trim(local.strColumnHeader)#</th>
					</cfloop>
				</tr>
				<cfloop query="#arguments.qryData#">
					<tr>
						<cfif arguments.bolShowRowCount>
							<td>#arguments.qryData.currentRow#</td>
						</cfif>
						<cfloop list="#arguments.lstColumnNames#" index="local.strColumn">
							<cfset local.strColumnValue = trim(evaluate("arguments.qryData.#local.strColumn#"))/>
							<td>#len(local.strColumnValue) ? local.strColumnValue : "&nbsp;"#</td>
						</cfloop>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfsavecontent>

	<cfreturn local.strHTML/>

</cffunction>
<cffunction name="serializeD3JSON" returnType="string">
	<cfargument name="qryData" type="query" required="true"/>
	<cfargument name="strLabelColumn" type="string" default=""/>
	<cfargument name="strValueColumn" type="string" default=""/>
	<cfargument name="strValueColumnX" type="string" default=""/>
	<cfargument name="strValueColumnY" type="string" default=""/>
	<cfargument name="bolWrapValuesWithQuotes" type="boolean" default="true"/>
	<cfargument name="bolWrapValuesWithQuotesX" type="boolean" default="true"/>
	<cfargument name="bolWrapValuesWithQuotesY" type="boolean" default="true"/>
	<cfargument name="strLink" type="string" default="javascript: void(0); "/>

	<cfif NOT (
		(
			len(trim(arguments.strLabelColumn)) AND len(trim(arguments.strValueColumn))
			AND NOT len(trim(arguments.strValueColumnX)) AND NOT len(trim(arguments.strValueColumnY))
		) OR (
			NOT len(trim(arguments.strLabelColumn)) AND NOT len(trim(arguments.strValueColumn))
			AND len(trim(arguments.strValueColumnX)) AND len(trim(arguments.strValueColumnY))
		)
	)>
		<cfthrow message="You must supply either the strLabelColumn and strValueColumn arguments, OR the strValueColumnX and strValueColumnY arguments."/>
	</cfif>

	<cfset local.strQuotes = arguments.bolWrapValuesWithQuotes ? """" : ""/>
	<cfset local.strQuotesX = arguments.bolWrapValuesWithQuotesX ? """" : ""/>
	<cfset local.strQuotesY = arguments.bolWrapValuesWithQuotesY ? """" : ""/>

	<cfsavecontent variable="local.strData">
		<cfoutput>
			<cfif len(trim(arguments.strLabelColumn)) AND len(trim(arguments.strValueColumn))>
				[
					<cfloop query="arguments.qryData">
						#arguments.qryData.currentRow GT 1 ? ", " : ""#{
							"label": "#evaluate("arguments.qryData.#arguments.strLabelColumn#")#" <!--- //#arguments.strLabelColumn# --->
							, "value": #local.strQuotes##evaluate("arguments.qryData.#arguments.strValueColumn#")##local.strQuotes#
							, "link": "#arguments.strLink#"
						}
					</cfloop>
				]
			<cfelseif len(trim(arguments.strValueColumnX)) AND len(trim(arguments.strValueColumnY))>
				[
					<cfloop query="arguments.qryData">
						#arguments.qryData.currentRow GT 1 ? ", " : ""#{
							"#arguments.strValueColumnX#": #local.strQuotesX##evaluate("arguments.qryData.#arguments.strValueColumnX#")##local.strQuotesX#
							, "#arguments.strValueColumnY#": #local.strQuotesY##evaluate("arguments.qryData.#arguments.strValueColumnY#")##local.strQuotesY#
						}
					</cfloop>
				]
			</cfif>
		</cfoutput>
	</cfsavecontent>

	<cfreturn local.strData/>
</cffunction>

<cffunction name="renderD3DonutChart" returnType="string">
	<cfargument name="strChartId" type="string" required="true"/>
	<cfargument name="strSmallBusinessCategory" type="string" default=""/>
	<cfargument name="strLabelColumn" type="string" required="true"/>
	<cfargument name="strValueColumn" type="string" required="true"/>
	<cfargument name="strLabel1" type="string" default=""/>
	<cfargument name="strLabel2" type="string" default=""/>
	<cfargument name="strLabel3" type="string" default=""/>
	<cfargument name="strValueLabel1" type="string" default=""/>
	<cfargument name="strValueLabel2" type="string" default=""/>
	<cfargument name="strValue1" type="string" default=""/>
	<cfargument name="strValue2" type="string" default=""/>
	<cfargument name="bolWrapValuesWithQuotes" type="boolean" default="false"/>
	<cfargument name="lstColorList" type="string" default=""/>
	<cfargument name="intChartWidth" type="numeric" default="450"/>
	<cfargument name="intChartHeight" type="numeric" default="450"/>
	<cfargument name="strInnerRadius" type="string" default="150"/>
	<cfargument name="strOuterRadius" type="string" default="105"/>

	<cfif reFind("[^,a-fA-F0-9]", arguments.lstColorList)>
		<cfthrow message="Only valid hexidecimal color values are allowed. Do not include the pound (##) sign."/>
	</cfif>

	<cfsavecontent variable="local.strContent">
		<cfoutput>
			<svg id="#arguments.strChartId#"></svg>
			<script>
				/*-- Init the data: --*/
				var chartData = #serializeD3JSON(
					qryData = request.stcData.stcDonutData["qryData#len(arguments.strSmallBusinessCategory) ? '_#arguments.strSmallBusinessCategory#' : ''#"]
					, strLabelColumn = "#arguments.strLabelColumn#"
					, strValueColumn = "#arguments.strValueColumn#"
					, bolWrapValuesWithQuotes = #arguments.bolWrapValuesWithQuotes#
				)#;

				/*-- First we need to define the size and radius of the chart. --*/
				var width = #arguments.intChartWidth#
					, height = #arguments.intChartHeight#
					, radius = Math.min(width, height) / 2;

				/*-- Next, we'll determine the colors to be used for the donut arcs: --*/
				<cfif len(trim(arguments.lstColorList))>
					/*-- If defining our own colors, use this: --*/
					var aryDonutColors = [
						<cfset local.iCount = 0/>
						<cfloop list="#arguments.lstColorList#" index="local.i">
							<cfset local.iCount++/>
							#local.iCount GT 1 ? ", " : ""#"###local.i#"
						</cfloop>
					];
					var colour = d3.scale.ordinal().range(aryDonutColors);
					var stroke = d3.scale.ordinal().range(aryDonutColors);
				<cfelse>
					/*-- Use D3's default colours. --*/
					var colour = d3.scale.category20();
					var stroke = d3.scale.category20();
				</cfif>
				/*-- Now it's time to define the size of our arcs. The outer radius determines
					the overall chart size from the center to the outer edge while the inner radius
					will define the size of the inner circle. --*/
				var arc = d3.svg.arc()
					.innerRadius(#arguments.strInnerRadius#)
					.outerRadius(#arguments.strOuterRadius#);

				/*-- Now that we have all of those important pieces, let's start putting it together.
					Let's start with the layout and attach the values that we defined in our chartData array. --*/
				var pie = d3.layout.pie()
					.value(function (d) { return d["value"]; })
					.sort(null);

				/*-- Now we're going to select our ID element and attach the size and radius attributes.
					We're also going to append a 'g' element to the SVG which is used to group together
					all the SVG shapes together. --*/
				var svg = d3.select("###arguments.strChartId#")
					.attr("width", width)
					.attr("height", height)
					.append("g")
					.attr("transform", "translate(" + radius + "," + radius + ")");

				/*-- Now we're going to attach our values and links to the pie chart. --*/
				var g = svg.selectAll(".arc")
					.data(pie(chartData))
					.enter().append("g")
					.attr("class", "arc")
					.on(
						"click"
						, function(d, i) {
							window.location = chartData[i].link;
						}
					);

				/*-- Last thing to see your work come to life is to append a path (most general shape that
					can be used in SVG (can draw shapes, etc.)) to each g element. --*/
				g.append("path")
					.attr("d", arc)
					.attr(
						"fill"
						, function(d, i) {
							return colour(i);
						}
					)
					.attr(
						"stroke"
						, function(d, i) {
							return colour(i);
						}
					);

				/*----------------------------------------------------------------------------------------------*/
				/*-- The code up to this point renders the donut, but there is no text/labels or hover features. The code below will do that. --*/
				/*----------------------------------------------------------------------------------------------*/

				/*-- We're going to use our data array and apply each label to each arc, define a position within the arc and apply a font color. --*/
				g.append("text")
					.attr(
						"transform"
						, function(d) {
							return "translate(" + arc.centroid(d) + ")";
						}
					)
					.attr("dy", ".25em")
					.style("text-anchor", "middle")
					.attr("fill", "##ffffff")
					.style("display", "none")
					.text(
						function(d, i) {
							return chartData[i].label;
						}
					);
				g.append("text")
					.attr(
						"transform"
						, function(d) {
							return "translate(" + arc.centroid(d) + ")";
						}
					)
					.attr("dy", ".25em")
					.style("text-anchor", "middle")
					.attr("fill", "##ffffff")
					.style("display", "none")
					.text(
						function(d, i) {
							return chartData[i].value;
						}
					);

				/*-- Let's create a circle in the center of the pie chart that we can use to insert text and style any way we like! --*/
				svg.append("circle")
					.attr("cx", 0)
					.attr("cy", 0)
					.attr("r", 100)
					.attr("fill", "##ffffff");  // If you want to change the colour of the inner circle, change it here.

				/*-- Insert horizontal dividing line(s) in the circle just above the 1st value and just below the 2nd value. --*/
				svg.append("line")
					.attr("x1", -93)
					.attr("x2", 93)
					.attr("y1", -24)
					.attr("y2", -24)
					.style("stroke", "##999999")
					.style("stroke-width", 1);

				svg.append("line")
					.attr("x1", -93)
					.attr("x2", 93)
					.attr("y1", 13)
					.attr("y2", 13)
					.style("stroke", "##999999")
					.style("stroke-width", 1);

				/*-- Insert horizontal dividing line in the circle between the two values. --*/
				/*-- svg.append("line")
					.attr("x1", -93)
					.attr("x2", 93)
					.attr("y1", -5)
					.attr("y2", -5)
					.style("stroke", "##999999")
					.style("stroke-width", 1); --*/

				/*-- Next we'll insert text and attach a class that we'll use in our CSS to style. --*/
				/*-- First label line text box: --*/
				svg.append("text")
					.attr("dy", "-4.75em")
					.style("text-anchor", "middle")
					.style("font-weight", "bold")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("#arguments.strLabel1#");

				/*-- Second label line text box: --*/
				svg.append("text")
					.attr("dy", "-3.75em")
					.style("text-anchor", "middle")
					.style("font-weight", "bold")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("#arguments.strLabel2#");

				/*-- Third label line text box: --*/
				svg.append("text")
					.attr("dy", "-2.75em")
					.style("text-anchor", "middle")
					.style("font-weight", "bold")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("#arguments.strLabel3#");

				/*-- First value's label text box: --*/
				svg.append("text")
					.attr("dy", "-0.6em")
					.attr("dx", "-6.5em")
					.style("text-anchor", "start")
					.style("font-weight", "bold")
					.attr("class", "inner-circle-text")
					.attr("fill", "###listFirst(arguments.lstColorList)#")
					.text("#arguments.strValueLabel1#");

				/*-- First value text box: --*/
				svg.append("text")
					.attr("dy", "-0.6em")
					.attr("dx", "6.5em")
					.style("text-anchor", "end")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("#arguments.strValue1#");

				/*-- Second value's label text box: --*/
				svg.append("text")
					.attr("dy", "0.6em")
					.attr("dx", "-6.5em")
					.style("text-anchor", "start")
					.style("font-weight", "bold")
					.attr("class", "inner-circle-text")
					.attr("fill", "###listLast(arguments.lstColorList)#")
					.text("#arguments.strValueLabel2#");

				/*-- Second value text box: --*/
				svg.append("text")
					.attr("dy", "0.6em")
					.attr("dx", "6.5em")
					.style("text-anchor", "end")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("#arguments.strValue2#");

				/*-- When we mouse over an arc, populate the inner circle text with the item label. --*/
				/*-- $(document).on(
					"mouseover"
					, "###arguments.strChartId# .arc"
					, function() { --*/
						/*-- Rollover and reset of arc props: --*/
						//$("###arguments.strChartId# .arc").css("stroke-width", "0");
						//$(".arc").css("opacity", "1");
						//$(this).css("stroke-width", "10");
						//$(this).css("opacity", "0.5");

						/*-- var strItemLabel_1 = $(this).children("text:first").html();
						var strItemLabel_2 = "";
						var strItemLabel_3 = $(this).children("text:last").html();
						var strItemLabel_4 = $(this).children("text:last").html();
						var strItemLabel_5 = $(this).children("text:last").html(); --*/

						/*-- Note: Had to use pure JS to select the text element, or getBBox() doesn't work. --*/
						/*-- var objTextElement_1 = document.getElementById("#arguments.strChartId#").getElementsByClassName("inner-circle-text")[0];
						var objTextElement_2 = document.getElementById("#arguments.strChartId#").getElementsByClassName("inner-circle-text")[1];
						var objTextElement_3 = document.getElementById("#arguments.strChartId#").getElementsByClassName("inner-circle-text")[2];
						var objTextElement_4 = document.getElementById("#arguments.strChartId#").getElementsByClassName("inner-circle-text")[3];
						var objTextElement_5 = document.getElementById("#arguments.strChartId#").getElementsByClassName("inner-circle-text")[4]; --*/

						/*-- objTextElement_1.innerHTML = strItemLabel_1;
						objTextElement_3.innerHTML = strItemLabel_3;
						objTextElement_4.innerHTML = strItemLabel_4;
						objTextElement_5.innerHTML = strItemLabel_5; --*/
						/*-- if (objTextElement_1.getBBox().width > 175) {
							var intTotalLength = strItemLabel_1.length;
							var intTotalLengthHalf = Math.floor(intTotalLength / 2);
							var aryItemLabel_1 = strItemLabel_1.split(" ");
							var aryItemLabel_2 = strItemLabel_1.split(" ");
							var intReassembledLength = 0;
							var intClosestLessThanHalf = new Number();
							var intClosestMoreThanHalf = new Number();
							objTextElement_1.innerHTML = "";
							for (i = 0; i < aryItemLabel_1.length; i++) {
								//-- To account for the space: --
								intReassembledLength += aryItemLabel_1[i].length + (i < aryItemLabel_1.length ? 1 : 0);
								if (intReassembledLength <= intTotalLengthHalf) {
									intClosestLessThanHalf = i;
								} else {
									intClosestMoreThanHalf = i;
									break;
								}
							}
							aryItemLabel_1.splice(intClosestMoreThanHalf, aryItemLabel_2.length);
							aryItemLabel_2.splice(0, intClosestMoreThanHalf);
							strItemLabel_1 = aryItemLabel_1.join(" ");
							strItemLabel_2 = aryItemLabel_2.join(" ");
							objTextElement_1.innerHTML = strItemLabel_1;
							objTextElement_2.innerHTML = strItemLabel_2;
						} --*/
					/*-- }
				); --*/
			</script>
		</cfoutput>
	</cfsavecontent>
	<cfreturn local.strContent/>
</cffunction>


<cffunction name="renderD3MultiSeriesLineChart" returnType="string">
	<cfargument name="strChartId" type="string" required="true"/>
	<cfargument name="strSmallBusinessCategory" type="string" default=""/>
	<cfargument name="strValueColumnX" type="string" required="true"/>
	<cfargument name="strValueColumnY" type="string" required="true"/>
	<cfargument name="bolWrapValuesWithQuotesX" type="boolean" default="false"/>
	<cfargument name="bolWrapValuesWithQuotesY" type="boolean" default="false"/>
	<cfargument name="intChartWidth" type="numeric" default="900"/>
	<cfargument name="intChartHeight" type="numeric" default="500"/>

	<cfset local.strQuotesX = arguments.bolWrapValuesWithQuotesX ? """" : ""/>
	<cfset local.strQuotesY = arguments.bolWrapValuesWithQuotesY ? """" : ""/>

	<cfset local.strQueryName = "objData#len(arguments.strSmallBusinessCategory) ? '_#arguments.strSmallBusinessCategory#' : ''#"/>
	<cfsavecontent variable="local.strContent">
		<cfoutput>
			<svg id="#arguments.strChartId#"></svg>
			<script>
				<!--- objChartData["jsnData_#local.i#"] --->
				var objChartData = {
					<cfset local.iCount = 0/>
					<cfloop list="smallBus,8a,womanOwned,smallDisadv,disabledVetOwned,HUBZone" index="local.i">
						<cfset local.iCount++/>
						#local.iCount GT 1 ? ", " : ""#jsnData_#local.i#: #serializeD3JSON(
							qryData = request.stcData.stcMultiSeriesData["qryData_#local.i#"]
							, strValueColumnX = arguments.strValueColumnX
							, strValueColumnY = arguments.strValueColumnY
							, bolWrapValuesWithQuotesX = arguments.bolWrapValuesWithQuotesX
							, bolWrapValuesWithQuotesY = arguments.bolWrapValuesWithQuotesY
						)#
					</cfloop>
				};
				<!--- var chartData = #serializeD3JSON(
					//qryData = request.stcData.objDataobjData_For_MultiSeriesLineChart
					qryData = request.stcData.stcMultiSeriesData[local.strQueryName]
					, strValueColumnX = arguments.strValueColumnX
					, strValueColumnY = arguments.strValueColumnY
					, bolWrapValuesWithQuotesX = arguments.bolWrapValuesWithQuotesX
					, bolWrapValuesWithQuotesY = arguments.bolWrapValuesWithQuotesY
				)#; --->

				/*-- Next, let's define some constants like width, height, left margin, etc., which we'll use while creating the graph. --*/
				var vis = d3.select("##sb_multi_series_line_chart")
					, WIDTH = #arguments.intChartWidth#
					, HEIGHT = #arguments.intChartHeight#
					, MARGINS = {
						top: 20
						, right: 20
						, bottom: 20
						, left: 50
					}
					, xScale = d3.scale.linear().range([MARGINS.left, WIDTH - MARGINS.right]).domain([
						<!--- #("min(listQualify(valueList(request.stcData.#local.strQueryName#.#strValueColumnX#), """"))")# --->
						#min(1, 2)#
						<!--- #min(evaluate("valueList(request.stcData.#local.strQueryName#.#strValueColumnX#)"))#
						, #max(evaluate("valueList(request.stcData.#local.strQueryName#.#strValueColumnX#)"))#
					])
					, yScale = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([
						#min(evaluate("valueList(request.stcData.#local.strQueryName#.#strValueColumnY#)"))#
						, #max(evaluate("valueList(request.stcData.#local.strQueryName#.#strValueColumnY#)"))# --->
					])
					/*-- Next, let's create the axes using the scales defined in the above code. --*/
					, xAxis = d3.svg.axis().scale(xScale)
					, yAxis = d3.svg.axis().scale(yScale);

				/*-- Next, append the created X axis to the svg container. --*/
				vis.append("svg:g").call(xAxis);

				/*-- While appending the X axis to the SVG container, use the transform property to move the axis downwards. --*/
				vis.append("svg:g")
					.attr("transform", "translate(0," + (HEIGHT - MARGINS.bottom) + ")")
					.call(xAxis);

				/*-- Now, let's add the Y Axis. --*/
				vis.append("svg:g").call(yAxis);

				/*-- Change the orientation of the above shown Y axis to the left. --*/
				yAxis = d3.svg.axis()
					.scale(yScale)
					.orient("left");

				/*-- Apply D3 transform while trying to append the Y axis to the SVG container: --*/
				vis.append("svg:g")
					.attr("transform", "translate(" + (MARGINS.left) + ",0)")
					.call(yAxis);

				/*-- Specify x and y coordinates for the line as per the xScale and yScale defined earlier. --*/
				var lineGen = d3.svg.line()
					.x(function(d) { return xScale(d.#arguments.strValueColumnX#); })
					.y(function(d) { return yScale(d.#arguments.strValueColumnY#); });

				/*-- Append a line path to svg and map the data to the plotting space using the lineGen function.
					Also specify a few attributes for the line such as stroke color, stroke-width, etc. --*/
				vis.append('svg:path')
					.attr('d', lineGen(chartData))
					.attr('stroke', 'green')
					.attr('stroke-width', 2)
					.attr('fill', 'none');

			</script>
		</cfoutput>
	</cfsavecontent>

	<cfreturn local.strContent/>
</cffunction>

<cffunction name="minQueryValue" returnType="any">
	<cfargument name="qryData" type="query" required="true"/>
	<cfargument name="qryData" type="query" required="true"/>
</cffunction>
