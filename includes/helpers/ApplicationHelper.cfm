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
						<th colspan="#listLen(arguments.lstColumnNames)#">#arguments.strTableHeader#</th>
					</tr>
				</cfif>
				<tr>
					<cfloop list="#arguments.lstColumnHeaders#" index="local.strColumnHeader">
						<th>#trim(local.strColumnHeader)#</th>
					</cfloop>
				</tr>
				<cfloop query="#arguments.qryData#">
					<tr>
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