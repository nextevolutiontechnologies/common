
<cfset tt = createObject("component", "org.camden.ups.timeintransitservice").init(application.key, application.username, application.password,true)>

<cfinvoke component="#tt#" method="getTimeInTransitInformation" returnVariable="result">
	<cfinvokeargument name="pickupday" value="#now()#">
	<cfinvokeargument name="shiptopostalcode" value="90210">
	<cfinvokeargument name="shipfrompostalcode" value="70508">
	<cfinvokeargument name="weight" value="5">
</cfinvoke>

<cfdump var="#result#">

