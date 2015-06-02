<!--- IF the browser type of the visitor --->
<CFIF IsDefined("CGI.HTTP_USER_AGENT")>
<CFOUTPUT>	  
				<cfsavecontent variable="dumpexception">
		 		<b>Error</b>
				<CFDUMP var="#cfcatch#">
				</cfsavecontent>
				
				<cfsavecontent variable="dumpcgi">
		 		<b>CGI</b>
				<CFDUMP var="#cgi#">
				</cfsavecontent>
		
				<cfsavecontent variable="dumpclient">
		 		<b>Client</b>
				<CFDUMP var="#form#">
				</cfsavecontent>  
			
			    <CFSET strDiagnostics='#cfcatch.Message# #cfcatch.Detail#'>
			<cfstoredproc procedure="pErroLog_Insert" debug="no" datasource="#application.datasource#">		
				<cfprocresult name="pErrorLog_Result">		
				<cfprocparam variable="intAppID" cfsqltype="cf_sql_integer"  value="1">
						<cfprocparam variable="Application_Name" cfsqltype="cf_sql_varchar" value="#application.applicationname#">
				<cfprocparam variable="strErrorLog" cfsqltype="cf_sql_varchar"  value="#LEFT(cfcatch.Message,500)#">
				<cfprocparam variable="intErrorLogTypeID" cfsqltype="cf_sql_integer"  value="1">
				<cfprocparam variable="strCGIPathinfo" cfsqltype="cf_sql_varchar"  value="#LEFT(CGI.Path_Info,200)#">
				<cfprocparam variable="strDiagnostics" cfsqltype="cf_sql_varchar"  value="#LEFT(strDiagnostics,1000)#">
				<cfprocparam variable="strSQLStatement" cfsqltype="cf_sql_varchar"  null="Yes">
				<cfprocparam variable="strCGIREMOTE_ADDR" cfsqltype="cf_sql_varchar"  value="#LEFT(CGI.REMOTE_ADDR,500)#">
				<cfprocparam variable="strCGIHTTPCOOKIE" cfsqltype="cf_sql_varchar"  value="#LEFT(CGI.HTTP_COOKIE,1000)#">
				<cfprocparam variable="strCGIHTTPREFERER" cfsqltype="cf_sql_varchar"  value="#LEFT(CGI.HTTP_REFERER,500)#">
				<cfprocparam variable="strCGIHTTPUSERAGENT" cfsqltype="cf_sql_varchar"  value="#LEFT(CGI.HTTP_USER_AGENT,1000)#">
				<cfprocparam variable="strCGI" cfsqltype="cf_sql_varchar"  value="#dumpcgi#">
				<cfprocparam variable="strclient" cfsqltype="cf_sql_varchar"  value="#dumpclient#">
				<cfprocparam variable="strerror" cfsqltype="cf_sql_varchar"  value="#dumpexception#">
				<CFIF CGI.QUERY_STRING eq ''>
					<cfprocparam variable="strQueryString" cfsqltype="cf_sql_varchar"   null="Yes">
				<CFELSE>
					<cfprocparam variable="strQueryString" cfsqltype="cf_sql_varchar"  value="#LEFT(CGI.QUERY_STRING,1000)#">
				</CFIF>
			</cfstoredproc> 
		
		</CFOUTPUT>
</CFIF>
