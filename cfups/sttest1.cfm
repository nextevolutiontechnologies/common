<!---
1Z12345E0291980793 This is a 2nd Day Air Letter. The
tracking number is valid.

1Z12345E6692804405 This is an international World Wide
Express package of US origin. The
tracking number is valid.

1Z12345E0390515214 This is a shipment with multiple
packages sent via UPS Ground. The
shipment identification number is valid.

1Z12345E1392654435 This is a Next Day Air Saver Letter. The
tracking number is valid.

1Z12345E6892410845 This is a Next Day Air Saver Letter. The
tracking number is valid.
--->

<cfset st = createObject("component", "org.camden.ups.shipmenttracking").init(application.key, application.username, application.password)>

<cfset results = st.getTrackingInformation('1Z12345E0291980793',true)>
<cfdump var="#results#">

<cfset results = st.getTrackingInformation('1Z12345E6692804405',true)>
<cfdump var="#results#">

<cfset results = st.getTrackingInformation('1Z12345E0390515214',true)>
<cfdump var="#results#">

<cfset results = st.getTrackingInformation('1Z12345E1392654435',true)>
<cfdump var="#results#">

<cfset results = st.getTrackingInformation('1Z12345E6892410845',true)>
<cfdump var="#results#">

<cfset results = st.getTrackingInformation('1ZA7228W0297868285',true)>
<cfdump var="#results#">


<cfoutput>
<hr />
#st.getDisclaimer()#
</cfoutput>