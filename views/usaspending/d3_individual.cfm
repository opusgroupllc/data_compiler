<h1>USASpending.gov > D3</h1>

<cfoutput>
	<cfset variables.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
	<cfinclude template="../includes/data_form.cfm"/>

	<div style="float: right; ">
		<cfif isDefined("request.objData")>
			<svg id="donut-chart"></svg>
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

				/*-- Now it's time to define the size of our arcs. The outer radius determines
					the overall chart size from the center to the outer edge while the inner radius
					will define the size of the inner circle. --*/
				var arc = d3.svg.arc()
					.innerRadius(radius - 130)
					.outerRadius(radius - 10);

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

				/*-- Let's create a circle in the center of the pie chart that we can use to insert text and style any way we like! --*/
				svg.append("circle")
					.attr("cx", 0)
					.attr("cy", 0)
					.attr("r", 100)
					.attr("fill", "##ffffff");  // If you want to change the colour of the inner circle, change it here.


				/*-- Next we'll insert text and attach a class that we'll use in our CSS to style. --*/
				/*-- svg.append("text")
					.attr("dy", "-0.5em")
					.style("text-anchor", "middle")
					.attr("class", "inner-circle")
					.attr("fill", "##36454f")
					.text(
						function(d) {
							return 'JavaScript';
						}
					);

				svg.append("text")
					.attr("dy", "1.0em")
					.style("text-anchor", "middle")
					.attr("class", "inner-circle")
					.attr("fill", "##36454f")
					.text(
						function(d) {
							return 'is lots of fun!';
						}
					); --*/
				svg.append("text")
					.attr("dy", "0.0em")
					.style("text-anchor", "middle")
					.attr("class", "inner-circle-text")
					.attr("fill", "##36454f")
					.text("");

				/*--  --*/
				$(document).on(
					"mouseover"
					, ".arc"
					, function() {
						//alert($(this).children("text:first").html());
						var strItemLabel = $(this).children("text:first").html();
						$("##donut-chart").find(".inner-circle-text:first").html(
							strItemLabel
						);
					}
				);


			</script>
			<br />
			#renderDataTable(
				qryData = request.objData
			)#
		</cfif>
	</div>

</cfoutput>

