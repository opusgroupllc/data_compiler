<h1>USASpending.gov</h1>

<cfoutput>

	<cfdump var="#request.xmlXMLResponse.xmlRoot.xmlChildren[1].xmlChildren#"/>
	<cfloop array="#request.xmlXMLResponse.xmlRoot.xmlChildren[1].xmlChildren#" index="variables.i">
		#variables.i.xmlAttributes.field# = "#variables.i.xmlAttributes.value#"
		<br/>
	</cfloop>


	<!--- <cfdump var="#request.xmlXMLResponse.xmlRoot.xmlChildren[2].xmlChildren#"/> --->

	<cfdump var="#request.xmlXMLResponse#"/>
</cfoutput>