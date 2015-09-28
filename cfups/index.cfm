<cfparam name="url.shipzipto" default="76114" maxlength="5" type="zipcode" >
<cfparam name="url.sw" default="1" maxlength="25" type="integer" >
<CFSET application.key = '5CDCC4D0A67945F5'>
<CFSET application.username = 'powervida333'>
<CFSET application.password = 'powervida4417'>

<CFSET this.ShipFromZip = '78734'>
<CFSET this.pkgWeight = '3'>
<CFSET this.pkgType = '01'>
<cfset st = createObject("component", "org.camden.ups.rateservice").init(application.key, application.username, application.password)>

<!--- Use this to show package types--->
<cfdump var="#st.getValidPackageTypes()#">


<cfset packages = arrayNew(1)>

<cfset arrayAppend(packages, st.getPackageStruct(weight=url.sw,width=2,length=3,height=1,packagetype="02", declaredvalue=0))>
<!--- 
<cfset arrayAppend(packages, st.getPackageStruct(weight=10,width=20,length=40,height=10,packagetype="03"))>
<cfset arrayAppend(packages, st.getPackageStruct(weight=10,packagetype="03"))>
--->

<cfset rates = st.getRateInformation(shipperpostalcode=this.ShipFromZip,packages=packages,shiptopostalcode=url.shipzipto)>
<CFQUERY name="GetData" dbtype="query" > 
	SELECT #this.ShipFromZip# ShipFrom,#url.shipzipto# shipto, billingweight, service,totalcharges FROM rates
</CFQUERY>
<CFDUMP var="#GetData#" >



<!--- package types
Valid values: 00 = UNKNOWN; 01 = UPS Letter;
02 = Package; 03 = Tube; 04 = Pak; 21 =
Express Box; 24 = 25KG Box; 25 = 10KG Box;
30 = Pallet; 2a = Small Express Box; 2b =
Medium Express Box; 2c = Large Express Box
--->