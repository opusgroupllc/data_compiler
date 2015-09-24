<!---
	fpds
	@author Rob Germain
	@date 9/18/15
 --->
<cfcomponent accessors="true" output="false" persistent="false">
	<cffunction name="index">
		<!--- <cfset request.xmlXMLResponse = parseXMLResponse(
			getXMLResponse().fileContent
		)/> --->
		<cfset request.xmlXMLResponse = this.getXMLResponse()/>
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
			<cfhttpparam type="xml" value="#this.createXMLRequestPacket()#"/>
		</cfhttp>

		<cfreturn local.stcXMLResponse/>

	</cffunction>

	<cffunction name="createXMLRequestPacket">
		<cfsavecontent variable="local.strXMLRequestPacket">
			<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:m0="http://www.fpdsng.com/FPDS">
				<SOAP-ENV:Body>
					<m:get xmlns:m="urn:FADS.BusinessServices.DataCollection.Assistance" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
						<authenticationKey>
							<m0:userID></m0:userID>
							<m0:password></m0:password>
							<m0:serviceOriginatorID>String</m0:serviceOriginatorID>
						</authenticationKey>
						<assistanceID>
							<m0:agencyID>String</m0:agencyID>
							<m0:FAIN>String</m0:FAIN>
							<m0:amendmentNumber>String</m0:amendmentNumber>
							<m0:URI>String</m0:URI>
							<m0:businessFundsIndicator>St</m0:businessFundsIndicator>
						</assistanceID>
					</m:get>
				</SOAP-ENV:Body>
			</SOAP-ENV:Envelope>
		</cfsavecontent>
		<cfreturn local.strXMLRequestPacket/>
	</cffunction>

	<cffunction name="parseXMLResponse" returnType="any">
		<cfargument name="strXMLResponse" type="string" required="true"/>
		<cfset local.xmlResponse = xmlParse(arguments.strXMLResponse)/>
		<cfreturn local.xmlResponse/>
	</cffunction>
</cfcomponent>