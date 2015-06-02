<cfcomponent output="no"  hint="This list of Email sent from Public website">
<cffunction name="SendShoppingConfirmation" returntype="boolean" output="no" access="remote">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<CFSET retvar  = 0>
	<CFSEt strEmail=''>
		<CFQUERY name="pGetOrdEmailInfoResults" datasource="#Application.Datasource#">
			<!--- SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1310 --->
			select * from vGetEmailList_NEW where intEmailID=1310 and intlangID=#session.lang#
		</CFQUERY>
	
		<cfstoredproc procedure="dbo.pGetOrderInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetOrderInfo_Results">
			<cfprocparam  variable="intOrderID" cfsqltype="cf_sql_integer"  value="#arguments.OrderID#">	
		</cfstoredproc>
		<!--- in case customer use billing on file email address could be missing int the order table, use customer table --->
		<CFSET LineItems = ValueList(pGetOrderInfo_Results.strProduct,"<BR>")>
		<CFIF pGetOrderInfo_Results.strEmail gt ''>
			<CFSET strEmail=pGetOrderInfo_Results.strEmail>
		<CFELSEIF pGetOrderInfo_Results.intCustomerID gt 0>
				<cfstoredproc procedure="dbo.pGetCustomerInfo" debug="no" datasource="#application.datasource#">		
				<cfprocresult name="pGetCustomerInfo_Results">
				<cfprocparam variable="intCustID" cfsqltype="cf_sql_integer"  value="#pGetOrderInfo_Results.intCustomerID#">	
				</cfstoredproc>
			<CFSET strEmail=pGetCustomerInfo_Results.strEmail>
		</CFIF>
		
		<cfset efrom = pGetOrdEmailInfoResults.strFrom>
		<cfset eSubject = pGetOrdEmailInfoResults.strSubject & " Order ##:"  &  arguments.OrderID >
		<cfset eto = pGetOrderInfo_Results.strOrderFirstName & " " & pGetOrderInfo_Results.strOrderLastName  & "<" & strEmail & ">">
		<CFSAVECONTENT variable="EmailContent">
		<CFOUTPUT>
						#REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(pGetOrdEmailInfoResults.strContent,"$$ORDERID$$",pGetOrderInfo_Results.intOrderID,"All")
							,"$$ORDERFIRSTNAME$$",pGetOrderInfo_Results.strOrderFirstName,"All") 
							,"$$ORDERDATE$$",DateFormat(pGetOrderInfo_Results.dtOrder,"mm/dd/yyyy"),"All")
							,"$$LINEITEMS$$",LineItems,"All")
							,"$$ORDERSUBTOTAL$$",DollarFormat(pGetOrderInfo_Results.OrderSubTotal),"All")
							,"$$ORDERTAX$$",DollarFormat(pGetOrderInfo_Results.amtTax),"All")
							,"$$ORDERSHIP$$",DollarFormat(pGetOrderInfo_Results.amtShipping),"All")
							,"$$ORDERTOTAL$$",DollarFormat(pGetOrderInfo_Results.amtOrderTotal),"All")
							,"$$LAST4CARD$$",RIGHT(pGetOrderInfo_Results.strShowCC,4),"All")
							,"$$ORDERNAME$$",pGetOrderInfo_Results.strOrderFirstName &' '& pGetOrderInfo_Results.strOrderLastName,"All")
							,"$$ORDERADDRESS$$",pGetOrderInfo_Results.strOrderAddress &' '& pGetOrderInfo_Results.strOrderAddress2,"All")
							,"$$CITYSTATEZIP$$",pGetOrderInfo_Results.strOrderCity &' '& pGetOrderInfo_Results.strOrderStateCode &' '& pGetOrderInfo_Results.strOrderZip,"All")
							,"$$ORDERCOUNTRY$$",'USA',"All")
							
				#</CFOUTPUT>
		</CFSAVECONTENT>
		<CFINVOKE component="cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
			<cfinvokeargument name="SendFROM" value="#efrom#">
			<cfinvokeargument name="SendTO" value="#eto#">
			<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
			<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
		</CFINVOKE>
			<CFTRY><CFCATCH>X
				<CFABORT>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="SendEnrollmentConfirmation" returntype="boolean" output="no" access="remote">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="MemberID" type="numeric" required="yes">
	
	<CFSET retvar  = 0>
	<CFTRY>
		<CFQUERY name="pGetOrdEmailInfoResults" datasource="#Application.Datasource#">
			<!--- SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1300 --->
			select * from vGetEmailList_NEW where intEmailID=1300 and intlangID=#session.lang#
		</CFQUERY>
		<cfstoredproc procedure="dbo.pGetOrderInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetOrderInfo_Results">
			<cfprocparam variable="intOrderID" cfsqltype="cf_sql_integer"  value="#arguments.OrderID#">	
		</cfstoredproc>
		<cfstoredproc procedure="pGetMemberInfo" debug="yes" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberInfo_Results">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.MemberID#" >
			<cfprocparam variable="strMemberGUID" cfsqltype="cf_sql_nvarchar" null='true' >	
		</cfstoredproc>
		<CFINVOKE component="cfc.SecureAPI" method="ResetPassword"  returnVariable="ResetPasswordResults">
			<cfinvokeargument name="intMemberID" value="#arguments.MemberID#">
		</CFINVOKE>
		<CFSET LineItems = ValueList(pGetOrderInfo_Results.strProduct,"<BR>")>
		
		<cfset efrom = pGetOrdEmailInfoResults.strFrom>
		<cfset eSubject = pGetOrdEmailInfoResults.strSubject & " Enrollment ##:"  &  arguments.MemberID >
		<cfset eto = " Powervida Enrollment <Enrollments@powervida.com>">
		<cfset eto = pGetMemberInfo_Results.strFirstName & " " & pGetMemberInfo_Results.strLastName  & "<" & pGetMemberInfo_Results.strEmail & ">">
		<CFSAVECONTENT variable="EmailContent">
		<CFOUTPUT>
						#REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(pGetOrdEmailInfoResults.strContent,"$$ORDERID$$",pGetOrderInfo_Results.intOrderID,"All")
							,"$$ORDERFIRSTNAME$$",pGetOrderInfo_Results.strOrderFirstName,"All") 
							,"$$ORDERDATE$$",DateFormat(pGetOrderInfo_Results.dtOrder,"mm/dd/yyyy"),"All")
							,"$$LINEITEMS$$",LineItems,"All")
							,"$$ORDERSUBTOTAL$$",DollarFormat(pGetOrderInfo_Results.OrderSubTotal),"All")
							,"$$ORDERTAX$$",DollarFormat(pGetOrderInfo_Results.amtTax),"All")
							,"$$ORDERSHIP$$",DollarFormat(pGetOrderInfo_Results.amtShipping),"All")
							,"$$ORDERTOTAL$$",DollarFormat(pGetOrderInfo_Results.amtOrderTotal),"All")
							,"$$LAST4CARD$$",RIGHT(pGetOrderInfo_Results.strShowCC,4),"All")
							,"$$MEMBERNAME$$",pGetOrderInfo_Results.strOrderFirstName &' '& pGetOrderInfo_Results.strOrderLastName,"All")
							,"$$MEMBERUSERNAME$$",pGetMemberInfo_Results.strUsername,"All")
							,"$$MEMBERPASSWORD$$",ResetPasswordResults,"All")
							,"$$ORDERADDRESS$$",pGetOrderInfo_Results.strOrderAddress &' '& pGetOrderInfo_Results.strOrderAddress2,"All")
							,"$$CITYSTATEZIP$$",pGetOrderInfo_Results.strOrderCity &' '& pGetOrderInfo_Results.strOrderStateCode &' '& pGetOrderInfo_Results.strOrderZip,"All")
							,"$$ORDERCOUNTRY$$",'USA',"All")
							
				#</CFOUTPUT>
		</CFSAVECONTENT>
		<CFINVOKE component="cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
			<cfinvokeargument name="SendFROM" value="#efrom#">
			<cfinvokeargument name="SendTO" value="#eto#">
			<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
			<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
		</CFINVOKE>
		<CFCATCH>
			<CFSET retvar  = "-1">
			<CFINCLUDE template="/error/cfcatch.cfm">
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="SendLeadEmail" returntype="string" output="no" access="remote">
	<cfargument name="intMemberID" type="numeric" required="yes">
	<cfargument name="intLeadID" type="numeric" required="yes">	
	<CFSET retvar  = 0>
     
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1500
		</CFQUERY>
		
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberInfoResults">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
		</cfstoredproc>
		<cfset efrom = pGetEmailInfoResults.strFrom>
		<cfset eSubject = pGetEmailInfoResults.strSubject>
		<cfset eto =  pGetMemberInfoResults.strEmail>
		<CFQUERY name="GetLead" datasource="#application.datasource#">
			select * 
			from vGetLEAD
			where intLeadID=#arguments.intLeadID#
		</CFQUERY>
		<CFSAVECONTENT variable="EmailContent">
		
				<CFINCLUDE template="/content/emails/contact-request.html">
		</CFSAVECONTENT>
		
			<CFINVOKE component="cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
				<cfinvokeargument name="SendFROM" value="#efrom#">
				<cfinvokeargument name="SendTO" value="#eto#">
				<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
				<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
			</CFINVOKE>
		<CFSET retvar=SendEmail_results>
	<CFRETURN retvar>	
</cffunction>
<cffunction name="SendCustomerRegistrationConfirmation" returntype="boolean" output="no" access="remote">
	<cfargument name="customerID" type="numeric" required="yes">
	
	<CFSET retvar  = 0>
		<CFQUERY name="pGetOrdEmailInfoResults" datasource="#Application.Datasource#">
			<!--- SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1303 --->
			select * from vGetEmailList_NEW where intEmailID=1303 and intlangID=#session.lang#
		</CFQUERY>
	
		<cfstoredproc procedure="dbo.pGetCustomerInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetCustomerInfo_Results">
			<cfprocparam variable="intCustID" cfsqltype="cf_sql_integer"  value="#arguments.customerID#">	
		</cfstoredproc>
		
		<CFINVOKE component="cfc.SecureAPI" method="GeneratePassword" returnVariable="GeneratePassword_results"></CFINVOKE>
		<!--- update password in customer table --->

		<cfstoredproc procedure="pUpdate_CustomerPassword" debug="yes" datasource="#application.datasource#">
			<cfprocresult name="pUpdate_CustomerPassword_Result">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intCID" type="in" value="#arguments.customerID#">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" variable="strPassword" type="in" value="#HASH(GeneratePassword_results)#">
		</cfstoredproc>
	
		<cfset efrom = pGetOrdEmailInfoResults.strFrom>
		<cfset eSubject = pGetOrdEmailInfoResults.strSubject >
		<cfset eto = pGetCustomerInfo_Results.strFirstName & " " & pGetCustomerInfo_Results.strLastName  & "<" & pGetCustomerInfo_Results.strEmail & ">">
		<CFSAVECONTENT variable="EmailContent">
		<CFOUTPUT>
						#REPLACE(
							REPLACE(pGetOrdEmailInfoResults.strContent,"$$CUSTEMAIL$$", pGetCustomerInfo_Results.strEmail,"All")
							,"$$NewPassword$$",GeneratePassword_results,"All") 
							
							
				#</CFOUTPUT>
		</CFSAVECONTENT>
		<CFINVOKE component="cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
			<cfinvokeargument name="SendFROM" value="#efrom#">
			<cfinvokeargument name="SendTO" value="#eto#">
			<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
			<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
		</CFINVOKE>
			<CFTRY><CFCATCH>X
				<CFABORT>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="ForgotPasswordCustomerEmail" returntype="boolean" output="no" access="remote">
	<cfargument name="customerID" type="numeric" required="yes">
	
	<CFSET retvar  = 0>
		<CFQUERY name="pGetOrdEmailInfoResults" datasource="#Application.Datasource#">
		<!--- 	SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1304 --->
		select * from vGetEmailList_NEW where intEmailID=1304 and intlangID=#session.lang#
		</CFQUERY>
	
		<cfstoredproc procedure="dbo.pGetCustomerInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetCustomerInfo_Results">
			<cfprocparam variable="intCustID" cfsqltype="cf_sql_integer"  value="#arguments.customerID#">	
		</cfstoredproc>
		
		<CFINVOKE component="cfc.SecureAPI" method="GeneratePassword" returnVariable="GeneratePassword_results"></CFINVOKE>
		<!--- update password in customer table --->

		<cfstoredproc procedure="pUpdate_CustomerPassword" debug="yes" datasource="#application.datasource#">
			<cfprocresult name="pUpdate_CustomerPassword_Result">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intCID" type="in" value="#arguments.customerID#">
			<cfprocparam cfsqltype="CF_SQL_VARCHAR" variable="strPassword" type="in" value="#HASH(GeneratePassword_results)#">
		</cfstoredproc>
	
		<cfset efrom = pGetOrdEmailInfoResults.strFrom>
		<cfset eSubject = pGetOrdEmailInfoResults.strSubject >
		<cfset eto = pGetCustomerInfo_Results.strFirstName & " " & pGetCustomerInfo_Results.strLastName  & "<" & pGetCustomerInfo_Results.strEmail & ">">
		<CFSAVECONTENT variable="EmailContent">
		<CFOUTPUT>
						#REPLACE(
						   REPLACE(
							REPLACE(pGetOrdEmailInfoResults.strContent,"$$CUSTEMAIL$$", pGetCustomerInfo_Results.strEmail,"All")
							,"$$NewPassword$$",GeneratePassword_results,"All") 
							,"$$REPFIRSTNAME$$",pGetCustomerInfo_Results.strFirstName,"All")
							
							
				#</CFOUTPUT>
		</CFSAVECONTENT>
		<CFINVOKE component="cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
			<cfinvokeargument name="SendFROM" value="#efrom#">
			<cfinvokeargument name="SendTO" value="#eto#">
			<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
			<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
		</CFINVOKE>
			<CFTRY><CFCATCH>X
				<CFABORT>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="SendEmail" returntype="string" output="yes" access="remote">
	<cfargument name="SendFROM" type="string" required="yes">
	<cfargument name="SendTO" type="string" required="yes">
	<cfargument name="SendSUBJECT" type="string" required="no">
	<cfargument name="SendCONTENT" type="string" required="yes">
	<CFSET retvar  = 0>
	<CFTRY> <!--- <CFOUTPUT>#SendCONTENT#</CFOUTPUT><CFABORT>  --->
		<CFMAIL to="#SendTO#" from="#SendFROM#" subject="#SendSUBJECT#" type="html">#SendCONTENT#</CFMAIL>

		<CFCATCH>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction> 
</cfcomponent>
















