<cfcomponent output="no"  hint="This list of methods will be used for secure billing with IPPay">
	<cfset This.acctid="PYVAZ">
	<cfset This.MerchantPin="Z2MYBYS6AA12WDDTKT4N2L1DB9KEN5LX">
	<cfset This.PostURL="https://trans.merchantpartners.com/cgi-bin/process.cgi">
	<cfset This.subid="PWRVD">
<cftry>
 	<cfquery name="GetBrandInfo">
		SELECT TOP (1) strMerchantCode
		FROM  BRANDING 
		WHERE intBrandID = #Application.BrandID#
	</cfquery>
	
	
	<cfif GetBrandInfo.strMerchantCode NEQ ''>
		<cfset This.subid= GetBrandInfo.strMerchantCode>
	</cfif>
<cfcatch>
	<cfset This.subid="PWRVD">
</cfcatch>
</cftry>
<cffunction name="SaleRequest" returntype="string" output="no" access="remote" description="Make Payment" hint="Makes Payment pass in CC on file ">
	<cfargument name="CardNum" type="string" Required="yes">
	<cfargument name="CardExpMonth" type="string" Required="yes">
	<cfargument name="CardExpYear" type="string" Required="yes">
	<cfargument name="CardCVV" type="string" required="false" >
	<cfargument name="CardName" type="string" required="false" >
	<cfargument name="CardBillAddr1" type="string" Required="yes">
	<cfargument name="CardBillAddr2" type="string" Required="no">
	<cfargument name="CardBillCity" type="string" Required="yes">
	<cfargument name="CardBillState" type="string" Required="yes">
	<cfargument name="CardBillzip" type="string" Required="yes">
	<cfargument name="Amount" type="string" Required="yes">
	<CFSET retvar  = 0>
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
		<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
		<cfhttpparam type="FORMFIELD" name="action" value="ns_quicksale_cc" >
		<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
		<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
		<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#" >
		<cfhttpparam type="FORMFIELD" name="ccname" value="#arguments.cardname#" >
		<cfhttpparam type="FORMFIELD" name="ccnum" value="#arguments.CardNum#" >
		<cfhttpparam type="FORMFIELD" name="amount" value="#arguments.Amount#" >
		<cfhttpparam type="FORMFIELD" name="Expmon" value="#arguments.CardExpMonth#" >
		<cfhttpparam type="FORMFIELD" name="Expyear" value="#arguments.CardExpYear#" >
		<cfhttpparam type="FORMFIELD" name="cvv2" value="#arguments.CardCVV#" >
		<cfhttpparam type="FORMFIELD" name="ci_email" value="prism-pay-trans@powervida.com" >
		<cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="#arguments.CardBillAddr1#" >
		<cfhttpparam type="FORMFIELD" name="ci_billaddr2" value="#arguments.CardBillAddr2#" >
		<cfhttpparam type="FORMFIELD" name="ci_billcity" value="#arguments.CardBillCity#" >
		<cfhttpparam type="FORMFIELD" name="ci_billstate" value="#arguments.CardBillState#" >
		<cfhttpparam type="FORMFIELD" name="ci_billzip" value="#arguments.CardBillZip#" >
	</cfhttp>
 
		<CFSET retvar = cfhttp.filecontent>
		<CFTRY><CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="PayTokenRequest" returntype="string" output="no" access="remote" description="Creates a PayToken for Furture Billings" hint="Test the Connection you should recieve XML back.">
	<cfargument name="action" type="string" Required="yes">
	<cfargument name="CardNum" type="string" Required="yes">
	<cfargument name="CardExpMonth" type="string" Required="yes">
	<cfargument name="CardExpYear" type="string" Required="yes">
	<cfargument name="CardCVV" type="string" required="false" >
	<cfargument name="CardName" type="string" required="false" >
	<cfargument name="CardBillAddr1" type="string" Required="yes">
	<cfargument name="CardBillAddr2" type="string" Required="no">
	<cfargument name="CardBillCity" type="string" Required="yes">
	<cfargument name="CardBillState" type="string" Required="yes">
	<cfargument name="CardBillzip" type="string" Required="yes">
	<cfargument name="Amount" type="string" Required="yes">
	<cfargument name="CartID" type="string" Required="yes">
	
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
	<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8">
	<!--- 
	profile_add (with profileactiontype of 3)
	--->
	<cfhttpparam type="FORMFIELD" name="action" value="#arguments.action#" >
		<!---
		0 - will validate the credit card with a $1.00 Authorization. If the Authorization is
		successful the card will be added to the vault. ACH and EXTACH payment types will
		only have basic validation performed on them before they are added to the vault.
		1 - will run an Authorization of the amount requested. If the Authorization is successful
		the card will be added to the vault. The action is only allowed for credit cards.
		2 - will run a Sale for the amount requested. If the Sale is successful the payment type
		will be added to the vault.
		3 - will import the payment type to the vault and no other transaction will be run.
		(Note) Not passing or setting this name/value will default to "0".
		--->
	<cfhttpparam type="FORMFIELD" name="profileactiontype" value="2" >
	<!--- 
	1 - Credit Card
	2 - Check
	--->
	<cfhttpparam type="FORMFIELD" name="accttype" value="1" >
	
	<!--- Merchant Specific --->
	<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
	<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
	<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#">
	<cfhttpparam type="FORMFIELD" name="merchantordernumber" value="" >
	<!--- User Specific --->
	<cfhttpparam type="FORMFIELD" name="ccname" value="#arguments.CardName#" >
	<cfhttpparam type="FORMFIELD" name="ccnum" value="#arguments.CardNum#" >
	<cfhttpparam type="FORMFIELD" name="Expmon" value="#arguments.CardExpMonth#" >
	<cfhttpparam type="FORMFIELD" name="Expyear" value="#arguments.CardExpYear#" >
	<cfhttpparam type="FORMFIELD" name="cvv2" value="#arguments.CardCVV#" >
	<cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="#arguments.CardBillAddr1#" >
	<cfhttpparam type="FORMFIELD" name="ci_billaddr2" value="#arguments.CardBillAddr2#" >
	<cfhttpparam type="FORMFIELD" name="ci_billcity" value="#arguments.CardBillCity#" >
	<cfhttpparam type="FORMFIELD" name="ci_billstate" value="#arguments.CardBillState#" >
	<cfhttpparam type="FORMFIELD" name="ci_billzip" value="#arguments.CardBillZip#" >
	
	<!--- Order Specific --->
	<cfhttpparam type="FORMFIELD" name="amount" value="#arguments.Amount#" >
	</cfhttp>
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	<cfstoredproc procedure="pINSERT_xCart_Payment" debug="yes" datasource="#application.datasource#">		
		<cfprocresult name="pINSERT_xCart_Payment_Result">	
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intCartID" type="in" value="#arguments.CartID#">
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intPaymentMethodID" type="in" value="1">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentResult" type="in" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentStatus" type="in" value="#this.PaymentStatus#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentReason" type="in" value="#this.PaymentReason#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="intPaymentProfileID" type="in" value="#this.PaymentUserProfileID#">
		<cfprocparam cfsqltype="cf_sql_decimal" scale="2" variable="amtPaid" type="in" value="#ReReplace(arguments.Amount, "[^\d.]", "","ALL")#">
	</cfstoredproc>
	
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
	
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="ProfileSale" returntype="string" output="yes" access="remote" description="Creates a PayToken for Furture Billings" hint="Test the Connection you should recieve XML back.">
	<cfargument name="userprofileid" type="string" Required="yes">
	<cfargument name="last4digits" type="string" Required="yes">
	<cfargument name="CardCVV" type="string" required="false" >
	<cfargument name="Amount" type="string" Required="yes">
	<cfargument name="CartID" type="string" Required="yes">
	
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
		<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
		<cfhttpparam type="FORMFIELD" name="action" value="profile_sale" >
		<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
		<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
		<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#" >
		
		<cfhttpparam type="FORMFIELD" name="userprofileid" value="#arguments.userprofileid#">
	
		<cfhttpparam type="FORMFIELD" name="last4digits" value="#arguments.last4digits#">
		<cfhttpparam type="FORMFIELD" name="amount" value="#arguments.Amount#" >
	</cfhttp>
	
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	 <cfstoredproc procedure="pINSERT_xCart_Payment" debug="yes" datasource="#application.datasource#">		
		<cfprocresult name="pINSERT_xCart_Payment_Result">	
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intCartID" type="in" value="#arguments.CartID#">
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intPaymentMethodID" type="in" value="1">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentResult" type="in" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentStatus" type="in" value="#this.PaymentStatus#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentReason" type="in" value="#this.PaymentReason#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="intPaymentProfileID" type="in" value="#this.PaymentUserProfileID#">
	</cfstoredproc> 
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
	
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="ProfileUpdate" returntype="string" output="no" access="remote" description="Creates a PayToken for Furture Billings" hint="Test the Connection you should recieve XML back.">
	<cfargument name="userprofileid" type="string" Required="yes">
	<cfargument name="last4digits" type="string" Required="yes">
	<cfargument name="CardName" type="string" required="false" >
	<cfargument name="CardBillAddr1" type="string" Required="yes">
	<cfargument name="CardBillCity" type="string" Required="yes">
	<cfargument name="CardBillState" type="string" Required="yes">
	<cfargument name="CardBillzip" type="string" Required="yes">
	<cfargument name="CardExpMonth" type="string" Required="yes">
	<cfargument name="CardExpYear" type="string" Required="yes">
	
	
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
		<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
		<cfhttpparam type="FORMFIELD" name="action" value="profile_update" >
		<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
		<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
		<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#" >
		
		<cfhttpparam type="FORMFIELD" name="userprofileid" value="#arguments.userprofileid#" >
		<cfhttpparam type="FORMFIELD" name="last4digits" value="#arguments.last4digits#" >
		<cfhttpparam type="FORMFIELD" name="ccname" value="#arguments.CardName#" >
		<cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="#arguments.CardBillAddr1#" >
		<cfhttpparam type="FORMFIELD" name="ci_billcity" value="#arguments.CardBillCity#" >
		<cfhttpparam type="FORMFIELD" name="ci_billstate" value="#arguments.CardBillState#" >
		<cfhttpparam type="FORMFIELD" name="ci_billzip" value="#arguments.CardBillZip#" >
		<cfhttpparam type="FORMFIELD" name="Expmon" value="#arguments.CardExpMonth#" >
		<cfhttpparam type="FORMFIELD" name="Expyear" value="#arguments.CardExpYear#" >
		<cfhttpparam type="FORMFIELD" name="accttype" value="1" >
		<cfhttpparam type="FORMFIELD" name="ci_email" value="prism-pay-trans@powervida.com" >
		<cfhttpparam type="FORMFIELD" name="ci_memo" 	value="">
		<cfhttpparam type="FORMFIELD" name="merchantordernumber" value="" >
	</cfhttp>
	
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
	
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="ProfileRemove" returntype="string" output="no" access="remote" description="remove profile for Furture Billings" hint="Test the Connection you should recieve XML back.">
	<cfargument name="userprofileid" type="string" Required="yes">
	<cfargument name="last4digits" type="string" Required="yes">
	
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
		<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
		<cfhttpparam type="FORMFIELD" name="action" value="profile_delete" >
		<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
		<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#" >
		
		<cfhttpparam type="FORMFIELD" name="userprofileid" value="#arguments.userprofileid#" >
		<cfhttpparam type="FORMFIELD" name="last4digits" value="#arguments.last4digits#" >
		<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
	</cfhttp>
	
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
	
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="AddCreditCardProfile" returntype="string" output="no" access="remote" description="This method is for autoship orders. Creates a PayToken for Furture Billings" hint="Test the Connection you should recieve XML back.">
<!--- 	<cfargument name="action" type="string" Required="yes"> --->
	<cfargument name="CardNum" type="string" Required="yes">
	<cfargument name="CardExpMonth" type="string" Required="yes">
	<cfargument name="CardExpYear" type="string" Required="yes">
	<cfargument name="CardCVV" type="string" required="false" >
	<cfargument name="CardName" type="string" required="false" >
	<cfargument name="CardBillAddr1" type="string" Required="yes">
	<cfargument name="CardBillAddr2" type="string" Required="no">
	<cfargument name="CardBillCity" type="string" Required="yes">
	<cfargument name="CardBillState" type="string" Required="yes">
	<cfargument name="CardBillzip" type="string" Required="yes">
	<cfargument name="Amount" type="string" Required="yes">
	<cfargument name="CartID" type="string" Required="yes">
	
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
	<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8">
	<!--- 
	profile_add (with profileactiontype of 3)
	--->
	<cfhttpparam type="FORMFIELD" name="action" value="profile_add" >
		<!---
		0 - will validate the credit card with a $1.00 Authorization. If the Authorization is
		successful the card will be added to the vault. ACH and EXTACH payment types will
		only have basic validation performed on them before they are added to the vault.
		1 - will run an Authorization of the amount requested. If the Authorization is successful
		the card will be added to the vault. The action is only allowed for credit cards.
		2 - will run a Sale for the amount requested. If the Sale is successful the payment type
		will be added to the vault.
		3 - will import the payment type to the vault and no other transaction will be run.
		(Note) Not passing or setting this name/value will default to "0".
		--->
	<cfhttpparam type="FORMFIELD" name="profileactiontype" value="3" >
	<!--- 
	1 - Credit Card
	2 - Check
	--->
    <cfhttpparam type="FORMFIELD" name="accttype" value="1" > 
	
	<!--- Merchant Specific --->
	<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
	<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
	<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#">
	<cfhttpparam type="FORMFIELD" name="merchantordernumber" value="" >
	<!--- User Specific --->
	<cfhttpparam type="FORMFIELD" name="ccname" value="#arguments.CardName#" >
	<cfhttpparam type="FORMFIELD" name="ccnum" value="#arguments.CardNum#" >
	<cfhttpparam type="FORMFIELD" name="Expmon" value="#arguments.CardExpMonth#" >
	<cfhttpparam type="FORMFIELD" name="Expyear" value="#arguments.CardExpYear#" >
	<cfhttpparam type="FORMFIELD" name="cvv2" value="#arguments.CardCVV#" >
	<!--- <cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="#arguments.CardBillAddr1#" >
	<cfhttpparam type="FORMFIELD" name="ci_billaddr2" value="#arguments.CardBillAddr2#" >
	<cfhttpparam type="FORMFIELD" name="ci_billcity" value="#arguments.CardBillCity#" >
	<cfhttpparam type="FORMFIELD" name="ci_billstate" value="#arguments.CardBillState#" >
	<cfhttpparam type="FORMFIELD" name="ci_billzip" value="#arguments.CardBillZip#" >
	 --->
	<!--- Order Specific --->
	<!--- <cfhttpparam type="FORMFIELD" name="amount" value="#arguments.Amount#" > --->
	</cfhttp>
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	<cfstoredproc procedure="pINSERT_xCart_Payment" debug="yes" datasource="#application.datasource#">		
		<cfprocresult name="pINSERT_xCart_Payment_Result">	
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intCartID" type="in" value="#arguments.CartID#">
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intPaymentMethodID" type="in" value="1">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentResult" type="in" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentStatus" type="in" value="#this.PaymentStatus#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentReason" type="in" value="#this.PaymentReason#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="intPaymentProfileID" type="in" value="#this.PaymentUserProfileID#">
		<cfprocparam cfsqltype="cf_sql_decimal" scale="2" variable="amtPaid" type="in" value="#ReReplace(arguments.Amount, "[^\d.]", "","ALL")#">
	</cfstoredproc>
	
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
	
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="AutoshipProfileSale" returntype="string" output="yes" access="remote" description="Creates a PayToken for Furture Billings" hint="Test the Connection you should recieve XML back.">
	<cfargument name="userprofileid" type="string" Required="yes">
	<cfargument name="last4digits" type="string" Required="yes">
	<cfargument name="CardCVV" type="string" required="false" >
	<cfargument name="Amount" type="string" Required="yes">
	<cfargument name="OrderID" type="string" Required="yes">
	<cfargument name="intBrandID" type="string" Required="no">
	
	<CFIF isDefined("arguments.intBrandID") and arguments.intBrandID gt 0>
		<cfquery name="GetBrandInfoByArgs">
			SELECT TOP (1) strMerchantCode
			FROM  BRANDING 
			WHERE intBrandID = #arguments.intBrandID#
		</cfquery>
		
		
		<cfif GetBrandInfoByArgs.strMerchantCode NEQ ''>
			<cfset This.subid= GetBrandInfoByArgs.strMerchantCode>
		</cfif>
		
	</CFIF>
	
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
		<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
		<cfhttpparam type="FORMFIELD" name="action" value="profile_sale" >
		<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
		<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
		<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#" >
		
		<cfhttpparam type="FORMFIELD" name="userprofileid" value="#arguments.userprofileid#">
	
		<cfhttpparam type="FORMFIELD" name="last4digits" value="#arguments.last4digits#">
		<cfhttpparam type="FORMFIELD" name="amount" value="#arguments.Amount#" >
	</cfhttp>
	
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	 <cfstoredproc procedure="pUpdate_Order_Payment" debug="yes" datasource="#application.datasource#">		
		<cfprocresult name="pUpdate_Order_Payment_Result">	
		<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intOrderID" type="in" value="#arguments.OrderID#">
		<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentResult" type="in" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
		<cfprocparam cfsqltype="cf_sql_decimal" variable="amtPaid" scale="2" type="in" value="#arguments.Amount#">
	</cfstoredproc> 
	
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
	
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
<cffunction name="OrderProfileUpdate" returntype="string" output="yes" access="remote" description="Creates a PayToken for Furture Billings" hint="Test the Connection you should recieve XML back.">
	<cfargument name="userprofileid" type="string" Required="yes">
	<cfargument name="cardNum" type="string" Required="yes">
	<cfargument name="last4digits" type="string" Required="yes">
	<cfargument name="first6digits" type="string" Required="yes">
	<cfargument name="CardName" type="string" required="false" >
	<cfargument name="CardBillAddr1" type="string" Required="yes">
	<cfargument name="CardBillCity" type="string" Required="yes">
	<cfargument name="CardBillStateID" type="string" Required="yes">
	<cfargument name="CardBillzip" type="string" Required="yes">
	<cfargument name="CardExpMonth" type="string" Required="yes">
	<cfargument name="CardExpYear" type="string" Required="yes">
	<cfargument name="orderID" type="string" Required="yes">
	<cfargument name="methodcall" default="profile_update">
	<cfargument name="intBrandID" type="string" Required="no">
	
	<CFIF isDefined("arguments.intBrandID") and arguments.intBrandID gt 0>
		<cfquery name="GetBrandInfoByArgs">
			SELECT TOP (1) strMerchantCode
			FROM  BRANDING 
			WHERE intBrandID = #arguments.intBrandID#
		</cfquery>
		
		
		<cfif GetBrandInfoByArgs.strMerchantCode NEQ ''>
			<cfset This.subid= GetBrandInfoByArgs.strMerchantCode>
		</cfif>
	</CFIF>
	
	<CFQUERY name="GetStateList" datasource="#application.datasource#" cachedwithin="#CreateTimespan(0,1,0,0)#">
		SELECT strStateCode, strState FROM StateProvince where intStateID='#arguments.CardBillStateID#'
	</CFQUERY>
<CFIF methodcall eq 'profile_update'>
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
		<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
		<cfhttpparam type="FORMFIELD" name="action" value="profile_update" >
		<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
		<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
		<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#" >
		<cfhttpparam type="FORMFIELD" name="userprofileid" value="#arguments.userprofileid#" >
		<cfhttpparam type="FORMFIELD" name="last4digits" value="#arguments.last4digits#" >
		<cfhttpparam type="FORMFIELD" name="ccname" value="#arguments.CardName#" >
		<cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="#arguments.CardBillAddr1#" >
		<cfhttpparam type="FORMFIELD" name="ci_billcity" value="#arguments.CardBillCity#" >
		<cfhttpparam type="FORMFIELD" name="ci_billstate" value="#GetStateList.strStateCode#" >
		<cfhttpparam type="FORMFIELD" name="ci_billzip" value="#arguments.CardBillZip#" >
		<cfhttpparam type="FORMFIELD" name="Expmon" value="#arguments.CardExpMonth#" >
		<cfhttpparam type="FORMFIELD" name="Expyear" value="#arguments.CardExpYear#" >
		<cfhttpparam type="FORMFIELD" name="accttype" value="1" >
		<cfhttpparam type="FORMFIELD" name="ci_email" value="prism-pay-trans@powervida.com" >
		<cfhttpparam type="FORMFIELD" name="ci_memo" 	value="">
		<cfhttpparam type="FORMFIELD" name="merchantordernumber" value="" >
	</cfhttp> 
<CFELSE>
	<cfhttp url="#this.PostURL#" method="Post" resolveurl="NO" > 
	<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8">
	<!--- 
	profile_add (with profileactiontype of 3)
	--->
	<cfhttpparam type="FORMFIELD" name="action" value="profile_add" >
		<!---
		0 - will validate the credit card with a $1.00 Authorization. If the Authorization is
		successful the card will be added to the vault. ACH and EXTACH payment types will
		only have basic validation performed on them before they are added to the vault.
		1 - will run an Authorization of the amount requested. If the Authorization is successful
		the card will be added to the vault. The action is only allowed for credit cards.
		2 - will run a Sale for the amount requested. If the Sale is successful the payment type
		will be added to the vault.
		3 - will import the payment type to the vault and no other transaction will be run.
		(Note) Not passing or setting this name/value will default to "0".
		--->
	<cfhttpparam type="FORMFIELD" name="profileactiontype" value="3" >
	<!--- 
	1 - Credit Card
	2 - Check
	--->
    <cfhttpparam type="FORMFIELD" name="accttype" value="1" > 
	
	<!--- Merchant Specific --->
	<cfhttpparam type="FORMFIELD" name="acctid" value="#this.acctid#" >
	<cfhttpparam type="FORMFIELD" name="merchantpin" value="#this.MerchantPin#">
	<cfhttpparam type="FORMFIELD" name="subid" value="#this.subid#">
	<cfhttpparam type="FORMFIELD" name="merchantordernumber" value="" >
	<!--- User Specific --->
	<cfhttpparam type="FORMFIELD" name="ccname" value="#arguments.CardName#" >
	<cfhttpparam type="FORMFIELD" name="ccnum" value="#arguments.CardNum#" >
	<cfhttpparam type="FORMFIELD" name="Expmon" value="#arguments.CardExpMonth#" >
	<cfhttpparam type="FORMFIELD" name="Expyear" value="#arguments.CardExpYear#" >
	<cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="#arguments.CardBillAddr1#" >
<!--- 	<cfhttpparam type="FORMFIELD" name="ci_billaddr2" value="#arguments.CardBillAddr2#" > --->
	<cfhttpparam type="FORMFIELD" name="ci_billcity" value="#arguments.CardBillCity#" >
	<cfhttpparam type="FORMFIELD" name="ci_billstate" value="#GetStateList.strStateCode#" >
	<cfhttpparam type="FORMFIELD" name="ci_billzip" value="#arguments.CardBillZip#" >
	
	<!--- Order Specific --->
	<!--- <cfhttpparam type="FORMFIELD" name="amount" value="#arguments.Amount#" > --->
	</cfhttp>
</CFIF>
	<CFINVOKE component="common.cfc.CSVtoQuery" method="CSVToQuery" returnVariable="ParseSaleRequest">
		<cfinvokeargument name="CSV" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
	</CFINVOKE>
	<CFSET GetColList = 'status,reason,userprofileid'>
	<CFLOOP query="ParseSaleRequest" >
		<CFIF ListLen(Column_1,"=") GTE 2 and ListContainsNoCase(GetColList,TRIM(ListGetAt(Column_1,1,"=")),",","false")>
		<CFSET DynoVar = 'this.Payment' & TRIM(ListGetAt(Column_1,1,"=")) >
		<CFPARAM Name="#DynoVar#" default="#TRIM(ListGetAt(Column_1,2,"="))#">
		</cfif>
	</CFLOOP>
	<CFPARAM Name="this.PaymentReason" default="Accepted">
	<CFPARAM Name="this.PaymentUserProfileID" default="0">
	<CFOUTPUT>#this.PaymentReason#</CFOUTPUT>
	<CFOUTPUT>#this.PaymentUserProfileID#</CFOUTPUT>
	<CFOUTPUT>#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#</CFOUTPUT>
	
	<CFSET retvar  = this.PaymentReason>
	<CFTRY>
		<CFIF this.PaymentReason eq 'Accepted'>
			<cfstoredproc procedure="pUpdatePaymentInfo" debug="yes" datasource="#application.datasource#">		
				<cfprocresult name="pUpdatePaymentInfo_Result">	
				<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intOrderID" type="in" value="#arguments.orderID#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strNameOnCard" type="in" value="#arguments.CardName#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strLast4" type="in" value="#arguments.last4digits#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strFirst6" type="in" value="#arguments.first6digits#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strCCExp"  type="in" value="#arguments.CardExpMonth#/#arguments.CardExpYear#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPayToken" type="in" value="#this.PaymentUserProfileID#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strPaymentResult" type="in" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strBillingAddress" type="in" value="#arguments.CardBillAddr1#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strBillingCity" type="in" value="#arguments.CardBillCity#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="intBillingStateID" type="in" value="#arguments.CardBillStateID#">
				<cfprocparam cfsqltype="cf_sql_nvarchar" variable="strBillingZip" type="in" value="#arguments.CardBillzip#">
			</cfstoredproc> 
	</CFIF>
	 	<cfstoredproc procedure="pINSERT_ORDER_NOTE" debug="yes" datasource="#application.datasource#">		
			<cfprocresult name="pINSERT_ORDER_NOTE_Result">	
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intOrderID" type="in" value="#arguments.OrderID#">
			<cfprocparam cfsqltype="CF_SQL_INTEGER" variable="intMemberID" type="in" value="#session.memberID#">
			<CFIF this.PaymentReason eq 'Accepted'>
			<cfprocparam cfsqltype="CF_SQL_NVARCHAR" variable="stOrderNote" type="in" value="Billing Information updated">
			<CFELSE>
			<cfprocparam cfsqltype="CF_SQL_NVARCHAR" variable="stOrderNote" type="in" value="Billing Information DECLINED">
			</CFIF>
			<cfprocparam cfsqltype="CF_SQL_NVARCHAR" variable="strPaymentResult" type="in" value="#Trim(ReplaceNoCase(cfhttp.filecontent,'<html><body><plaintext>',''))#">
		</cfstoredproc>
		<CFCATCH>
			<CFSET retvar  = -1>
		</CFCATCH>
	</CFTRY>
	<cfreturn retvar>
</cffunction>
</cfcomponent>
















