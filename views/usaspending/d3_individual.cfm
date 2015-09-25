<h1>USASpending.gov > D3</h1>

<cfoutput>
	<cfset variables.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
	<cfinclude template="../includes/data_form.cfm"/>

	<div style="float: right; ">
		<cfif isDefined("request.objData")>

			#renderD3DonutChart(
				strChartId = "sb_donut_uncategorized"
				, strLabelColumn = "mod_parent"
				, strValueColumn = "obligatedamount"
				, intChartWidth = 450
				, intChartHeight = 450
				, intInnerRadius = 150
				, intOuterRadius = 105
			)#

			#renderD3DonutChart(
				strChartId = "sb_donut_8A"
				, strLabelColumn = "mod_parent"
				, strValueColumn = "obligatedamount"
				, intChartWidth = 450
				, intChartHeight = 450
				, intInnerRadius = 150
				, intOuterRadius = 105
			)#
<!--- 			<svg id="donut-chart"></svg>
			<script>
				/*-- Init the data: --*/
				var chartData = #serializeD3JSON(
					qryData = request.objData
					, strLabelColumn = "mod_parent"
					, strValueColumn = "obligatedamount"
					, bolWrapValuesWithQuotes = false
				)#;

				/*-- First we need to define the size and radius of the chart. --*/
				var width = 450
					, height = 450
					, radius = Math.min(width, height) / 2;

				/*-- Next, we'll use D3's default colours. --*/
				var colour = d3.scale.category20();
				/*-- If you want to define your own colours, use this instead: --*/
				//var colour = d3.scale.ordinal().range([*insert hex values here*]);
				var stroke = d3.scale.category20();
				/*-- Now it's time to define the size of our arcs. The outer radius determines
					the overall chart size from the center to the outer edge while the inner radius
					will define the size of the inner circle. --*/
				var arc = d3.svg.arc()
					.innerRadius(radius - 150)
					.outerRadius(radius - 105);

				/*-- Now that we have all of those important pieces, let's start putting it together.
					Let's start with the layout and attach the values that we defined in our chartData array. --*/
				var pie = d3.layout.pie()
					.value(function (d) { return d["value"]; })
					.sort(null);

				/*-- Now we're going to select our ID element and attach the size and radius attributes.
					We're also going to append a 'g' element to the SVG which is used to group together
					all the SVG shapes together. --*/
				var svg = d3.select("##donut-chart")
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

				svg.append("line")
					.attr("x1", -75)
					.attr("x2", 75)
					.attr("y1", 15)
					.attr("y2", 15)
					.style("stroke", "##36454f")
					.style("stroke-width", 1);

				/*-- Next we'll insert text and attach a class that we'll use in our CSS to style. --*/

				svg.append("text")
					.attr("dy", "-1.0em")
					.style("text-anchor", "middle")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("");

				svg.append("text")
					.attr("dy", "0.0em")
					.style("text-anchor", "middle")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("");

				svg.append("text")
					.attr("dy", "3.0em")
					.style("text-anchor", "middle")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("");

				/*-- When we mouse over an arc, populate the inner circle text with the item label. --*/
				$(document).on(
					"mouseover"
					, ".arc"
					, function() {
						$(".arc").css("stroke-width", "0");
						//$(".arc").css("opacity", "1");
						$(this).css("stroke-width", "10");
						//$(this).css("opacity", "0.5");
						var strItemLabel_1 = $(this).children("text:first").html();
						var strItemLabel_2 = "";
						var strItemLabel_3 = $(this).children("text:last").html();
						/*-- Note: Had to use pure JS to select the text element, or getBBox() doesn't work. --*/
						var objTextElement_1 = document.getElementById("donut-chart").getElementsByClassName("inner-circle-text")[0];
						var objTextElement_2 = document.getElementById("donut-chart").getElementsByClassName("inner-circle-text")[1];
						var objTextElement_3 = document.getElementById("donut-chart").getElementsByClassName("inner-circle-text")[2];
						objTextElement_1.innerHTML = strItemLabel_1;
						objTextElement_3.innerHTML = strItemLabel_3;
						if (objTextElement_1.getBBox().width > 175) {
							var intTotalLength = strItemLabel_1.length;
							var intTotalLengthHalf = Math.floor(intTotalLength / 2);
							var aryItemLabel_1 = strItemLabel_1.split(" ");
							var aryItemLabel_2 = strItemLabel_1.split(" ");
							var intReassembledLength = 0;
							var intClosestLessThanHalf = new Number();
							var intClosestMoreThanHalf = new Number();
							objTextElement_1.innerHTML = "";
							for (i = 0; i < aryItemLabel_1.length; i++) {
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
						}
					}
				);
			</script> --->
			<br />
			#renderDataTable(
				qryData = request.objData
			)#
		</cfif>
	</div>

</cfoutput>
