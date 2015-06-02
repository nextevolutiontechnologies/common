<cfcomponent displayname="Secure API" hint="This is to encapsulate methods with the security level">
<cffunction name="AuthenticateUser" output="false" returntype="numeric" description="Returns intMemberID if Success, 0 - if user nto exist" access="remote">  
	<cfargument name="username" type="string" default="" required="no" displayname="user name" />
	<cfargument name="password" type="string" default="" required="no" displayname="password" />
	
	<CFSET memberID_return=0>
	<CFTRY>
		<CFQUERY name="checkUser" >
			SELECT intMemberID, intRepID, intMemberTypeID, strMemberType, strUserName, strPassword  from vGetMemberInfo 
			WHERE 
				strUserName=<cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" >
					and 
				strPassword=<cfqueryparam value="#HASH(arguments.password)#" cfsqltype="CF_SQL_VARCHAR" >
		</CFQUERY>
		<CFIF checkUser.RecordCount gt 0>
			<CFSET memberID_return=checkUser.intMemberID>
		</CFIF>
		<CFCATCH>
		</CFCATCH>
	</CFTRY>
	
	<cfreturn memberID_return>
</cffunction>
<cffunction name="GetMemberIDByUserName" output="false" returntype="numeric" description="Returns intMemberID if Success, 0 - if user nto exist" access="remote">  
	<cfargument name="username" type="string" default="" required="no" displayname="user name" />
	
	
	<CFSET memberID_return=0>
	<CFTRY>
		<CFQUERY name="checkUser" >
			SELECT intMemberID, intRepID, intMemberTypeID, strMemberType, strUserName, strPassword  from vGetMemberInfo 
			WHERE 
				strUserName=<cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" >
					
		</CFQUERY>
		<CFIF checkUser.RecordCount gt 0>
			<CFSET memberID_return=checkUser.intMemberID>
		</CFIF>
		<CFCATCH>
		</CFCATCH>
	</CFTRY>
	
	<cfreturn memberID_return>
</cffunction>
<cffunction name="CheckRegistrationKey" output="false" returntype="numeric" description="Returns intMemberID if Success, 0 - if user nto exist">  
	<cfargument name="RegistrationKey" type="string" required="yes" displayname="Registration Key to check" />
	<CFSET this.theKey='CLEVER@2014'>
	<CFSET this.myAlgorithm='CFMX_COMPAT'>
	<CFSET this.myEncoding='Base64'>
	<CFSET memberID_return=0>
	
	<CFOUTPUT>
			IN: #arguments.RegistrationKey#<BR>
			Decode: #URLDecode(arguments.RegistrationKey)#<BR>
			decrypt: #decrypt('#URLDecode(arguments.RegistrationKey)#', this.theKey, this.myAlgorithm, this.myEncoding)#
			</CFOUTPUT>

		<CFQUERY name="checkUser" >
			SELECT intMemberID, intRepID,strFullName,  intMemberTypeID, strMemberType, strUserName, strPassword  
			from vGetMemberInfo 
			WHERE intMemberID = <cfqueryparam value="#decrypt('#URLDecode(arguments.RegistrationKey)#', this.theKey, this.myAlgorithm, this.myEncoding)#" cfsqltype="CF_SQL_VARCHAR" >
		</CFQUERY>
		<CFIF checkUser.RecordCount gt 0>
			<CFSET memberID_return=checkUser.intMemberID>
		</CFIF>
	<CFTRY>	<CFCATCH>
	</CFCATCH>
	</CFTRY>
	
	<cfreturn memberID_return>
</cffunction>
<cffunction name="ChangePassword" output="false" returntype="string">
	<cfargument name="intMemberID" type="numeric" required="yes"  />
	<cfargument name="strNewPassword" type="string"  required="yes" displayname="password" />
	<cfargument name="strCurrPassword" type="string" required="yes" displayname="password" />
	<CFTRY>
		<CFSET retvar = 0>
		<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" >		
			<cfprocresult name="pGetMemberInfoResults">
			<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
		</cfstoredproc>
		
		<CFINVOKE component="common.cfc.SecureAPI" method="AuthenticateUser" returnVariable="AuthenticateUser_results">
			<cfinvokeargument name="userName" value="#pGetMemberInfoResults.strUserName#">
			<cfinvokeargument name="password" value="#arguments.strCurrPassword#">
		</CFINVOKE>
		<!--- 0 - password is incorrect, 1 - has been changed --->
		<CFIF AuthenticateUser_results GT 0>
			<cfstoredproc procedure="pUPDATE_MemberPassword" debug="no" >
				<cfprocparam variable="intMemberID" cfsqltype="cf_sql_INTEGER"  value="#arguments.intMemberID#">	
				<cfprocparam variable="strNewPassword" cfsqltype="cf_sql_VARCHAR"  value="#HASH(arguments.strNewPassword)#">
				<cfprocparam variable="isPasswordChanged" cfsqltype="cf_sql_BOOLEAN"  value=1>
				<cfprocparam cfsqltype="cf_sql_numeric" type="out" variable="return_value"> 
			</cfstoredproc>
			
			<CFINVOKE component="common.cfc.SecureAPI" method="UpdateMailPassword" returnVariable="UpdateEmailPasswordRESULTS">
				<cfinvokeargument name="strEmail" value="#pGetMemberInfoResults.strUserName#@powervida.biz">
				<cfinvokeargument name="strPassword" value="#arguments.strNewPassword#">
			</CFINVOKE>
			
			<CFSET retvar=return_value>
		<CFELSE>
			<CFSET retvar=0>
	
		</CFIF>
		<CFCATCH>
			<CFSET retvar=-1>
		</CFCATCH>
	</CFTRY>
	
	<cfreturn retvar>
</cffunction>
<cffunction name="ResetPassword" output="false" returntype="string">
	<cfargument name="intMemberID" type="numeric" required="yes">
	<cfset retvar=0>
			<cfstoredproc procedure="dbo.pGetMemberInfo" debug="no" >		
				<cfprocresult name="pGetMemberInfoResults">
				<cfprocparam variable="intMemberID" cfsqltype="cf_sql_integer"  value="#arguments.intMemberID#">	
			</cfstoredproc>
		    <CFINVOKE method="GeneratePassword" returnVariable="GeneratePassword_results"></CFINVOKE>
			
			<cfstoredproc procedure="pUPDATE_MemberPassword" debug="no" >
				<cfprocparam variable="intMemberID" cfsqltype="cf_sql_INTEGER"  value="#arguments.intMemberID#">	
				<cfprocparam variable="strNewPassword" cfsqltype="cf_sql_VARCHAR"  value="#HASH(GeneratePassword_results)#">
				<cfprocparam variable="isPasswordChanged" cfsqltype="cf_sql_BOOLEAN"  value="False">
				<cfprocparam cfsqltype="cf_sql_numeric" type="out" variable="return_value"> 
			</cfstoredproc>
			<CFINVOKE component="common.cfc.SecureAPI" method="UpdateMailPassword" returnVariable="UpdateEmailPasswordRESULTS">
				<cfinvokeargument name="strEmail" value="#pGetMemberInfoResults.strUserName#@powervida.biz">
				<cfinvokeargument name="strPassword" value="#LEFT(HASH(arguments.intmemberID),7)#">
			</CFINVOKE>
		
		<CFSET retvar = GeneratePassword_results>
		<CFTRY><CFCATCH><CFSET retvar=-1></CFCATCH>
		</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="CreateMailAccount" output="false" returntype="string">
	<cfargument name="strFullName" type="string" required="yes">
	<cfargument name="strUserName" type="string" required="yes">
	<cfargument name="strDomain" type="string" required="yes">
	<cfargument name="strPassword" type="string" required="yes">
	
	<CFTRY>
		<cfset retvar=0>
		<CFHTTP method="POST" url="http://mailapi.tekvation.net/mod/CreateMailAccount.asp">
			<CFHTTPPARAM name="txtFullName" value="#arguments.strFullName#" type="FORMFIELD">
			<CFHTTPPARAM name="cmdAddUser" value="Add" type="FORMFIELD">
			<CFHTTPPARAM name="txtDomain" value="#arguments.strDomain#" type="FORMFIELD">
			<CFHTTPPARAM name="txtUserName" value="#arguments.strUserName#" type="FORMFIELD">
			<CFHTTPPARAM name="txtPassword" value="#arguments.strPassword#" type="FORMFIELD">
		</CFHTTP>
		
		<CFSET retvar = cfhttp.filecontent>
		<CFCATCH>
			<CFSET retvar=-1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="CheckMailAccount" output="false" returntype="string">
	<cfargument name="strEmail" type="string" required="yes">
	<CFTRY>
		<cfset retvar=0>
		<CFHTTP method="post" url="http://mailapi.tekvation.net/mod/CheckMailAccount.asp">
			<CFHTTPPARAM name="txtEmail" value="#arguments.strEmail#" type="FORMFIELD">
			<CFHTTPPARAM name="cmdGetUser" value="Submit" type="FORMFIELD">
		</CFHTTP>
		<CFSET retvar = cfhttp.filecontent>
		<CFCATCH>
			<CFSET retvar=-1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="UpdateMailPassword" output="false" returntype="string">
	<cfargument name="strEmail" type="string" required="yes">
	<cfargument name="strPassword" type="string" required="yes">
	<CFTRY>
		<cfset retvar=0>
		<CFHTTP method="post" url="http://mailapi.tekvation.net/mod/UpdateMailPassword.asp?Email=#arguments.strEmail#">
			<CFHTTPPARAM name="txtPassword" value="#arguments.strPassword#" type="FORMFIELD">
			<CFHTTPPARAM name="cmdUpdateUser" value="Update changes" type="FORMFIELD">
		</CFHTTP>
		
		<CFSET retvar = cfhttp.filecontent>
		<CFCATCH><CFSET retvar=-1></CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="UpdateMailBox" output="false" returntype="string">
	<cfargument name="strEmail" type="string" required="yes">
	<cfargument name="strMailBox" type="string" required="yes">
	<CFTRY>
		<cfset retvar=0>
		<CFHTTP method="post" url="http://mailapi.tekvation.net/mod/UpdateMailBox.asp?Email=#arguments.strEmail#">
			<CFHTTPPARAM name="txtMailBox" value="#arguments.strMailBox#" type="FORMFIELD">
			<CFHTTPPARAM name="cmdUpdateUser" value="Update changes" type="FORMFIELD">
		</CFHTTP>
		
		<CFSET retvar = cfhttp.filecontent>
		<CFCATCH><CFSET retvar=-1></CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>

<cffunction name="GeneratePassword" output="false" returntype="string">
		<cfset strPassword="">
			<!--- Set up available lower case values. --->
			<cfset strLowerCaseAlpha = "abcdefghijklmnopqrstuvwxyz" />
			<!---
			Set up available upper case values. In this instance, we
			want the upper case to correspond to the lower case, so
			we are leveraging that character set.
			--->
			<cfset strUpperCaseAlpha = UCase( strLowerCaseAlpha ) />
			 
			<!--- Set up available numbers. --->
			<cfset strNumbers = "0123456789" />
			 
			<!--- Set up additional valid password chars. --->
			<cfset strOtherChars = "@##$%" />
			 
			<!---
			We are going to concatenate all the previous valid character sets.
			--->
			<!--- <cfset strAllValidChars = (
			strLowerCaseAlpha &
			strUpperCaseAlpha &
			strNumbers &
			strOtherChars
			) /> --->
			
			<cfset strAllValidChars = (
			strLowerCaseAlpha &
			strUpperCaseAlpha &
			strNumbers
			) /> 
			  
			<cfset arrPassword = ArrayNew( 1 ) />
			 
			<!---
			When creating a password, there are certain rules that we
			need to follow (as deemed by the business logic). That is,
			the password must:
			 
			- must be exactly 8 characters in length
			- must have at least 1 number
			- must have at least 1 uppercase letter
			- must have at least 1 lower case letter
			--->
			 
			<!--- Select the random number from our number set. --->
			<cfset arrPassword[ 1 ] = Mid(
			strNumbers,
			RandRange( 1, Len( strNumbers ) ),
			1
			) />
			 
			<!--- Select the random letter from our lower case set. --->
			<cfset arrPassword[ 2 ] = Mid(
			strLowerCaseAlpha,
			RandRange( 1, Len( strLowerCaseAlpha ) ),
			1
			) />
			 
			<!--- Select the random letter from our upper case set. --->
			<cfset arrPassword[ 3 ] = Mid(
			strUpperCaseAlpha,
			RandRange( 1, Len( strUpperCaseAlpha ) ),
			1
			) />
			 
			<!---
			ASSERT: At this time, we have satisfied the character
			requirements of the password, but NOT the length
			requirement. In order to do that, we must add more
			random characters to make up a proper length.
			--->
			 
			<!--- Create rest of the password. --->
			<cfloop
			index="intChar"
			from="#(ArrayLen( arrPassword ) + 1)#"
			to="8"
			step="1">
			 
			<!---
			Pick random value. For this character, we can choose
			from the entire set of valid characters.
			--->
			<cfset arrPassword[ intChar ] = Mid(
			strAllValidChars,
			RandRange( 1, Len( strAllValidChars ) ),
			1
			) />
			 
			</cfloop>
			 
			<!---
			Use the Java
			Collections utility class to shuffle this array into
			a "random" order.
			--->
			<cfset CreateObject( "java", "java.util.Collections" ).Shuffle(
			arrPassword
			) />
			 
			<!---
			Need get a single string. We can
			do this by converting the array to a list and then just
			providing no delimiters (empty string delimiter).
			--->
			<cfset strPassword = ArrayToList(
			arrPassword,
			""
			) />
			
	<cfreturn strPassword>
</cffunction>
<cffunction name="getEncryptedValue" returntype="string">
	<cfargument name="ValueToEncrypt" type="string">
	<CFSET this.theKey='RandomKeyForClient'>
	<CFSET this.myAlgorithm='CFMX_COMPAT'>
	<CFSET this.myEncoding='Base64'>

	<CFSET encryptedReturn=encrypt(arguments.ValueToEncrypt, this.theKey, this.myAlgorithm, this.myEncoding)> 
	<cfreturn encryptedReturn>
</cffunction>
<cffunction name="getDEcryptedValue" returntype="string">
	<cfargument name="ValueToDecrypt" type="string">
	<CFSET this.theKey='CLEVER@2014'>
	<CFSET this.myAlgorithm='CFMX_COMPAT'>
	<CFSET this.myEncoding='Base64'>

	<CFSET dencryptedReturn=decrypt(arguments.ValueToDecrypt, this.theKey, this.myAlgorithm, this.myEncoding)> 
	<cfreturn dencryptedReturn>
</cffunction>
<cffunction name="CheckUnsubscribeKey" output="false" returntype="numeric" description="Returns intSentEmailDetailsID if Success, 0 - if email not exist">  
	<cfargument name="UnsubscribeKey" type="string" required="yes" displayname="Registration Key to check" />
	<CFSET this.theKey='CLEVER@2014'>
	<CFSET this.myAlgorithm='CFMX_COMPAT'>
	<CFSET this.myEncoding='Base64'>
	<CFSET keyreturn=0>	
	<CFINVOKE component="cfc.SecureAPI" method="getDEcryptedValue" returnVariable="getmid">
		<cfinvokeargument name="ValueToDecrypt" value="#arguments.UnsubscribeKey#">		
	</CFINVOKE>	
	<CFTRY>	
		<cfquery name="validateEmail" >
				SELECT * FROM vGetSentEmailInfo where intSendEmailDetailsID=<cfqueryparam  cfsqltype="CF_SQL_integer" value="#getmid#">
		</cfquery>			
		<CFIF validateEmail.RecordCount gt 0>
			<CFSET keyreturn=validateEmail.intSendEmailDetailsID>
		</CFIF>
	<CFCATCH></CFCATCH>
	</CFTRY>
	
	<cfreturn keyreturn>
</cffunction>

</cfcomponent>