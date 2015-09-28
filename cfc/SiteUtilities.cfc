<cfcomponent displayname="Utility" hint="This is to have all utility function, example: dropdown menus and etc.">
  <cffunction name="GetStateProvinceDropDown" access="remote" returntype="query">
	<cfargument name="strCountryCode" type="string" required="true" default="US"/>
	<CFTRY> 
	 <CFQUERY name="GetStateProvince" datasource="#application.datasource#">
		 select intStateID, strStateCode, strState from vGetStateProvince where 
		 strCountryCode=<cfqueryparam value="#arguments.strCountryCode#" cfsqltype="CF_SQL_VARCHAR" >
	 </CFQUERY>
	  
	 <CFCATCH>
		 <CFQUERY name="GetStateProvince" datasource="#application.datasource#">
	   		select '' as intStateID, '' as strState, '' as strStateCode, '' as strCountrycode
	   	</CFQUERY>
	</CFCATCH>
	 </CFTRY>
	 <cfreturn GetStateProvince>
  </cffunction>
<!--- 
 <cffunction name="CheckUserName" returnType="numeric" > 
	<cfargument name="strUserName" required="true" type="string">	
	<cfstoredproc procedure="pCheckUsername" datasource="#application.datasource#" debug="true">
		<cfprocparam value="#Arguments.strUsername#" cfsqltype="CF_SQL_VARCHAR">
		<cfprocresult name="CheckUserNameResult">
	</cfstoredproc>
	<cfreturn  CheckUserNameResult.intMemberID>
  </cffunction>
--->
<cffunction name="CheckMemberUsername" returnType="numeric" > 
	<cfargument name="strUserName" required="true" type="string">	
	<cfstoredproc procedure="pCheckMemberUsername" datasource="#application.datasource#" debug="true">
		<cfprocparam value="#Arguments.strUsername#" cfsqltype="CF_SQL_VARCHAR">
		<cfprocresult name="CheckUserNameResult">
	</cfstoredproc>
	<cfreturn  CheckUserNameResult.intMemberID>
 </cffunction>

<cffunction name="GetInterestedIn" access="remote" returntype="query">
	<cfargument name="strIntestedID" type="string" required="false"/>
	
	<CFTRY> 
	 <cfquery name="getInterested" datasource="#application.datasource#">
		SELECT    intInterestedInID, strInterestedInText, strIntestestedInURL, intOrderby, isActive
	    FROM      INTERESTEDIN
	    WHERE     isActive=1 
	    <cfif isdefined("arguments.strIntestedID") and #arguments.strIntestedID# gt "">
	    AND  strInterestedInText ='#listfirst('#arguments.strIntestedID#',',')#'
	    </cfif>
	    ORDER BY intOrderby
	</cfquery>
	  
	 <CFCATCH>
		 <CFQUERY name="getInterested" datasource="#application.datasource#">
	   		select '' as intInterestedInID, 'home' as  strIntestestedInURL
	   	</CFQUERY>
	</CFCATCH>
	 </CFTRY>
	 <cfreturn getInterested>
  </cffunction>
<cffunction name="GetItemsQuantity_MixandMatch" access="remote" returntype="numeric">
	<cfargument name="intNumberSelectedCheckboxes" required="true" type="numeric">	
	<cfargument name="intNumber" required="false" default="24" type="numeric">	
	<cfargument name="intPacksNumber" required="false" default="2" type="numeric">	
	
	<CFSET resultreturn=0>
	<CFTRY>
	<CFSET resultreturn=#arguments.intNumber#/#arguments.intPacksNumber#>
	<CFSET resultreturn=#resultreturn#/#arguments.intNumberSelectedCheckboxes#>
	<CFCATCH></CFCATCH>
	</CFTRY>
	<CFRETURN resultreturn>
</cffunction>
</cfcomponent>