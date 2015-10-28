<!---
	usaspending
	@author Rob Germain
	@date 9/18/15
 --->
<cfcomponent accessors="true" output="false" persistent="false">

	<cffunction name="index">
		<cfparam name="form.data_form_submitted" default="0"/>
		<cfparam name="form.detail" default="b"/>
		<cfparam name="form.max_records" default="10"/>
		<cfparam name="form.stateCode" default=""/>
		<cfparam name="form.company_name" default=""/>
		<cfparam name="form.mod_agency" default=""/>
		<cfparam name="form.maj_agency_cat" default=""/>
		<cfparam name="form.fiscal_year" default="2015"/>

		<cfif val(form.data_form_submitted)>
			<cfset local.stcURLParams = structNew()/>
			<cfloop list="detail,max_records,stateCode,company_name,mod_agency,maj_agency_cat,fiscal_year" index="local.i">
				<cfif structKeyExists(form, local.i) AND len(trim(form[local.i]))>
					<cfset local.stcURLParams[local.i] = form[local.i]/>
				</cfif>
			</cfloop>

			<cfset request.objData = this.parseXMLResponse(
				strDetailLevel = form.detail
				, strXMLData = this.getXMLResponse(
					stcURLParams = local.stcURLParams
				).fileContent
			)>
		</cfif>
		<cfset event.setView("usaspending/index")/>
	</cffunction>

	<cffunction name="batch_load_setup">
		<cfparam name="form.data_form_submitted" default="0"/>
		<cfparam name="form.detail" default="c"/>
		<cfparam name="form.max_records" default="10"/>
		<cfparam name="form.stateCode" default=""/>
		<!--- <cfparam name="form.agency_id" default="0"/> --->
		<cfparam name="form.mod_agency" default=""/>
		<cfparam name="form.maj_agency_cat" default=""/>
		<cfparam name="form.fiscal_year" default="2015"/>
		<cfparam name="form.generate_spreadsheet" default="0"/>

		<cfset request.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/batch_load_process"/>
		<cfset request.form_action_2 = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
		<cfset request.qryAgencyCodes = this.getAgencyCodes()/>

		<cfset event.setView("usaspending/batch_load_setup")/>

	</cffunction>

	<cffunction name="batch_load_process">

		<cfset request.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
		<cfset request.spreadsheet_url = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/deliver_spreadsheet"/>

		<cfset this.cleanBatchProcessTable()/>

		<!--- <cftry>
			<cfthrow message="asdf"/>
			<cfcatch>
				<cfdump var="#cfcatch#"/>
			</cfcatch>
		</cftry> --->

		<cfset request.stcDataChunks = structNew()/>
		<cfset local.strThreadInitiatorID = reReplaceNoCase(createUUID(), "[^a-zA-Z0-9]", "_", "all")/>
		<cfset local.lstBatchLoadProcessThreadIdList = ""/>
		<cfset request.intStep = 500/>
		<cfloop from="1" to="#form.max_records#" step="#request.intStep#" index="request.t">
			<cflock timeout="1" scope="request" throwOnTimeout="true" type="exclusive">
				<cfset request.strBatchLoadProcessThreadId = "batch_load_process_thread__#local.strThreadInitiatorID#__#request.t#"/>
				<cfset local.lstBatchLoadProcessThreadIdList = listAppend(local.lstBatchLoadProcessThreadIdList, request.strBatchLoadProcessThreadId)/>
				<cfset request.stcDataChunks[request.strBatchLoadProcessThreadId].stcError = {
					bolError = false
					, strErrorMessage = ""
				}/>
			</cflock>
			<cfthread
				action="run"
				name="#request.strBatchLoadProcessThreadId#"

				strBatchLoadProcessThreadId="#request.strBatchLoadProcessThreadId#"
				recordsFrom="#request.t#"
				intStep="#request.intStep#"
			>
				<cfoutput>My Name is: #attributes.strBatchLoadProcessThreadId#</cfoutput>
				<cftry>
					<cfset attributes.stcURLParams = structNew()/>
					<cfloop list="detail,stateCode,mod_agency,maj_agency_cat,fiscal_year" index="attributes.i">
						<cfif structKeyExists(form, attributes.i) AND len(trim(form[attributes.i]))>
							<cfset attributes.stcURLParams[attributes.i] = form[attributes.i]/>
						</cfif>
						<cflock timeout="1" scope="request" throwOnTimeout="true" type="exclusive">
							<cfset attributes.stcURLParams["max_records"] = attributes.intStep/>
							<cfset attributes.stcURLParams["records_from"] = attributes.recordsFrom/>
						</cflock>
					</cfloop>
					<cfoutput>
						attributes.recordsFrom=#attributes.recordsFrom#<br />
						<cfloop list="#structKeyList(attributes.stcURLParams)#" index="attributes.x">
							attributes.stcURLParams["#attributes.x#"] = #attributes.stcURLParams[attributes.x]#<br />
						</cfloop>
					</cfoutput>
					TRACE_1
					<cflock timeout="1" scope="request" throwOnTimeout="true" type="exclusive"><!--- name="#request.strBatchLoadProcessThreadId#__lock_2"  --->
						<cfset request.stcDataChunks[attributes.strBatchLoadProcessThreadId] = structNew()/>
						<cfset request.stcDataChunks[attributes.strBatchLoadProcessThreadId].stcData = structNew()/>
					</cflock>
					<cfset attributes.objData = this.parseXMLResponse(
						strDetailLevel = form.detail
						, strXMLData = this.getXMLResponse(
							stcURLParams = attributes.stcURLParams
						).fileContent
					)/>
					<!--- <cfset cfthread.objData = "HELLO!!"/> --->
					<!--- <cfset cfthread.stcURLParams = attributes.stcURLParams/> --->
					<cflock timeout="1" scope="request" throwOnTimeout="true" type="exclusive"><!--- name="#request.strBatchLoadProcessThreadId#__lock_3"  --->
						<cfset request.stcDataChunks[attributes.strBatchLoadProcessThreadId].stcData.objData = attributes.objData/>
					</cflock>
					<cfset structDelete(attributes, "objData")/>

					<cfoutput>
						TRACE_2 (request.stcDataChunks[attributes.strBatchLoadProcessThreadId].stcData.objData.recordCount = #request.stcDataChunks[attributes.strBatchLoadProcessThreadId].stcData.objData.recordCount#
					</cfoutput>
					<cfset attributes.bolLoadBatchProcessChunkSuccessful = this.loadBatchProcessChunk(
						strBatchLoadProcessThreadId = attributes.strBatchLoadProcessThreadId
						, qryData = request.stcDataChunks[attributes.strBatchLoadProcessThreadId].stcData.objData
						, intStartRow = attributes.recordsFrom
					)/>
					<cfoutput>
						TRACE_3 (attributes.bolLoadBatchProcessChunkSuccessful = #attributes.bolLoadBatchProcessChunkSuccessful#)
					</cfoutput>
					<cfcatch>
						TRACE_4
						<cflock timeout="1" scope="request" throwOnTimeout="true" type="exclusive"><!--- name="#request.strBatchLoadProcessThreadId#__lock_4"  --->
							<cfset request.stcDataChunks[attributes.strBatchLoadProcessThreadId].stcError = {
								bolError = true
								, strErrorMessage = "There was a problem retrieving the requested data. This could be due their being "
									& "no records matching the criteria, or a USASpending.gov server timeout. Please try again in a "
									& "few minutes or try a different Agency."
							}/>
						</cflock>
						TRACE_5
						<!--- <cfset request.stcError[attributes.strBatchLoadProcessThreadId] = duplicate(request.stcDataChunks)/> --->
						<!--- <cfdump var="#cfcatch#"> --->
						<cfoutput>
							Error Message: #cfcatch.Message#<br />
							Error Detail: #cfcatch.Detail#
							Template: #cfcatch.TagContext[1].template#:#cfcatch.TagContext[1].line#
						</cfoutput>
						TRACE_6
					</cfcatch>
				</cftry>
				TRACE_7
			</cfthread>
			TRACE_8
		</cfloop>
		<cfthread action="join" name="#local.lstBatchLoadProcessThreadIdList#"/>
		<cfdump var="#cfthread#">
		TRACE_9
	</cffunction>

	<cffunction name="cleanBatchProcessTable" returnType="boolean">
		<cftry>
			<cfquery name="local.qryData">
				TRUNCATE TABLE test_data
			</cfquery>
			<cfcatch>
				<cfreturn false/>
			</cfcatch>
		</cftry>
		<cfreturn true/>
	</cffunction>

	<cffunction name="loadBatchProcessChunk" returnType="boolean">
		<cfargument name="strBatchLoadProcessThreadId" type="string" required="true"/>
		<cfargument name="qryData" type="query" required="true"/>
		<cfargument name="intStartRow" type="numeric" required="true"/>

		<cfif arguments.qryData.recordCount>
			<cftry>
				<cftransaction>
					<cfloop query="arguments.qryData">
						<cfquery name="local.qryInsertData">
							INSERT INTO test_data (
								batch_load_process_thread_id
								, spendingcategory
								, obligatedamount
								, maj_agency_cat
								, maj_fund_agency_cat
								, signeddate
								, agencyid
								, piid
								, fiscal_year
								, idvmodificationnumber
								, firm8aflag
								, hubzoneflag
								, sdbflag
								, womenownedflag
								, srdvobflag
								, contractingofficerbusinesssizedetermination
								, last_modified_date
								, idvagency
								, idvprocurementinstrumentid
								, is_type_none_bt
								, is_type_8a_bt
								, is_type_women_owned_bt
								, is_type_small_disadvantaged_bt
								, is_type_disabled_vet_owned_bt
								, is_type_hub_zone_bt
								, year_month_dt
								, transactionnumber
								, retrieved_record_nbr
							) VALUES (
								<cfqueryparam value="#arguments.strBatchLoadProcessThreadId#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.spendingcategory#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.obligatedamount#" cfsqltype="cf_sql_float"/>
								, <cfqueryparam value="#arguments.qryData.maj_agency_cat#" cfsqltype="cf_sql_int"/>
								, <cfqueryparam value="#arguments.qryData.maj_fund_agency_cat#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.signeddate#" cfsqltype="cf_sql_timestamp"/>
								, <cfqueryparam value="#arguments.qryData.agencyid#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.piid#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.fiscal_year#" cfsqltype="cf_sql_int"/>
								, <cfqueryparam value="#arguments.qryData.idvmodificationnumber#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.firm8aflag#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.hubzoneflag#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.sdbflag#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.womenownedflag#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.srdvobflag#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.contractingofficerbusinesssizedetermination#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.last_modified_date#" cfsqltype="cf_sql_timestamp"/>
								, <cfqueryparam value="#arguments.qryData.idvagency#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.idvprocurementinstrumentid#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.is_type_none_bt#" cfsqltype="cf_sql_bit"/>
								, <cfqueryparam value="#arguments.qryData.is_type_8a_bt ? 1 : 0#" cfsqltype="cf_sql_bit"/>
								, <cfqueryparam value="#arguments.qryData.is_type_women_owned_bt ? 1 : 0#" cfsqltype="cf_sql_bit"/>
								, <cfqueryparam value="#arguments.qryData.is_type_small_disadvantaged_bt ? 1 : 0#" cfsqltype="cf_sql_bit"/>
								, <cfqueryparam value="#arguments.qryData.is_type_disabled_vet_owned_bt ? 1 : 0#" cfsqltype="cf_sql_bit"/>
								, <cfqueryparam value="#arguments.qryData.is_type_hub_zone_bt ? 1 : 0#" cfsqltype="cf_sql_bit"/>
								, <cfqueryparam value="#arguments.qryData.year_month_dt#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#arguments.qryData.transactionnumber#" cfsqltype="cf_sql_varchar"/>
								, <cfqueryparam value="#(arguments.intStartRow - 1) + arguments.qryData.currentRow#" cfsqltype="cf_sql_bigint"/>
							)
						</cfquery>
					</cfloop>
				</cftransaction>
				<cfcatch>
					<cfoutput>
						ERROR in loadBatchProcessChunk():<br />
						Error Message: #cfcatch.Message#<br />
						Error Detail: #cfcatch.Detail#<br />
						Template: #cfcatch.TagContext[1].template#:#cfcatch.TagContext[1].line#<br /><br />
					</cfoutput>
					<cfreturn false/>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfreturn false/>
		</cfif>
		<cfreturn true/>
	</cffunction>

	<cffunction name="d3_individual">
		<cfparam name="form.data_form_submitted" default="0"/>
		<cfparam name="form.detail" default="c"/>
		<cfparam name="form.max_records" default="10"/>
		<cfparam name="form.stateCode" default=""/>
		<!--- <cfparam name="form.agency_id" default="0"/> --->
		<cfparam name="form.mod_agency" default=""/>
		<cfparam name="form.maj_agency_cat" default=""/>
		<cfparam name="form.fiscal_year" default="2015"/>
		<cfparam name="form.generate_spreadsheet" default="0"/>

		<cfset request.stcError = {
			bolError = false
			, strErrorMessage = ""
		}/>
		<cfset request.stcSpreadsheetError = {
			bolSpreadsheetError = false
			, strSpreadsheetErrorMessage = ""
		}/>

		<cfset request.form_action = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/d3_individual"/>
		<cfset request.spreadsheet_url = "#cgi.https IS 'on' ? 'https' : 'http'#://#cgi.server_name##cgi.script_name#/usaspending/deliver_spreadsheet"/>

		<cfset request.stcBusinessCagoryColors = {
			strSmallBus = "FF9900"
			, str8a = "0040FF"
			, strWomanOwned = "B20000"
			, strSmallDisAdv = "008C00"
			, strDisabledVetOwned = "FF9999"
			, strHUBZone = "73B9FF"
			, strAllOther = "000000"
		}/>

		<cfif val(form.data_form_submitted)>
			<cftry>
				<cfset local.stcURLParams = structNew()/>
				<cfloop list="detail,max_records,stateCode,mod_agency,maj_agency_cat,fiscal_year" index="local.i">
					<cfif structKeyExists(form, local.i) AND len(trim(form[local.i]))>
						<cfset local.stcURLParams[local.i] = form[local.i]/>
					</cfif>
				</cfloop>

				<cfset request.stcData = structNew()/>
				<cfset request.stcData.objData = this.parseXMLResponse(
					strDetailLevel = form.detail
					, strXMLData = this.getXMLResponse(
						stcURLParams = local.stcURLParams
					).fileContent
				)/>

				<!--- ----------------------------------------------------------------------------------------------- --->
				<cfset request.stcData.stcDonutData = structNew()/>
				<cfset variables.stcDonutData = this.groupChartDataBySmallBusinessCategory(qryData = request.stcData.objData)/>
				<cfloop list="#structKeyList(variables.stcDonutData)#" index="variables.i">
					<cfset request.stcData.stcDonutData[variables.i] = variables.stcDonutData[variables.i]/>
				</cfloop>
				<cfset structDelete(variables, "stcData.stcDonutData")/>

				<!--- ----------------------------------------------------------------------------------------------- --->
				<cfset request.stcData.stcMultiSeriesData = structNew()/>
				<cfset variables.stcMultiSeriesData = this.separateChartDataBySmallBusinessCategory(qryData = request.stcData.objData)/>
				<cfloop list="#structKeyList(variables.stcMultiSeriesData)#" index="variables.i">
					<cfset request.stcData.stcMultiSeriesData[variables.i] = variables.stcMultiSeriesData[variables.i]/>
				</cfloop>
				<cfset structDelete(variables, "stcData")/>

				<cftry>
					<cfif val(form.generate_spreadsheet)>
						<cfset session.xlsData = this.queryToSpreadsheet(request.stcData)/>
					</cfif>
					<cfcatch>
						<cfset request.stcSpreadsheetError = {
							bolSpreadsheetError = true
							, strSpreadsheetErrorMessage = "There was a problem generating a spreadsheet of the data."
						}/>
					</cfcatch>
				</cftry>

				<cfcatch>
					<cfset request.stcError = {
						bolError = true
						, strErrorMessage = "There was a problem retrieving the requested data. This could be due their being "
							& "no records matching the criteria, or a USASpending.gov server timeout. Please try again in a "
							& "few minutes or try a different Agency."
					}/>
				</cfcatch>

			</cftry>

		</cfif>
		<!--- <cfset request.qryBranches = this.getBranches()/> --->
		<cfset request.qryAgencyCodes = this.getAgencyCodes()/>
		<!--- <cfset request.qryBranchesAndAgencyCodes = this.getBranchesAndAgencyCodes()/> --->
		<cfset event.setView("usaspending/d3_individual")/>
	</cffunction>

	<cffunction name="deliver_spreadsheet">
		<cftry>
			<cfheader name="Content-Disposition" value="attachment; filename=ChartData_#dateTimeFormat(now(), 'yyyymmdd_HHnnss')#.xls"/>
			<cfcontent type="application/msexcel" variable="#application.spreadsheet.readBinary(session.xlsData)#"/>
			<cfcatch>
				<cfset request.stcSpreadsheetError = {
					bolSpreadsheetError = true
					, strSpreadsheetErrorMessage = "There was a problem delivering the generated spreadsheet."
				}/>
			</cfcatch>
		</cftry>
		<cfset event.setView("usaspending/deliver_spreadsheet")/>
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
		<cfargument name="strDetailLevel" type="string" required="true"/>
		<cfargument name="strXMLData" type="string" required="true"/>
		<cfargument name="strSmallBusinessCategory" type="string" default=""/>

		<cfswitch expression="#arguments.strDetailLevel#">
			<cfcase value="s">
				<cfreturn this.parseXMLResponseSummary(xmlXMLData = xmlParse(arguments.strXMLData))/>
			</cfcase>
			<cfcase value="l">
				<cfreturn this.parseXMLResponseLow(xmlXMLData = xmlParse(arguments.strXMLData))/>
			</cfcase>
			<cfcase value="m">
				<cfreturn this.parseXMLResponseMedium(xmlXMLData = xmlParse(arguments.strXMLData))/>
			</cfcase>
			<cfcase value="b">
				<cfreturn this.parseXMLResponseBasic(xmlXMLData = xmlParse(arguments.strXMLData))/>
			</cfcase>
			<cfcase value="c">
				<cfreturn this.parseXMLResponseComplete(
					xmlXMLData = xmlParse(arguments.strXMLData)
					, strSmallBusinessCategory = arguments.strSmallBusinessCategory
				)/>
			</cfcase>
			<cfdefaultcase>
				<cfreturn "No matching detail level."/>
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="parseXMLResponseSummary" returnType="struct">
		<cfargument name="xmlXMLData" type="xml" required="true"/>

		<cfscript>
			local.lstGroupNames = "Totals";
			local.lstGroupNames = listAppend(local.lstGroupNames, "ExtentOfCompetition");
			local.lstGroupNames = listAppend(local.lstGroupNames, "TypeOfContractUsed");
			local.lstGroupNames = listAppend(local.lstGroupNames, "TopKnownCongressionalDistricts");
			local.lstGroupNames = listAppend(local.lstGroupNames, "TopProductsOrServicesSold");
			local.lstGroupNames = listAppend(local.lstGroupNames, "TopContractingAgencies");
			local.lstGroupNames = listAppend(local.lstGroupNames, "TopRecipients");
			local.lstGroupNames = listAppend(local.lstGroupNames, "TopContractorParentCompanies");
			local.lstGroupNames = listAppend(local.lstGroupNames, "FiscalYears");

			<!--- Drill down as far as possible to the actual data records: Note: Had to use the ":" before each node in the path due
				to the "xmlns" attribute in the parent tag. --->
			local.stcDataArrays = {
				aryTotals = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:totals/"
				)
				//arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:records/:record/"
				, aryExtentOfCompetition = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:extent_of_competition/"
				)
				, aryTypeOfContractUsed= xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:type_of_contract_used/"
				)
				, aryTopKnownCongressionalDistricts = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:top_known_congressional_districts/:congressional_district/"
				)
				, aryTopProductsOrServicesSold = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:top_products_or_services_sold/:product_or_service_category/"
				)
				, aryTopContractingAgencies = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:top_contracting_agencies/:agency/"
				)
				, aryTopRecipients = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:top_recipients/:recipient/"
				)
				, aryTopContractorParentCompanies = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:top_contractor_parent_companies/:contractor_parent_company/"
				)
				, aryFiscalYears = xmlSearch(
					arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:record/:fiscal_years/:fiscal_year/"
				)
			};
			local.stcDataQueries = {
				qryTotals = queryNew("fiscal_year,total_ObligatedAmount,percent_of_fiscal_year,number_of_contractors,number_of_transactions")
				, qryExtentOfCompetition = queryNew(
					"not_competed"
					& ",full_and_open_competition_after_exclusion_of_sources"
					& ",not_available_for_competition"
					& ",full_and_open_competition"
					& ",follow_on_to_competed_action"
					& ",competitive_delivery_order"
					& ",non-competitive_delivery_order"
					& ",competed_under_SAP"
					& ",not_competed_under_SAP"
				)
				, qryTypeOfContractUsed = queryNew(
					"cost_plus_award_fee"
					& ",fixed_price_with_economic_price_adjustment"
					& ",firm_fixed_price"
					& ",cost_plus_incentive"
					& ",cost_plus_fixed_fee"
					& ",fixed_price_incentive"
					& ",contracts_that_used_a_combination_of_the_above_pricing_arrangements"
					& ",time_and_materials"
					& ",cost_no_fee"
					& ",fixed_price_redetermination"
					& ",fixed_price_level_of_effort"
					& ",fixed_price_award_fee"
					& ",cost_sharing"
					& ",labor_hours"
					& ",contracts_that_allow_the_orders_to_be_priced_differently_than_the_basic_contract"
					& ",awards_only_where_none_of_the_above_pricing_arrangements_apply"
					& ",unknown"
				)
				, qryTopKnownCongressionalDistricts = queryNew("congressional_district,rank,total_obligatedAmount")
				, qryTopProductsOrServicesSold = queryNew("product_or_service_category,rank,total_obligatedAmount")
				, qryTopContractingAgencies = queryNew("agency,rank,total_obligatedAmount")
				, qryTopRecipients = queryNew("recipient,rank,total_obligatedAmount")
				, qryTopContractorParentCompanies = queryNew("contractor_parent_company,rank,total_obligatedAmount")
				, qryFiscalYears = queryNew("fiscal_year,year")
			};
		</cfscript>

		<!--- Loop over the group names: --->
		<cfloop list="#local.lstGroupNames#" index="local.strGroupName">
			<!--- Loop over the group name array: --->
			<cfloop array="#local.stcDataArrays['ary#local.strGroupName#']#" index="local.xmlRecord">
				<cfif NOT listFindNoCase("Totals,ExtentOfCompetition,TypeOfContractUsed", local.strGroupName)
					OR (
						listFindNoCase("Totals,ExtentOfCompetition,TypeOfContractUsed", local.strGroupName)
						AND arrayLen(local.xmlRecord.xmlChildren)
					)
				>
					<cfset queryAddRow(local.stcDataQueries['qry#local.strGroupName#'])/>
				</cfif>
				<cfif listFindNoCase(local.stcDataQueries['qry#local.strGroupName#'].columnList, local.xmlRecord.xmlName)>
					<cfset querySetCell(local.stcDataQueries['qry#local.strGroupName#'], local.xmlRecord.xmlName, local.xmlRecord.xmlText)/>
				</cfif>
				<!--- Loop over the group name array children: --->
				<cfloop array="#local.xmlRecord.xmlChildren#" index="local.xmlColumn">
					<cfif listFindNoCase(local.stcDataQueries['qry#local.strGroupName#'].columnList, local.xmlColumn.xmlName)>
						<cfset querySetCell(local.stcDataQueries['qry#local.strGroupName#'], local.xmlColumn.xmlName, local.xmlColumn.xmlText)/>
					</cfif>
				</cfloop>
				<cfif listFindNoCase("TopKnownCongressionalDistricts,TopProductsOrServicesSold,TopRecipients,TopContractorParentCompanies", local.strGroupName)>
					<cfset querySetCell(local.stcDataQueries['qry#local.strGroupName#'], "rank", local.xmlRecord.xmlAttributes.rank)/>
					<cfset querySetCell(local.stcDataQueries['qry#local.strGroupName#'], "total_obligatedAmount", local.xmlRecord.xmlAttributes.total_obligatedAmount)/>
				<cfelseif local.strGroupName IS "FiscalYears">
					<cfset querySetCell(local.stcDataQueries['qry#local.strGroupName#'], "year", local.xmlRecord.xmlAttributes.year)/>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.stcDataQueries/>
	</cffunction>

	<cffunction name="parseXMLResponseLow" returnType="query">
		<cfargument name="xmlXMLData" type="xml" required="true"/>

		<cfscript>
			<!--- Drill down as far as possible to the actual data records: Note: Had to use the ":" before each node in the path due
				to the "xmlns" attribute in the parent tag. --->
			local.aryXMLData = xmlSearch(
				arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:records/:record/"
			);
			local.qryXMLData = queryNew(
				"mod_parent"
				& ",name_add"
				& ",obligatedAmount"
				& ",duns_no"
			);
		</cfscript>
		<cfloop array="#local.aryXMLData#" index="local.xmlRecord">
			<cfset queryAddRow(local.qryXMLData)/>
			<cfloop array="#local.xmlRecord.xmlChildren#" index="local.xmlColumn">
				<cfif listFindNoCase(local.qryXMLData.columnList, local.xmlColumn.xmlName)>
					<cfset querySetCell(local.qryXMLData, local.xmlColumn.xmlName, local.xmlColumn.xmlText)/>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.qryXMLData/>
	</cffunction>

	<cffunction name="parseXMLResponseMedium" returnType="query">
		<cfargument name="xmlXMLData" type="xml" required="true"/>

		<cfscript>
			<!--- Drill down as far as possible to the actual data records: Note: Had to use the ":" before each node in the path due
				to the "xmlns" attribute in the parent tag. --->
			local.aryXMLData = xmlSearch(
				arguments.xmlXMLData, "/:usaspendingSearchResults/:data/:records/:record/"
			);
			local.qryXMLData = queryNew(
				"mod_parent"
				& ",name_add"
				& ",obligatedAmount"
			);
		</cfscript>
		<cfloop array="#local.aryXMLData#" index="local.xmlRecord">
			<cfset queryAddRow(local.qryXMLData)/>
			<cfloop array="#local.xmlRecord.xmlChildren#" index="local.xmlColumn">
				<cfif listFindNoCase(local.qryXMLData.columnList, local.xmlColumn.xmlName)>
					<cfset querySetCell(local.qryXMLData, local.xmlColumn.xmlName, local.xmlColumn.xmlText)/>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.qryXMLData/>
	</cffunction>

	<cffunction name="parseXMLResponseBasic" returnType="query">
		<cfargument name="xmlXMLData" type="xml" required="true"/>

		<cfscript>
			<!--- Drill down as far as possible to the actual data records: Note: Had to use the ":" before each node in the path due
				to the "xmlns" attribute in the parent tag. --->
			local.aryXMLData = xmlSearch(
				arguments.xmlXMLData, "/:usaspendingSearchResults/:result/:doc/"
			);
			local.qryXMLData = queryNew(
				"spendingCategory"
				& ",record_count"
				& ",UniqueTransactionID"
				& ",ContractPricing"
				& ",ContractingAgency"
				& ",DUNSNumber"
				& ",parentDUNSNumber"
				& ",DateSigned"
				& ",ContractDescription"
				& ",ReasonForModification"
				& ",DollarsObligated"
				& ",ExtentCompeted"
				& ",FiscalYear"
				& ",TransactionNumber"
				& ",AgencyID"
				& ",FundingAgency"
				& ",ContractingAgencyCode"
				& ",ModificationNumber"
				& ",PSCCategoryCode"
				& ",ParentRecipientOrCompanyName"
				& ",PlaceofPerformanceCongDistrict"
				& ",PlaceofPerformanceState"
				& ",PlaceofPerformanceZipCode"
				& ",PrincipalNAICSCode"
				& ",ProcurementInstrumentID"
				& ",PrincipalPlaceCountyOrCity"
				& ",ProductorServiceCode"
				& ",ProgramSource"
				& ",ProgramSourceAccountCode"
				& ",RecipientAddressLine123"
				& ",RecipientCity"
				& ",RecipientCongressionalDistrict"
				& ",RecipientName"
				& ",RecipientOrContractorName"
				& ",RecipientState"
				& ",RecipientZipCode"
				& ",TypeofSpending"
				& ",VendorName"
				& ",TransactionStatus"
				& ",AwardType"
				& ",MajorAgency"
				& ",MajorFundingAgency"
				& ",TypeofTransaction"
				& ",ProgramSourceAgencyCode"
				& ",IDVAgency"
				& ",IDVProcurementInstrumentID"
				& ",ProgramSourceDescription"
				& ",RecipientCountyName"
			);
		</cfscript>
		<cfloop array="#local.aryXMLData#" index="local.xmlRecord">
			<cfset queryAddRow(local.qryXMLData)/>
			<cfif isStruct(local.xmlRecord.xmlAttributes) AND structKeyExists(local.xmlRecord.xmlAttributes, "spendingCategory")>
				<cfset querySetCell(local.qryXMLData, "spendingCategory", local.xmlRecord.xmlAttributes.spendingCategory)/>
			</cfif>
			<cfloop array="#local.xmlRecord.xmlChildren#" index="local.xmlColumn">
				<cfif listFindNoCase(local.qryXMLData.columnList, local.xmlColumn.xmlName)>
					<cfset querySetCell(local.qryXMLData, local.xmlColumn.xmlName, local.xmlColumn.xmlText)/>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.qryXMLData/>
	</cffunction>

	<cffunction name="parseXMLResponseComplete" returnType="query">
		<cfargument name="xmlXMLData" type="xml" required="true"/>
		<cfargument name="strSmallBusinessCategory" type="string" default=""/>

		<cfset local.lstSmallBusinessCategories = "none,smallBus,8a,womanOwned,smallDisadv,disabledVetOwned,HUBZone"/>
		<cfif len(arguments.strSmallBusinessCategory)
			AND NOT listFindNoCase(local.lstSmallBusinessCategories, arguments.strSmallBusinessCategory)
		>
			<cfthrow message="Only the following values are allowed for arguments.strSmallBusinessCategory: #local.lstSmallBusinessCategories#, or you can leave it blank for all."/>
		</cfif>

		<cfscript>
			<!--- Drill down as far as possible to the actual data records: Note: Had to use the ":" before each node in the path due
				to the "xmlns" attribute in the parent tag. --->
			local.aryXMLData = xmlSearch(
				arguments.xmlXMLData, "/:usaspendingSearchResults/:result/:doc/"
			);
			local.qryXMLData = queryNew(
				"spendingCategory"
				& ",obligatedAmount"
//				& ",baseAndExercisedOptionsValue"
//				& ",baseAndAllOptionsValue"
				& ",maj_agency_cat"
//				& ",mod_agency"
				& ",maj_fund_agency_cat"
//				& ",contractingOfficeAgencyID"
//				& ",contractingOfficeID"
//				& ",fundingRequestingAgencyID"
//				& ",fundingRequestingOfficeID"
				& ",signedDate"
//				& ",effectiveDate"
//				& ",currentCompletionDate"
//				& ",ultimateCompletionDate"
//				& ",lastdatetoorder"
//				& ",contractActionType"
//				& ",reasonForModification"
//				& ",typeOfContractPricing"
//				& ",subcontractPlan"
//				& ",priceEvaluationPercentDifference"
//				& ",letterContract"
//				& ",multiYearContract"
//				& ",performanceBasedServiceContract"
//				& ",contingencyHumanitarianPeacekeepingOperation"
//				& ",contractFinancing"
//				& ",costOrPricingData"
//				& ",costAccountingStandardsClause"
//				& ",descriptionOfContractRequirement"
//				& ",purchaseCardAsPaymentMethod"
//				& ",numberOfActions"
//				& ",nationalInterestActionCode"
//				& ",ProgSourceAgency"
//				& ",ProgSourceAccount"
//				& ",vendorName"
//				& ",vendorAlternateName"
//				& ",vendorLegalOrganizationName"
//				& ",streetAddress"
//				& ",city"
//				& ",state"
//				& ",ZIPCode"
//				& ",vendorCountryCode"
//				& ",vendorStateCode"
//				& ",vendor_cd"
//				& ",congressionalDistrict"
//				& ",vendorSiteCode"
//				& ",vendorAlternateSiteCode"
//				& ",DUNSNumber"
//				& ",parentDUNSNumber"
//				& ",phoneNo"
//				& ",faxNo"
//				& ",registrationDate"
//				& ",renewalDate"
//				& ",mod_parent"
//				& ",stateCode"
//				& ",popStateCode"
//				& ",placeOfPerformanceCountryCode"
//				& ",placeOfPerformanceZIPCode"
//				& ",pop_cd"
//				& ",placeOfPerformanceCongressionalDistrict"
//				& ",psc_cat"
//				& ",productOrServiceCode"
//				& ",systemEquipmentCode"
//				& ",claimantProgramCode"
//				& ",principalNAICSCode"
//				& ",informationTechnologyCommercialItemCategory"
//				& ",GFE_GFP"
//				& ",useOfEPADesignatedProducts"
//				& ",recoveredMaterialClauses"
//				& ",seaTransportation"
//				& ",contractBundling"
//				& ",consolidatedContract"
//				& ",countryOfOrigin"
//				& ",placeOfManufacture"
//				& ",manufacturingOrganizationType"
				& ",agencyID"
				& ",PIID"
//				& ",modNumber"
				& ",transactionNumber"
				& ",fiscal_year"
				& ",IDVModificationNumber"
//				& ",extentCompeted"
//				& ",reasonNotCompeted"
//				& ",numberOfOffersReceived"
//				& ",commercialItemAcquisitionProcedures"
//				& ",commercialItemTestProgram"
//				& ",smallBusinessCompetitivenessDemonstrationProgram"
//				& ",A76Action"
//				& ",solicitationProcedures"
//				& ",typeOfSetAside"
//				& ",localAreaSetAside"
//				& ",evaluatedPreference"
//				& ",fedBizOpps"
//				& ",organizationalType"
//				& ",numberOfEmployees"
//				& ",annualRevenue"
				& ",firm8AFlag"
				& ",HUBZoneFlag"
				& ",SDBFlag"
//				& ",shelteredWorkshopFlag"
//				& ",HBCUFlag"
//				& ",educationalInstitutionFlag"
				& ",womenOwnedFlag"
//				& ",veteranOwnedFlag"
				& ",SRDVOBFlag"
//				& ",localGovernmentFlag"
//				& ",minorityInstitutionFlag"
//				& ",AIOBFlag"
//				& ",stateGovernmentFlag"
//				& ",federalGovernmentFlag"
//				& ",minorityOwnedBusinessFlag"
//				& ",APAOBFlag"
//				& ",tribalGovernmentFlag"
//				& ",BAOBFlag"
//				& ",NAOBFlag"
//				& ",SAAOBFlag"
//				& ",nonprofitOrganizationFlag"
//				& ",isothernotforprofitorganization"
//				& ",isforprofitorganization"
//				& ",isfoundation"
//				& ",HAOBFlag"
//				& ",ishispanicservicinginstitution"
//				& ",verySmallBusinessFlag"
//				& ",hospitalflag"
				& ",contractingOfficerBusinessSizeDetermination"
//				& ",is1862landgrantcollege"
//				& ",is1890landgrantcollege"
//				& ",is1994landgrantcollege"
//				& ",isveterinarycollege"
//				& ",isveterinaryhospital"
//				& ",isprivateuniversityorcollege"
//				& ",isschoolofforestry"
//				& ",isstatecontrolledinstitutionofhigherlearning"
//				& ",receivescontracts"
//				& ",receivesgrants"
//				& ",receivescontractsandgrants"
//				& ",isairportauthority"
//				& ",iscouncilofgovernments"
//				& ",ishousingauthoritiespublicortribal"
//				& ",isinterstateentity"
//				& ",isplanningcommission"
//				& ",isportauthority"
//				& ",istransitauthority"
//				& ",issubchapterscorporation"
//				& ",islimitedliabilitycorporation"
//				& ",isforeignownedandlocated"
//				& ",isarchitectureandengineering"
//				& ",iscitylocalgovernment"
//				& ",iscommunitydevelopedcorporationownedfirm"
//				& ",iscommunitydevelopmentcorporation"
//				& ",isconstructionfirm"
//				& ",ismanufacturerofgoods"
//				& ",iscorporateentitynottaxexempt"
//				& ",iscountylocalgovernment"
//				& ",isdomesticshelter"
//				& ",isfederalgovernmentagency"
//				& ",isfederallyfundedresearchanddevelopmentcorp"
//				& ",isforeigngovernment"
//				& ",isindiantribe"
//				& ",isintermunicipallocalgovernment"
//				& ",isinternationalorganization"
//				& ",islaborsurplusareafirm"
//				& ",islocalgovernmentowned"
//				& ",ismunicipalitylocalgovernment"
//				& ",isnativehawaiianownedorganizationorfirm"
//				& ",isotherbusinessororganization"
//				& ",isotherminorityowned"
//				& ",ispartnershiporlimitedliabilitypartnership"
//				& ",isschooldistrictlocalgovernment"
//				& ",issmallagriculturalcooperative"
//				& ",issoleproprietorship"
//				& ",istownshiplocalgovernment"
//				& ",istriballyownedfirm"
//				& ",istribalcollege"
//				& ",isalaskannativeownedcorporationorfirm"
//				& ",iscorporateentitytaxexempt"
//				& ",WalshHealyAct"
//				& ",serviceContractAct"
//				& ",DavisBaconAct"
//				& ",ClingerCohenAct"
//				& ",prime_awardee_executive1_compensation"
//				& ",prime_awardee_executive2_compensation"
//				& ",prime_awardee_executive3_compensation"
//				& ",prime_awardee_executive4_compensation"
//				& ",prime_awardee_executive5_compensation"
//				& ",interagencycontractingauthority"
				& ",last_modified_date"
//				& ",fundedByForeignEntity"
//				& ",typeOfContract"
//				& ",majorProgramCode"
//				& ",isdotcertifieddisadvantagedbusinessenterprise"
//				& ",solicitationID"
				& ",IDVAgency"
				& ",IDVProcurementInstrumentID"
//				& ",ProgramSourceDescription"
//				& ",RecipientCountyName"
				& ",is_type_none_bt"
				& ",is_type_8A_bt"
				& ",is_type_women_owned_bt"
				& ",is_type_small_disadvantaged_bt"
				& ",is_type_disabled_vet_owned_bt"
				& ",is_type_hub_zone_bt"
				& ",year_month_dt"
			);
		</cfscript>
		<cfloop array="#local.aryXMLData#" index="local.xmlRecord">
			<cfset queryAddRow(local.qryXMLData)/>
			<cfif isStruct(local.xmlRecord.xmlAttributes) AND structKeyExists(local.xmlRecord.xmlAttributes, "spendingCategory")>
				<cfset querySetCell(local.qryXMLData, "spendingCategory", local.xmlRecord.xmlAttributes.spendingCategory)/>
			</cfif>
			<cfloop array="#local.xmlRecord.xmlChildren#" index="local.xmlColumn">
				<cfif listFindNoCase(local.qryXMLData.columnList, local.xmlColumn.xmlName)>
					<cfset querySetCell(local.qryXMLData, local.xmlColumn.xmlName, local.xmlColumn.xmlText)/>
				</cfif>
			</cfloop>

			<!--- firm8A,HUBZone,SDB,womenOwned,SRDVOB,none ---><!--- none --->
			<cfset local.bolIsTypeNone = true/>
			<cfloop list="firm8A:8A,womenOwned:women_owned,SDB:small_disadvantaged,SRDVOB:disabled_vet_owned,HUBZone:hub_zone" index="local.lstType">
				<cfset local.bolIsTypeFlag = 1 EQ listFindNoCase("y,true", evaluate("local.qryXMLData.#listFirst(local.lstType, ':')#Flag[local.qryXMLData.recordCount]"))/>
				<cfset querySetCell(
					local.qryXMLData
					, "is_type_#listLast(local.lstType, ':')#_bt"
					, local.bolIsTypeFlag
				)/>
				<cfif local.bolIsTypeNone AND local.bolIsTypeFlag>
					<cfset local.bolIsTypeNone = false/>
				</cfif>
			</cfloop>
			<cfset querySetCell(local.qryXMLData, "is_type_none_bt", local.bolIsTypeNone)/>
			<cfset querySetCell(local.qryXMLData, "year_month_dt", dateFormat(local.qryXMLData.signedDate[local.qryXMLData.recordCount], "yyyy-mm"))/>

		</cfloop>

		<cfif len(arguments.strSmallBusinessCategory)>
			<cfquery name="local.qryXMLData" dbtype="query">
				SELECT *
				FROM local.qryXMLData
				<!--- small business???? --->
				WHERE contractingofficerbusinesssizedetermination = <cfqueryparam value="S: SMALL BUSINESS" cfsqltype="cf_sql_varchar"/>
				<cfswitch expression="#arguments.strSmallBusinessCategory#">
					<cfcase value="none">
						WHERE SRDVOBFlag IN (<cfqueryparam value="N,false" list="true" cfsqltype="cf_sql_varchar"/>)
						AND firm8AFlag IN (<cfqueryparam value="N,false" list="true" cfsqltype="cf_sql_varchar"/>)
						AND HUBZoneFlag IN (<cfqueryparam value="N,false" list="true" cfsqltype="cf_sql_varchar"/>)
						AND womenOwnedFlag IN (<cfqueryparam value="N,false" list="true" cfsqltype="cf_sql_varchar"/>)
						AND SDBFlag IN (<cfqueryparam value="N,false" list="true" cfsqltype="cf_sql_varchar"/>)
					</cfcase>
					<cfcase value="disabledVetOwned">
						WHERE SRDVOBFlag IN (<cfqueryparam value="Y,true" list="true" cfsqltype="cf_sql_varchar"/>)
					</cfcase>
					<cfcase value="8a">
						WHERE firm8AFlag IN (<cfqueryparam value="Y,true" list="true" cfsqltype="cf_sql_varchar"/>)
					</cfcase>
					<cfcase value="HUBZone">
						WHERE HUBZoneFlag IN (<cfqueryparam value="Y,true" list="true" cfsqltype="cf_sql_varchar"/>)
					</cfcase>
					<cfcase value="womanOwned">
						WHERE womenOwnedFlag IN (<cfqueryparam value="Y,true" list="true" cfsqltype="cf_sql_varchar"/>)
					</cfcase>
					<cfcase value="smallDisadv">
						WHERE SDBFlag IN (<cfqueryparam value="Y,true" list="true" cfsqltype="cf_sql_varchar"/>)
					</cfcase>
				</cfswitch>
			</cfquery>
		</cfif>

		<cfreturn local.qryXMLData/>
	</cffunction>

	<cffunction name="getBranches" returnType="query">
		<cfquery name="local.qryData" datasource="data_compiler">
			SELECT *
			FROM "branch"
			ORDER BY "branch_name_txt"
		</cfquery>
		<cfreturn local.qryData/>
	</cffunction>

	<cffunction name="getAgencyCodes" returnType="query">
		<cfargument name="intBranchID" type="numeric" default="0"/>
		<cfquery name="local.qryData" datasource="data_compiler">
			SELECT *
			FROM "OMB_agency_bureau_and_treasury_codes"
			<cfif arguments.intBranchID>
				WHERE branch_id = <cfqueryparam value="#arguments.intBranchID#" cfsqltype="cf_sql_bigint"/>
			</cfif>
			ORDER BY "agency_name_txt"
		</cfquery>
		<cfreturn local.qryData/>
	</cffunction>

	<cffunction name="getBranchesAndAgencyCodes" returnType="query">
		<cfargument name="intBranchID" type="numeric" default="0"/>
		<cfquery name="local.qryData" datasource="data_compiler">
			SELECT "b"."branch_name_txt", "oabatc"."id" AS "agency_id", "oabatc".*
			FROM "branch" b
				INNER JOIN "OMB_agency_bureau_and_treasury_codes" oabatc
					ON "oabatc"."branch_id" = "b"."id"
			<cfif arguments.intBranchID>
				WHERE "branch_id" = <cfqueryparam value="#arguments.intBranchID#" cfsqltype="cf_sql_bigint"/>
			</cfif>
			ORDER BY "branch_name_txt", "agency_name_txt"
		</cfquery>
		<cfreturn local.qryData/>
	</cffunction>

	<cffunction name="groupChartDataBySmallBusinessCategory" returnType="struct">
		<cfargument name="qryData" type="query" required="true"/>

		<cfset local.lstInitialFieldList = arguments.qryData.getColumnList()/>
		<cfset local.stcData = structNew()/>

		<cfloop list="smallBus,8a,womanOwned,smallDisadv,disabledVetOwned,HUBZone" index="local.i">
			<cfif local.i IS "smallBus">
				<cfset local.strGroupField = "contractingofficerbusinesssizedetermination"/>
				<cfset local.strGroupLabel = "Small Business"/>
				<cfset local.strGroupCriteria = "s: small business"/>
			<cfelseif local.i IS "8a">
				<cfset local.strGroupField = "firm8AFlag"/>
				<cfset local.strGroupLabel = "8A"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "womanOwned">
				<cfset local.strGroupField = "womenOwnedFlag"/>
				<cfset local.strGroupLabel = "Woman Owned"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "smallDisAdv">
				<cfset local.strGroupField = "SDBFlag"/>
				<cfset local.strGroupLabel = "Small Disadvantaged Business"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "disabledVetOwned">
				<cfset local.strGroupField = "SRDVOBFlag"/>
				<cfset local.strGroupLabel = "Disabled Veteran Owned"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "HUBZone">
				<cfset local.strGroupField = "HUBZoneFlag"/>
				<cfset local.strGroupLabel = "HUBZone"/>
				<cfset local.strGroupCriteria = "y,true"/>
			</cfif>

			<cfquery name="local.qryDataIs" dbtype="query">
				SELECT '#local.strGroupLabel#' AS small_business_category_txt
					, SUM([obligatedamount]) AS total_obligated_amount_nbr
				FROM arguments.qryData
				WHERE LOWER([#local.strGroupField#]) IN (<cfqueryparam value="#local.strGroupCriteria#" list="true" cfsqltype="cf_sql_varchar"/>)
			</cfquery>
			<cfif NOT local.qryDataIs.recordCount>
				<cfset local.qryDataIs = queryNew("small_business_category_txt,total_obligated_amount_nbr")/>
				<cfset queryAddRow(local.qryDataIs)/>
				<cfset querySetCell(local.qryDataIs, "small_business_category_txt", local.strGroupLabel)/>
				<cfset querySetCell(local.qryDataIs, "total_obligated_amount_nbr", 0.00)/>
			</cfif>

			<cfquery name="local.qryDataIsNot" dbtype="query">
				SELECT 'Not #local.strGroupLabel#' AS small_business_category_txt
					, SUM([obligatedamount]) AS total_obligated_amount_nbr
				FROM arguments.qryData
				WHERE LOWER([#local.strGroupField#]) NOT IN (<cfqueryparam value="#local.strGroupCriteria#" list="true" cfsqltype="cf_sql_varchar"/>)
			</cfquery>
			<cfif NOT local.qryDataIsNot.recordCount>
				<cfset local.qryDataIsNot = queryNew("small_business_category_txt,total_obligated_amount_nbr")/>
				<cfset queryAddRow(local.qryDataIsNot)/>
				<cfset querySetCell(local.qryDataIsNot, "small_business_category_txt", local.strGroupLabel)/>
				<cfset querySetCell(local.qryDataIsNot, "total_obligated_amount_nbr", 0.00)/>
			</cfif>

			<cfquery name="local.stcData.qryData_#local.i#" dbtype="query">
				SELECT [small_business_category_txt], [total_obligated_amount_nbr]
				FROM local.qryDataIs
				UNION ALL
				SELECT [small_business_category_txt], [total_obligated_amount_nbr]
				FROM local.qryDataIsNot
			</cfquery>

		</cfloop>

		<cfreturn local.stcData/>

	</cffunction>

	<cffunction name="separateChartDataBySmallBusinessCategory" returnType="struct">
		<cfargument name="qryData" type="query" required="true"/>

		<cfset local.lstInitialFieldList = arguments.qryData.getColumnList()/>
		<cfset local.stcData = structNew()/>

		<cfloop list="smallBus,8a,womanOwned,smallDisadv,disabledVetOwned,HUBZone" index="local.i">
			<cfif local.i IS "smallBus">
				<cfset local.strGroupField = "contractingofficerbusinesssizedetermination"/>
				<cfset local.strGroupCriteria = "s: small business"/>
			<cfelseif local.i IS "8a">
				<cfset local.strGroupField = "firm8AFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "womanOwned">
				<cfset local.strGroupField = "womenOwnedFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "smallDisAdv">
				<cfset local.strGroupField = "SDBFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "disabledVetOwned">
				<cfset local.strGroupField = "SRDVOBFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "HUBZone">
				<cfset local.strGroupField = "HUBZoneFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			</cfif>

			<cfquery name="local.stcData.qryData_#local.i#" dbtype="query">
				SELECT [signedDate]
					, SUM([obligatedAmount]) AS obligatedAmount
					, 0 AS ytd_total_obligated_amount_nbr
				FROM arguments.qryData
				WHERE LOWER([#local.strGroupField#]) IN (<cfqueryparam value="#local.strGroupCriteria#" list="true" cfsqltype="cf_sql_varchar"/>)
				GROUP BY [signedDate]
				ORDER BY [signedDate]
			</cfquery>

			<cfset local.amtTotal = 0/>
			<cfloop query="local.stcData.qryData_#local.i#">
				<cfset local.amtTotal += val(evaluate("local.stcData.qryData_#local.i#.obligatedAmount"))/>
				<cfset querySetCell(
					local.stcData["qryData_#local.i#"]
					, "ytd_total_obligated_amount_nbr"
					, local.amtTotal
					, evaluate("local.stcData.qryData_#local.i#.currentRow")
				)/>
			</cfloop>

		</cfloop>

		<cfreturn local.stcData/>

	</cffunction>

	<cffunction name="separateChartDataBySmallBusinessCategory2" returnType="struct">
		<cfargument name="qryData" type="query" required="true"/>

		<cfset local.lstInitialFieldList = arguments.qryData.getColumnList()/>
		<cfset local.stcData = structNew()/>

		<cfloop list="smallBus,8a,womanOwned,smallDisadv,disabledVetOwned,HUBZone" index="local.i">
			<cfif local.i IS "smallBus">
				<cfset local.strGroupField = "contractingofficerbusinesssizedetermination"/>
				<cfset local.strGroupCriteria = "s: small business"/>
			<cfelseif local.i IS "8a">
				<cfset local.strGroupField = "firm8AFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "womanOwned">
				<cfset local.strGroupField = "womenOwnedFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "smallDisAdv">
				<cfset local.strGroupField = "SDBFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "disabledVetOwned">
				<cfset local.strGroupField = "SRDVOBFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			<cfelseif local.i IS "HUBZone">
				<cfset local.strGroupField = "HUBZoneFlag"/>
				<cfset local.strGroupCriteria = "y,true"/>
			</cfif>

			<cfquery name="local.stcData.qryData_#local.i#" dbtype="query">
				SELECT [signedDate]
					, SUM([obligatedAmount]) AS obligatedAmount
					, 0 AS ytd_total_obligated_amount_nbr
				FROM arguments.qryData
				WHERE LOWER([#local.strGroupField#]) IN (<cfqueryparam value="#local.strGroupCriteria#" list="true" cfsqltype="cf_sql_varchar"/>)
				GROUP BY [signedDate]
				ORDER BY [signedDate]
			</cfquery>

			<cfset local.amtTotal = 0/>
			<cfloop query="local.stcData.qryData_#local.i#">
				<cfset local.amtTotal += val(evaluate("local.stcData.qryData_#local.i#.obligatedAmount"))/>
				<cfset querySetCell(
					local.stcData["qryData_#local.i#"]
					, "ytd_total_obligated_amount_nbr"
					, local.amtTotal
					, evaluate("local.stcData.qryData_#local.i#.currentRow")
				)/>
			</cfloop>

		</cfloop>

		<cfreturn local.stcData/>

	</cffunction>

	<cffunction name="queryToSpreadsheet" returnType="Any">
		<cfargument name="stcData" type="struct" required="true"/>

		<cfset local.xlsData = application.spreadsheet.new("initialSheet")/>

		<cfloop list="#structKeyList(arguments.stcData)#" index="local.strStructKeyName">
			<cfif isQuery(arguments.stcData[local.strStructKeyName])>
				<cfset local.strSheetName = reReplaceNoCase(local.strStructKeyName, "(obj|qryData_)", "", "all")/>

				<cfset application.spreadsheet.createSheet(local.xlsData, local.strSheetName)/>
				<cfset application.spreadsheet.setActiveSheet(local.xlsData, local.strSheetName)/>
				<cfset application.spreadsheet.addRow(
					workbook = local.xlsData
					, data = arguments.stcData[local.strStructKeyName].getColumnList()
				)/>
				<cfset application.spreadsheet.addRows(
					workbook = local.xlsData
					, data = arguments.stcData[local.strStructKeyName]
					, row = 2
					, column = 1
					, autoSizeColumns = true
				)/>

			<cfelseif isStruct(arguments.stcData[local.strStructKeyName])>
				<cfloop list="#structKeyList(arguments.stcData[local.strStructKeyName])#" index="local.strStructKeyName_2">
					<!--- Sub-struct will either be stcMultiSeriesData or stcDonutData --->
					<cfset local.strSheetName = reReplaceNoCase(local.strStructKeyName, "(stc|Data)", "", "all") & "_" & replaceNoCase(local.strStructKeyName_2, "qryData_", "", "all")/>

					<cfset application.spreadsheet.createSheet(local.xlsData, local.strSheetName)/>
					<cfset application.spreadsheet.setActiveSheet(local.xlsData, local.strSheetName)/>
					<cfset application.spreadsheet.addRow(
						workbook = local.xlsData
						, data = arguments.stcData[local.strStructKeyName][local.strStructKeyName_2].getColumnList()
					)/>
					<cfset application.spreadsheet.addRows(
						workbook = local.xlsData
						, data = arguments.stcData[local.strStructKeyName][local.strStructKeyName_2]
						, row = 2
						, column = 1
						, autoSizeColumns = true
					)/>
				</cfloop>
			</cfif>
		</cfloop>

		<cfset application.spreadsheet.removeSheet(local.xlsData, "initialSheet")/>
		<cfset application.spreadsheet.setActiveSheetNumber(local.xlsData, 1)/>

		<cfreturn local.xlsData/>

	</cffunction>

</cfcomponent>