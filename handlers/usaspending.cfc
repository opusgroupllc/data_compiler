<!---
	usaspending
	@author Rob Germain
	@date 9/18/15
 --->
<cfcomponent accessors="true" output="false" persistent="false">

	<cffunction name="index">
		<cfscript>
			//runEvent( 'usaspending' );
			request.xmlXMLResponse = parseXMLResponse(
				getXMLResponse(
					stcURLParams = {
						detail = "s"
						, fiscal_year = 2015
						, stateCode = "TX"
						, max_records = 10
					}
				).fileContent
			);
		    event.setView("usaspending/index");
		</cfscript>
	</cffunction>

	<cffunction name="getXMLResponse" returnType="Struct">
		<cfargument name="stcURLParams" type="struct" required="true"/>

		<!--- return https://www.usaspending.gov/fpds/fpds.php?detail=s&fiscal_year=2015&stateCode=TX&max_records=10 --->

		<cfhttp url="https://www.usaspending.gov/fpds/fpds.php" result="local.stcXMLResponse">
			<cfloop list="#structKeyList(arguments.stcURLParams)#" index="local.i">
				<cfhttpparam type="url" name="#local.i#" value="#arguments.stcURLParams[local.i]#"/>
			</cfloop>
		</cfhttp>

		<cfreturn local.stcXMLResponse/>

	</cffunction>

	<cffunction name="parseXMLResponse" returnType="any">
		<cfargument name="strXMLResponse" type="string" required="true"/>
		<cfset local.xmlResponse = xmlParse(arguments.strXMLResponse)/>
		<cfreturn local.xmlResponse/>
	</cffunction>
</cfcomponent>