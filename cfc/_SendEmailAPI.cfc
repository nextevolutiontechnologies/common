<cfcomponent output="no"  hint="This list of methods can be used to Send Email">
<cffunction name="SendShoppingConfirmation" returntype="boolean" output="no" access="remote">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<CFSET retvar  = 0>
		<CFQUERY name="pGetOrdEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1310
		</CFQUERY>
	
		<cfstoredproc procedure="dbo.pGetOrderInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetOrderInfo_Results">
			<cfprocparam variable="intOrderID" cfsqltype="cf_sql_integer"  value="#arguments.OrderID#">	
		</cfstoredproc>
		
		<CFSET LineItems = ValueList(pGetOrderInfo_Results.strProduct,"<BR>")>
		
		
		<cfset efrom = pGetOrdEmailInfoResults.strFrom>
		<cfset eSubject = pGetOrdEmailInfoResults.strSubject & " Order ##:"  &  arguments.OrderID >
		<cfset eto = pGetOrderInfo_Results.strOrderFirstName & " " & pGetOrderInfo_Results.strOrderLastName  & "<" & pGetOrderInfo_Results.strEmail & ">">
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
		<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
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
<cffunction name="SendEmailValidation" returntype="numeric" output="no" access="remote">
	<cfargument name="intMemberID" type="numeric" required="no" default="0">
	<CFSET retvar  = 0>
	<CFTRY>
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1000
		</CFQUERY>
		
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberInfo_Result">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
		</cfstoredproc>
		
		
		<cfset efrom = pGetEmailInfoResults.strFrom>
		<cfset eSubject = pGetEmailInfoResults.strSubject>
		<cfset eto = pGetMemberInfo_Result.strFullName  & '<' & pGetMemberInfo_Result.strEmail & '>'>

		<CFSAVECONTENT variable="EmailContent">
			<CFOUTPUT>
			
			 #REPLACE(
            	REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
							pGetEmailInfoResults.strContent,'$$REPFIRSTNAME$$',PGETMEMBERINFO_RESULT.strFirstname,"All" )
						,"$$REPEMAIL$$",pGetmemberinfo_result.strEmail,"ALL" )
					,"$$MEMBERKEY$$",pGetmemberinfo_result.strMemberGUID,"All" )
				,"$$REPUSERNAME$$",pGetmemberinfo_result.strusername,"all" )
			,"$$SITEURL$$",Application.PublicURL,"All")
			#
			</CFOUTPUT>
		</CFSAVECONTENT>
		
		<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
			<cfinvokeargument name="SendFROM" value="#efrom#">
			<cfinvokeargument name="SendTO" value="#eto#">
			<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
			<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
		</CFINVOKE>
		
		<CFQUERY name="UpdateStatus" datasource="#Application.Datasource#">
			UPDATE MEMBER
			SET intStatusID = 100 
			WHERE intMemberID = #arguments.intMemberID#
		</CFQUERY>
		<CFSET retvar  = 1>
		<CFCATCH>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	
	<cfreturn retvar>
</cffunction>
<cffunction name="SendResetPassword" returntype="boolean" output="no" access="remote">
	<cfargument name="intMemberID" type="numeric" required="Yes">
	<CFSET retvar  = 0>
	
		
		
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="PGETMEMBERINFO_RESULT">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
		</cfstoredproc>
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT e.intEmailID,e.strFrom,el.strSubject,el.strContent
			FROM dbo.EMAIL e with (nolock) 
				INNER JOIN dbo.EMAIL_LANG el with (nolock) on  e.intEmailID = el.intEmailID 
			WHERE e.intEmailID = 1100
			
		</CFQUERY>
		
		
		<CFINVOKE component="common.cfc.SecureAPI" method="ResetPassword"  returnVariable="ResetPasswordResults">
			<cfinvokeargument name="intMemberID" value="#arguments.intMemberID#">
		</CFINVOKE>
		
		
		<cfset efrom = pGetEmailInfoResults.strFrom>
		<cfset eSubject = pGetEmailInfoResults.strSubject>
		<cfset eto = PGETMEMBERINFO_RESULT.strFullName  & '<' & PGETMEMBERINFO_RESULT.strEmail & '>'>
		
		<CFSAVECONTENT variable="EmailContent">
			<CFOUTPUT>
			
			 #REPLACE(
            	REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
							pGetEmailInfoResults.strContent,'$$MEMBERNAME$$',PGETMEMBERINFO_RESULT.strFirstname,"All" )
						,"$$MEMBEREMAIL$$",pGetmemberinfo_result.strEmail,"ALL" )
					,"$$MEMBERPASSWORD$$",ResetPasswordresults,"All" )
				,"$$MEMBERUSERNAME$$",pGetmemberinfo_result.strusername,"all" )
			,"$$SITEURL$$",cgi.server_name,"All")
			#
			</CFOUTPUT>
		</CFSAVECONTENT>
		
		<CFIF ResetPasswordResults NEQ "-1">
		<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
			<cfinvokeargument name="SendFROM" value="#efrom#">
			<cfinvokeargument name="SendTO" value="#eto#">
			<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
			<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
		</CFINVOKE>
			<CFSET retvar  = 2>
		<CFELSE>
			<CFSET retvar  = -2>
		</CFIF>
	<CFTRY>	<CFCATCH>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="SendForgotPassword" returntype="boolean" output="no" access="remote">
	<cfargument name="strUserName" type="string" required="yes">
	<cfargument name="strEmail" type="string" required="yes">
	
	<CFSET retvar  = 0>
		
	
		
	<cfstoredproc procedure="dbo.pCheckMemberByUserNameEmail" debug="yes" datasource="#application.datasource#">		
		<cfprocresult name="pGetMemberInfoResults">
		<cfprocparam variable="strUserName" cfsqltype="cf_sql_VARCHAR"  value="#arguments.strUserName#">
		<cfprocparam variable="strEmail" cfsqltype="cf_sql_VARCHAR"  value="#arguments.strEmail#">	
	</cfstoredproc>
	
	<CFIF pGetMemberInfoResults.intMemberID GT 0>
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1200
		</CFQUERY>
		
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberInfo_Result">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#pGetMemberInfoResults.intMemberID#">	
		</cfstoredproc>
		
		<CFINVOKE component="common.cfc.SecureAPI" method="ResetPassword"  returnVariable="ResetPasswordResults">
			<cfinvokeargument name="intMemberID" value="#pGetMemberInfoResults.intMemberID#">
		</CFINVOKE>
		
		
		<cfset efrom = pGetEmailInfoResults.strFrom>
		<cfset eSubject = pGetEmailInfoResults.strSubject>
		<cfset eto = pGetMemberInfo_Result.strFullName  & '<' & pGetMemberInfo_Result.strEmail & '>'>
		
		<CFSAVECONTENT variable="EmailContent">
			<CFOUTPUT>
			 #REPLACE(
            	REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
							pGetEmailInfoResults.strContent,'$$REPFIRSTNAME$$',PGETMEMBERINFO_RESULT.strFirstname,"All" )
						,"$$REPEMAIL$$",pGetmemberinfo_result.strEmail,"ALL" )
					,"$$NewPassword$$",ResetPasswordresults,"All" )
				,"$$REPUSERNAME$$",pGetmemberinfo_result.strusername,"all" )
			,"$$SITEURL$$",cgi.server_name,"All")
			#
			</CFOUTPUT>
		</CFSAVECONTENT>
		
		<CFIF ResetPasswordResults NEQ "-1">
			<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
				<cfinvokeargument name="SendFROM" value="#efrom#">
				<cfinvokeargument name="SendTO" value="#eto#">
				<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
				<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
			</CFINVOKE>
			<CFSET retvar  = 2>
		<CFELSE>
			<CFSET retvar  = -2>
		</CFIF>
	</CFIF>
	<CFTRY>	<CFCATCH>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="SendRegistrationConfirmation" returntype="boolean" output="no" access="remote">
	<cfargument name="intMemberID" type="numeric" required="yes">
		
	<CFSET retvar  = 0>
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1300
		</CFQUERY>
	<CFTRY>	
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberInfoResults">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
		</cfstoredproc>
		<cfset efrom = pGetEmailInfoResults.strFrom>
		<cfset eSubject = pGetEmailInfoResults.strSubject>
		<cfset eto = pGetMemberInfoResults.strFullName  & '<' & pGetMemberInfoResults.strEmail & '>'>
		
		<CFSAVECONTENT variable="EmailContent">
			<CFINCLUDE template="/emails/RegistrationConfirmation.html">
		</CFSAVECONTENT>
		
		<CFINVOKE component="common.cfc.SecureAPI" method="ResetPassword"  returnVariable="ResetPasswordResults">
			<cfinvokeargument name="intMemberID" value="#arguments.intMemberID#">
		</CFINVOKE>
		
		<CFIF ResetPasswordResults NEQ "-1">
			<CFSET Session.tpass = ResetPasswordResults>
			<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
				<cfinvokeargument name="SendFROM" value="#efrom#">
				<cfinvokeargument name="SendTO" value="#eto#">
				<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
				<cfinvokeargument name="SendCONTENT" value="#ReplaceNoCase(ReplaceNoCase(EmailContent,"$$NewPassword$$",ResetPasswordresults,"all"),"$$USERNAME$$",pGetMemberInfoResults.strUsername,"all")#">
			</CFINVOKE>
			<CFSET retvar  = 1>
		<CFELSE>
			<CFSET retvar  = -2>
		</CFIF>
		<CFCATCH>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="SendContentReview" returntype="string" output="no" access="remote">

	<cfargument name="intMemberID" type="numeric" required="yes">
	<cfargument name="intMemberReviewID" type="numeric" required="yes">
	<!--- reviewType examp. 'intContactInfo', intMainImage, intMessage or intAboutDistributor --->
	<cfargument name="reviewType" type="string" required="yes">
	<!--- need to show message approval for carrier opportunity. This message is in message table, bot member_review table --->
	<cfargument name="intMessageID" type="string" required="no">
	<CFSET retvar  = 0>
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = 1400
		</CFQUERY>
		
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberInfoResults">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
		</cfstoredproc>
		<cfset efrom = pGetEmailInfoResults.strFrom>
		<cfset eSubject = pGetEmailInfoResults.strSubject>
		<cfset eto =  pGetMemberInfoResults.strEmail>
		
		<cfstoredproc procedure="pGetMemberReviewList" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetMemberReviewResult">
			<cfprocparam variable="intMemberReviewID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberReviewID#">	
		</cfstoredproc>
		<CFSET ReviewMessage=pGetMemberReviewResult.strApprovalMsg>
		
	   	<CFIF isdefined("arguments.intMessageID") and arguments.intMessageID gt 0>
		   	<CFQUERY name="getReviewmessage" datasource="#application.datasource#">
			   	select strApprovalMsg from vGetMessage where intMessageID=#arguments.intMessageID#
		   	</CFQUERY>
		   	<CFSET ReviewMessage=getReviewmessage.strApprovalMsg>
	   	</CFIF>
	
		<CFSAVECONTENT variable="EmailContent">
			<CFIF Evaluate("pGetMemberReviewResult.#arguments.reviewType#") eq -1>
				<CFINCLUDE template="/emails/content-denied.html">
			<CFELSE>
				<CFINCLUDE template="/emails/content-accepted.html">
			</CFIF>
		</CFSAVECONTENT>
		
		
		<CFSET textString="">
		<CFIF arguments.reviewType eq 'intAboutDistributor'><CFSET textString="About Our Distributorship"></CFIF>
		<CFIF arguments.reviewType eq 'intMainImage'><CFSET textString="Main Image"></CFIF>
		<CFIF arguments.reviewType eq 'intMessage'><CFSET textString="Message"></CFIF>
		<CFIF arguments.reviewType eq 'intContactInfo'><CFSET textString="Contact Info"></CFIF>
		<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
				<cfinvokeargument name="SendFROM" value="#efrom#">
				<cfinvokeargument name="SendTO" value="#eto#">
				<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
				<cfinvokeargument name="SendCONTENT" value="#ReplaceNoCase(ReplaceNoCase(EmailContent,"$$note$$",ReviewMessage,"all"),"$$TYPE$$",textString,"all")#">
			</CFINVOKE>
		<CFSET retvar=SendEmail_results>
	<CFRETURN retvar>	
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
		
			<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
				<cfinvokeargument name="SendFROM" value="#efrom#">
				<cfinvokeargument name="SendTO" value="#eto#">
				<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
				<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
			</CFINVOKE>
		<CFSET retvar=SendEmail_results>
	<CFRETURN retvar>	
</cffunction>
<cffunction name="SendCommunicationEmail" returntype="string" output="no" access="remote">
	<cfargument name="intMemberID" type="numeric" required="yes">
	<cfargument name="intSendEmailID" type="numeric" required="yes">	
	
	<CFSET retvar  = 0>
        <cfstoredproc procedure="dbo.pGetSendEmail" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="pGetSendEmailList_Result">
			<cfprocparam variable="intSendEmailID" cfsqltype="cf_sql_INTEGER"  value="#arguments.intSendEmailID#">
		</cfstoredproc>
		<CFQUERY name="pGetEmailInfoResults" datasource="#Application.Datasource#">
			SELECT *  FROM dbo.EMAIL WHERE intEmailID = #pGetSendEmailList_Result.intEmailID#
		</CFQUERY>
		
		
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" datasource="#application.datasource#">		
			<cfprocresult name="PGETMEMBERINFO_RESULT">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_INTEGER"  value="#arguments.intMemberID#">
		</cfstoredproc>
		<!--- <cfset efrom = PGETMEMBERINFO_RESULT.strEmail> --->
		<cfset efrom =  PGETMEMBERINFO_RESULT.strFirstName & ' ' & PGETMEMBERINFO_RESULT.strlastName & '<' & PGETMEMBERINFO_RESULT.strUsername & '@' & Application.EmailDomain & '>'>
		<cfset eSubject = pGetSendEmailList_Result.strSubject>
		<!--- <cfset eto =  pGetMemberInfoResults.strEmail> --->
		<CFSET ContactIMG = "#application.PublicURL#/common/img/member/default-member.jpg">
		
		<CFIF pGetSendEmailList_Result.RecordCount gt 0 and pGetSendEmailList_Result.strEmail neq ''>
			<CFLOOP query="pGetSendEmailList_Result">
				<CFSET intSendEmailDetailsID=pGetSendEmailList_Result.intSendEmailDetailsID>
				<CFSET intSendEmailID=arguments.intSendEmailID>
			<CFSAVECONTENT variable="EmailContent">
				 <cfoutput>
			
			 
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
													pGetSendEmailList_Result.strContent,'$$REPPHONE$$',PGETMEMBERINFO_RESULT.strPhone,"All" )
												,"$$REPEMAIL$$",pGetmemberinfo_result.strEmail,"ALL" )
												,"$$EMAILTO$$",pGetSendEmailList_Result.strEmail,"ALL" )
											,"$$REPFULLNAME$$",pGetmemberinfo_result.strFullName,"All" )
										,"$$REPNUMBER$$",pGetmemberinfo_result.intRepID,"All" )
									,"$$REPUSERNAME$$",pGetmemberinfo_result.strusername,"all" )
								,"$$SITEURL$$",Application.PublicURL,"All")
							,"$$CUSTOMMESSAGE$$",pGetSendEmailList_Result.strSendEmailBody,"All" )
						,"$$EMAILTOFIRSTNAME$$",pGetSendEmailList_Result.strFirstName,"All" )
					,"$$CONTACTIMG$$",ContactIMG,"All" )
				,"$$UNSUBSCRIBEKEY$$",pGetSendEmailList_Result.strGUID)
			,"$$SENDEMAILID$$",pGetSendEmailList_Result.intSendEmailDetailsID)#
            </cfoutput>
         
			</CFSAVECONTENT>	
			<CFINVOKE component="common.cfc.SendEmailAPI" method="SendEmail" returnVariable="SendEmail_results">
				<cfinvokeargument name="SendFROM" value="#efrom#">
				<cfinvokeargument name="SendTO" value="#pGetSendEmailList_Result.strEmail#">
				<cfinvokeargument name="SendSUBJECT" value="#eSubject#">
				<cfinvokeargument name="SendCONTENT" value="#EmailContent#">
			</CFINVOKE>
			</CFLOOP>
			<CFSET retvar=SendEmail_results>
		</CFIF>
	<CFRETURN retvar>	
</cffunction>
<cffunction name="SendEmail" returntype="string" output="yes" access="remote">
	<cfargument name="SendFROM" type="string" required="yes">
	<cfargument name="SendTO" type="string" required="yes">
	<cfargument name="SendSUBJECT" type="string" required="no">
	<cfargument name="SendCONTENT" type="string" required="yes">
	<CFSET retvar  = 0>
	<CFTRY>
		<CFMAIL to="#SendTO#" from="#SendFROM#" subject="#SendSUBJECT#" type="html">#SendCONTENT#</CFMAIL>

		<CFCATCH>
			<CFSET retvar  = -1>
			<CFINCLUDE template="/error/cfcatch.cfm">
			
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction> 
</cfcomponent>
















