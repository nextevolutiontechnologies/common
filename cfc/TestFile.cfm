<!---<CFINVOKE component="cfc.TaxData" method="GetTaxByZip"  returnVariable="GetTaxByZip_Results" >
</CFINVOKE>
<CFDUMP var="#GetTaxByZip_Results#" >--->


<CFINVOKE component="common.cfc.prism-pay" method="SaleRequest" returnVariable="this.SaleRequest">
	<cfinvokeargument name="CardNum" value="5454545454545454">
	<cfinvokeargument name="CardExpMonth" value="12">
	<cfinvokeargument name="CardExpYear" value="15">
	<cfinvokeargument name="CardCVV" value="123">
	<cfinvokeargument name="CardBillAddr1" value="123 West street">
	<cfinvokeargument name="CardBillAddr2" value="">
	<cfinvokeargument name="CardBillCity" value="Houston">
	<cfinvokeargument name="CardBillState" value="TX">
	<cfinvokeargument name="CardBillzip" value="77064">
	<cfinvokeargument name="Amount" value="4.25">
</CFINVOKE>



<CFDUMP var="#this.SaleRequest#">
<BR><HR>
<CFINVOKE component="common.cfc.prism-pay" method="CreatePayTokenRequest" returnVariable="this.CreatePayTokenRequest">
</CFINVOKE>
<CFDUMP var="#this.CreatePayTokenRequest#">
<CFABORT>
<cfhttp url="https://trans.merchantpartners.com/cgi-bin/process.cgi" method="Post" resolveurl="NO" > 
	<cfhttpparam type="header" name="content-type" value="text/xml; charSet=utf-8"> 
	<cfhttpparam type="FORMFIELD" name="action" value="ns_quicksale_cc" >
	<cfhttpparam type="FORMFIELD" name="acctid" value="PYVAZ" >
	<cfhttpparam type="FORMFIELD" name="merchantpin" value="Z2MYBYS6AA12WDDTKT4N2L1DB9KEN5LX">
	<cfhttpparam type="FORMFIELD" name="subid" value="" >
	<cfhttpparam type="FORMFIELD" name="Accepturl" value="http://trans.merchantpartners.com/cgi-bin/showresult.cgi" >
	<cfhttpparam type="FORMFIELD" name="Declineurl" value="http://trans.merchantpartners.com/cgi-bin/showresult.cgi" >
	<cfhttpparam type="FORMFIELD" name="emailsubject" value="Test Trans from API" >
	<cfhttpparam type="FORMFIELD" name="emailtext" value="Transaction Receipt for: @CI_NAME@
Customer Email: @CI_EMAIL@
Customer Phone: @CI_PHONE@
IP Address: @CI_IPADDR@
Customer Billing Address: @CI_BILLADDR1@
Billing Address 2: @CI_BILLADDR2@
Billing City: @CI_BILLCITY@
Billing State: @CI_BILLSTATE@
Billing Zip: @CI_BILLZIP@
Billing Country: @CI_BILLCOUNTRY@
Time of Transaction: @TIME@
Authorization Number: @AUTHNO@
Order ID: @ORDERID@
Amount of Purchase: @AMOUNT@" >
	<cfhttpparam type="FORMFIELD" name="ccname" value="John Doe" >
	<cfhttpparam type="FORMFIELD" name="ccnum" value="5454545454545454" >
	<cfhttpparam type="FORMFIELD" name="amount" value="1.25" >
	<cfhttpparam type="FORMFIELD" name="Expmon" value="12" >
	<cfhttpparam type="FORMFIELD" name="Expyear" value="15" >
	<cfhttpparam type="FORMFIELD" name="ci_email" value="john.mclaughlin@tekvation.com" >
	<cfhttpparam type="FORMFIELD" name="ci_billaddr1" value="111 One Stree" >
	<cfhttpparam type="FORMFIELD" name="ci_billaddr2" value="" >
	<cfhttpparam type="FORMFIELD" name="ci_billcity" value="Houston" >
	<cfhttpparam type="FORMFIELD" name="ci_billstate" value="TX" >
	<cfhttpparam type="FORMFIELD" name="ci_billzip" value="77064" >
	
</cfhttp>
 
<CFOUTPUT>

	#cfhttp.filecontent#
</CFOUTPUT>
<CFABORT>


<CFINVOKE component="cfc.prism-pay" method="SaleRequest" returnVariable="this.TestTerminal">
</CFINVOKE>
<CFDUMP var="#this.TestTerminal#">