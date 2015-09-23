<!---
	fpds
	@author Rob Germain
	@date 9/18/15
 --->
<cfcomponent accessors="true" output="false" persistent="false">
	<cffunction name="index">
		<cfset request.xmlXMLResponse = parseXMLResponse(
			getXMLResponse().fileContent
		)/>
		<cfset event.setView("fpds/index")/>
	</cffunction>

	<cffunction name="getXMLResponse" returnType="Struct">
		<!--- <cfargument name="stcURLParams" type="struct" required="true"/> --->

		<!--- WSDLs:
			https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/Award.wsdl
			https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/IDV.wsdl

			https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/Award.wsdl
			https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/IDV.wsdl

			https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/OtherTransactionAward.wsdl
			https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/OtherTransactionIDV.wsdl

			https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/OtherTransactionAward.wsdl
			https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/OtherTransactionIDV.wsdl
		 --->
		<cfscript>
			local.strURL = "https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/Award.wsdl";
			//local.strURL = "https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/IDV.wsdl";

			//local.strURL = "https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/Award.wsdl";
			//local.strURL = "https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/IDV.wsdl";

			//local.strURL = "https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/OtherTransactionAward.wsdl";
			//local.strURL = "https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/OtherTransactionIDV.wsdl";

			//local.strURL = "https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/OtherTransactionAward.wsdl";
			//local.strURL = "https://www.fpds.gov/FPDS/GUIServices/DataCollection/contracts/1.4/OtherTransactionIDV.wsdl";
		</cfscript>
		<cfhttp method="post" url="https://www.fpds.gov/FPDS/BusinessServices/DataCollection/contracts/1.4/Award.wsdl" result="local.stcXMLResponse">
			<!--- PortType	<DomainClassName>PortType
			Binding 	<DomainClassName>Binding
			Soap-binding style	rpc
			TargetNameSpace	<DomainClassName>.wsdl --->
			<cfhttpparam type="url" name="PortType" value="AwardPortType"/>
			<cfhttpparam type="url" name="Binding" value="AwardBinding"/>
			<cfhttpparam type="url" name="Soap-binding style" value="rpc"/>
			<cfhttpparam type="url" name="TargetNameSpace" value="Award.wsdl"/>
			<cfhttpparam type="xml" name="asdf" value="#this.createXMLRequestPacket()#"/>
		</cfhttp>

		<cfreturn local.stcXMLResponse/>

	</cffunction>

	<cffunction name="createXMLRequestPacket">
		<cfsavecontent variable="local.strXMLRequestPacket">
			<schema targetNamespace="http://www.fpdsng.com/FPDS" elementFormDefault="qualified" version="1.4">
				<annotation>
					<documentation>
						<history version="1.2">
							* Using 1.2 version of Award.xsd
						</history>
						<history version="1.3">
							* Created new version 1.3 03/19/2008
							* Now uses 1.2 version of Template.xsd and 1.3 version of Award.xsd
						</history>
						<history version="1.4">
							* Created new version 1.4 08/15/2009
							* Now uses 1.4 version of Award.xsd; 1.3 Version of Template.xsd
						</history>
					</documentation>
				</annotation>
				<!-- import the required XSDs -->
				<include schemaLocation="http://www.fpdsng.com/FPDS/schema/common/1.3/Template.xsd"/>
				<include schemaLocation="http://www.fpdsng.com/FPDS/schema/DataCollection/contracts/1.4/Award.xsd"/>
				<!-- define the complex types -->
				<complexType name="awardTemplateType">
					<complexContent>
						<extension base="FPDS:templateType">
							<sequence>
								<element name="award" type="FPDS:awardType"/>
							</sequence>
						</extension>
					</complexContent>
				</complexType>
				<element name="awardTemplate" type="FPDS:awardTemplateType"/>
				<element name="awardTemplateSearchCriteria" type="FPDS:templateSearchCriteriaType"/>
			</schema>
		</cfsavecontent>
		<cfreturn local.strXMLRequestPacket/>
	</cffunction>

	<cffunction name="parseXMLResponse" returnType="any">
		<cfargument name="strXMLResponse" type="string" required="true"/>
		<cfset local.xmlResponse = xmlParse(arguments.strXMLResponse)/>
		<cfreturn local.xmlResponse/>
	</cffunction>
</cfcomponent>