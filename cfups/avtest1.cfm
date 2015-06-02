<cfset av = createObject("component", "org.camden.ups.addressverification").init(application.key, application.username, application.password)>

<cfset results = av.addressVerification(city="Lafayette", state="LA",postalcode="70508")>
<cfdump var="#results#">

<cfset results = av.addressVerification(city="Zoolander", state="XX",postalcode="12345")>
<cfdump var="#results#">


<cfset results = av.streetAddressVerification(address="32 E 31st Street", city="New York", state="NY",postalcode="10016")>
<cfdump var="#results#" label="Results">

<cfset results = av.streetAddressVerification(address="32 E 31ST ST", city="NEW YORK", state="NY",postalcode="10016-6881")>
<cfdump var="#results#" label="Results Perfect">

	
<cfset results = av.streetAddressVerification(address="3200 S 31st Street", city="New York", state="NY",postalcode="10016")>
<cfdump var="#results#" label="Results">

<cfset results = av.streetAddressVerification(address="6523 Helen Woodward Way Suite 100", city="Rancho Santa Fe", state="CA",postalcode="92067")>
<cfdump var="#results#" label="Results">

<cfoutput>
<hr />
#av.getDisclaimer()#
</cfoutput>