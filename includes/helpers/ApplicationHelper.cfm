﻿<!--- All methods in this helper will be available in all handlers,views & layouts --->

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
	<cfargument name="strLabelColumn" type="string" required="true"/>
	<cfargument name="strValueColumn" type="string" required="true"/>
	<cfargument name="bolWrapValuesWithQuotes" type="boolean" default="true"/>
	<cfargument name="strLink" type="string" default="javascript: void(0); "/>

	<cfset local.strQuotes = arguments.bolWrapValuesWithQuotes ? """" : ""/>

	<cfsavecontent variable="local.strData">
		<cfoutput>
			[
				<cfloop query="arguments.qryData">
					#arguments.qryData.currentRow GT 1 ? ", " : ""#{
						"label": "#evaluate("arguments.qryData.#arguments.strLabelColumn#")#"
						, "value": #local.strQuotes##evaluate("arguments.qryData.#arguments.strValueColumn#")##local.strQuotes#
						, "link": "#arguments.strLink#"
					}
				</cfloop>
			]
		</cfoutput>
	</cfsavecontent>

	<cfreturn local.strData/>
</cffunction>