<cfcomponent name="FolioAPI">
	<cfset this.baseHref = "https://api.foliofn.com/restapi">
	<cfset this.apiKey = "zEK9xjb4WXa0q3rSFSu7">
	<cfset this.ShareSec = "049sbBOXtlj8rgGWRFqqhLe0kH1YWUl3cRnif2uK">
	
	<cfset this.debug = false>
	<cfset this.counter = 10000>
		
	<cffunction name="init" output="true" returntype="FolioAPI">
		<cfargument name="baseHref" type="string" required="yes">
		<cfargument name="apiKey" type="string" required="yes">
		<cfargument name="debug" type="string" required="no" default="false">

		<cfset this.baseHref = ARGUMENTS.baseHref>
		<cfset this.apiKey = ARGUMENTS.apiKey>
		<cfset this.debug = ARGUMENTS.debug>
		
		<cfif this.debug EQ true>
			<cfoutput>
			<style type="text/css">
				div.debugContainer {font-family: courier new; position: relative; min-height: 50px; padding: 10px 20px 10px 30px; border-bottom: 1px ##aaa dashed; }
				div.debugContainer h3 { line-height: 10px; font-weight: bold; }
				div.debugContainer h3 span { font-weight: normal; background: ##EDF5F4; color: ##000; }
				div.debugContainer div.info { margin-left: 20px; }
				div.status { position: absolute;top: 0px;left: 0px; height: 100%; }
			</style>
			</cfoutput>
		</cfif>
		
		<cfreturn this>
	</cffunction>
	

<!---
	Call Functions	
--->

<!---
	Projects
--->
	<cffunction name="getAccounts" returntype="struct">
		<cfargument name="filter" required="no" type="string">
		
		<cfset var parameters = StructNew()>
		<cfset var responseObject = StructNew()>
		
		<cfif StructKeyExists( ARGUMENTS, "filter" )>
			<cfset parameters["find"] = ARGUMENTS.filter>
			
			<cfset responseObject = this.runAPICall(
				call = "GET /accounts",
				params = parameters
			)>
		<cfelse>
			<cfset responseObject = this.runAPICall(
				call = "GET /accounts"
			)>
		</cfif>
		
		<cfreturn responseObject>
	</cffunction>
	<cffunction name="getAccount" returntype="struct">
		<cfargument name="filter" required="no" type="string">
		
		<cfset var parameters = StructNew()>
		<cfset var responseObject = StructNew()>
		
		<cfif StructKeyExists( ARGUMENTS, "filter" )>
			<cfset parameters["find"] = ARGUMENTS.filter>
			
			<cfset responseObject = this.runAPICall(
				call = "GET /accounts/RA0459300R",
				params = parameters
			)>
		<cfelse>
			<cfset responseObject = this.runAPICall(
				call = "GET /accounts/RA0459300R"
			)>
		</cfif>
		
		<cfreturn responseObject>
	</cffunction>
	
<!---
	Helper functions
--->
	<cffunction name="runAPICall" returntype="struct">
		<cfargument name="call" type="string" required="yes">
		<cfargument name="body" type="string" required="no" default="">
		<cfargument name="params" type="struct" required="no" >
		
		<cfset var locals = StructNew()>
		<cfset var response = StructNew()>
		<cfset response.object = StructNew()>
        <cfset response.header = StructNew()>
        <cfset response.status = "OK">
		<cfset response.object.call = ARGUMENTS.call>
		
		<!--- here is the Dynamic Coldfusion version and the Values from each step --->
		<!--- Timestamp --->
		<cfset currentDate = dateTimeFormat(NOW(),"yyyy-mm-dd","PST") />
		<cfset currentTime = dateTimeFormat(NOW(),"HH:nn:ss.sss","PST") & '-07:00' />
		<cfset currentTimeEncoded = ReplaceNoCase(currentTime,":","%3A","all" )/>
		<!--- Signature String --->
		<cfset DynamicSignature = 'GET\nhttps://api.foliofn.com/restapi/accounts\n'& currentDate & 'T' & currentTime & '\n' & lcase(HASH(''))  />
		<!--- HMAC sha256 Encrypt Steps --->
		<cfset DynamicSignature = replace( DynamicSignature, "\n", chr( 10 ), "all" ) />
		<cfset DynamicSignatureEncrypted = BinaryEncode(BinaryDecode(lcase(hmac(DynamicSignature, this.ShareSec, "hmacsha256" )),"hex"),"base64") />
		<!--- URL Encode Steps --->
		<cfset DynamicURLEncodeCF = URLEncodedFormat(DynamicSignatureEncrypted) />
		<!--- Final Auth Header  --->
		<cfset DynamicAuthHeaderCF = 'FOLIOWS FOLIOWS_API_KEY="' & this.apiKey &  '",FOLIOWS_SIGNATURE="' & DynamicURLEncodeCF & '",FOLIOWS_TIMESTAMP="' & currentDate & 'T' & currentTimeEncoded & '"' />
			
		
		<!--- Execute the API call 
		<cfset callURL = this.baseHref & Right( locals.URL, Len( locals.URL )-1 )>
--->
		
		<cfhttp method="get" url="https://api.foliofn.com/restapi/accounts">
			<cfhttpparam type="header" name="Authorization" value="#DynamicAuthHeaderCF#" />
			<cfhttpparam type="body" value=''>
		</cfhttp>
<cftry>
			<cfcatch type="Any">
				
				<cfif this.debug>
					<cfoutput>#outputDebugInfo( ARGUMENTS, response )#</cfoutput>
				</cfif>
				<cfset response.statuscode = cfhttp.Statuscode>
				<cfset response.status = "ERROR">
				<cfreturn response>
			</cfcatch>
		</cftry>
		
		<cfset response.header = cfhttp.Responseheader>
		
		<cfif cfhttp.Statuscode IS NOT "200" AND cfhttp.Statuscode IS NOT "200 OK" AND cfhttp.Statuscode IS NOT "201" AND cfhttp.Statuscode IS NOT "201 Created">
			<cfset response.status = "ERROR">
		</cfif>
		
		<cfif ( cfhttp.Statuscode IS "200 OK" OR cfhttp.Statuscode IS "201" OR cfhttp.Statuscode IS "201 Created" ) AND NOT Find( "cfdump", cfhttp.Filecontent )>
			<cfif cfhttp.Mimetype EQ "text/xml">
				<cftry>
					<cfset response.object = APPLICATION.API.xml2Struct.ConvertXmlToStruct( cfhttp.Filecontent, response.object )>
					<cfcatch type="Any">
						<cfif this.debug>
							<cfoutput>#outputDebugInfo( ARGUMENTS, response )#</cfoutput>
						</cfif>
						
						<cfset response.statuscode = cfhttp.Statuscode>
						<cfset response.status = "ERROR">
						<cfreturn response>
					</cfcatch>
				</cftry>
			<cfelse>
				<cftry>
					<cfset response.object = DeserializeJSON( cfhttp.Filecontent )>
					
					<cfcatch type="Any">
						
						<cfif this.debug>
							<cfoutput>#outputDebugInfo( ARGUMENTS, response )#</cfoutput>
						</cfif>
						
						<cfset response.statuscode = cfhttp.Statuscode>
						<cfset response.status = "ERROR">
						<cfreturn response>
					</cfcatch>
				</cftry>			
			</cfif>
		<cfelse>
			<cfif this.debug>
					<cfoutput>#outputDebugInfo( ARGUMENTS, response )#</cfoutput>
			</cfif>
			<cfset response.statuscode = cfhttp.Statuscode>
			<cfset response.status = "ERROR">
			<cfreturn response>
		</cfif>
		
		<cfif this.debug>
			<cfoutput>#outputDebugInfo( ARGUMENTS, response )#</cfoutput>
		</cfif>
		
		<cfsetting enablecfoutputonly="No">
		
		
		<cfreturn response>
		
	</cffunction>

	<cffunction name="outputDebugInfo">
		<cfargument name="args" required="yes" type="struct">
		<cfargument name="response" required="no" type="struct">
		
		<cfset var parameters = "">
		<cfif StructKeyExists( ARGUMENTS.args, "params" )>
			<cfloop collection="#ARGUMENTS.args.params#" item="item">
				<cfset parameters = parameters & item & "=" & ARGUMENTS.args.params[item] & "&amp;">
			</cfloop>
			<cfset parameters = Left( parameters, (Len( parameters ) -5 ) )>
		</cfif>
		
		
		<cfsavecontent variable="content">
			<cfoutput>
			<style type="text/css">div.dump_#this.counter# { position: absolute; right: 0px; z-index: #this.counter#; }</style>
			<div class="debugContainer" style="position: relative; min-height: 50px; padding: 10px 20px 10px 30px; border-bottom: 1px ##aaa dashed;">
				<div class="dump_#this.counter#">
					<cfdump var="#ARGUMENTS.response#" expand="no">
				</div>
				
				<h3>Call: <span>#ARGUMENTS.args.call#</span></h3>
				<div class="info" >
				<cfif StructKeyExists( ARGUMENTS.args, "body" )>
					<p><b>Body:</b><br /> #ARGUMENTS.args.body#</p>
				</cfif>
				<cfif StructKeyExists( ARGUMENTS.args, "params" )>
					<p ><b>Params:</b><br />#parameters#</p>
				</cfif>
				</div>

				<cfif ARGUMENTS.response.status EQ "OK">
					<div class="status" style="background: ##d5f0d9; font-weight: bold; padding: 2px 4px;">OK</div>
				<cfelse>
					<div class="status" style="background: ##f0d5d5; font-weight: bold; padding: 2px 4px;">ER</div>
				</cfif>
			</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn content>
	</cffunction>
	
	
	<cffunction name="buildRequestBody">
		<cfargument name="wrapper" type="string" required="no" default="body">
		<cfargument name="requestArgs" required="yes">
		<cfargument name="extraWrapper" required="no">
			
		<cfset var body = StructNew()>
		
		<cfif IsStruct( ARGUMENTS.requestArgs )>
			
			<cfloop item="key" collection="#ARGUMENTS.requestArgs#">
				<cfif StructKeyExists( ARGUMENTS.requestArgs,  key )>
					<cfif StructKeyExists( argToEleMap, key )>
						<cfif StructKeyExists( ARGUMENTS, "extraWrapper" )>
							<cfset body["#ARGUMENTS.extraWrapper#"]["#ARGUMENTS.wrapper#"]["#StructFind(argToEleMap, key)#"] = ARGUMENTS.requestArgs[ key ] />
						<cfelse>
							<cfset body["#ARGUMENTS.wrapper#"]["#StructFind(argToEleMap, key)#"] = ARGUMENTS.requestArgs[ key ] />
						</cfif>
					<cfelse>
						<cfif StructKeyExists( ARGUMENTS, "extraWrapper" )>
							<cfset body["#ARGUMENTS.extraWrapper#"]["#ARGUMENTS.wrapper#"]["#key#"] = ARGUMENTS.requestArgs[ key ] />
						<cfelse>
							<cfset body["#ARGUMENTS.wrapper#"]["#key#"] = ARGUMENTS.requestArgs[ key ] />
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset body = this.encodeJson( body )>
		<cfreturn body>
	</cffunction>
	
	
	<!--- CONVERTS DATA FROM CF TO JSON FORMAT --->
	<cffunction name="encodeJson" access="remote" returntype="string" output="No"
			hint="Converts data from CF to JSON format">
		<cfargument name="data" type="any" required="Yes" />
		<!---
			The following argument allows for formatting queries in query or struct format
			If set to query, query will be a structure of colums filled with arrays of data
			If set to array, query will be an array of records filled with a structure of columns
		--->
		<cfargument name="queryFormat" type="string" required="No" default="array" />
		<cfargument name="queryKeyCase" type="string" required="No" default="lower" />
		<cfargument name="stringNumbers" type="boolean" required="No" default=true >
		<cfargument name="formatDates" type="boolean" required="No" default=false >

		
		<!--- VARIABLE DECLARATION --->
		<cfset var jsonString = "" />
		<cfset var tempVal = "" />
		<cfset var arKeys = "" />
		<cfset var colPos = 1 />
		<cfset var i = 1 />
		
		<cfset var _data = arguments.data />

		<!--- NUMBER --->
		<cfif IsNumeric(_data)>
			<cfif ARGUMENTS.stringNumbers EQ false>
				<cfreturn ToString(_data) />
			<cfelse>
				<cfreturn '"' & ToString(_data) & '"' />
			</cfif>

		<!--- BOOLEAN --->
		<cfelseif IsBoolean(_data) AND NOT ListFindNoCase("Yes,No", _data)>
			<cfreturn LCase(ToString(_data)) />
			
		
		<!--- DATE --->
		<cfelseif IsDate(_data) AND arguments.formatDates>
			<cfreturn '"' & APPLICATION.teamworkpm.serverZuluDateFormat( _data ) & '"'>
			<!--- <cfreturn '"#DateFormat(_data, "medium")# #TimeFormat(_data, "medium")#"' />--->
		
		<!--- STRING --->
		<cfelseif IsSimpleValue(_data)>
			<cfreturn '"' & replace( Replace(JSStringFormat(_data), "/", "\/", "ALL"), "\'", "'", "ALL" ) & '"' />
		
		<!--- ARRAY --->
		<cfelseif IsArray(_data)>
			<cfset jsonString = "" />
			<cfloop from="1" to="#ArrayLen(_data)#" index="i">
				<cfset tempVal = encodeJson( _data[i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates ) />
				<cfset jsonString = ListAppend(jsonString, tempVal, ",") />
			</cfloop>
			
			<cfreturn "[" & jsonString & "]" />
		
		<!--- STRUCT --->
		<cfelseif IsStruct(_data)>
			<cfset jsonString = "" />
			<cfset arKeys = StructKeyArray(_data) />
			<cfloop from="1" to="#ArrayLen(arKeys)#" index="i">
				<cfset tempVal = encodeJson( _data[ arKeys[i] ], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates ) />
				<cfset jsonString = ListAppend(jsonString, '"' & arKeys[i] & '":' & tempVal, ",") />
			</cfloop>
			
			<cfreturn "{" & jsonString & "}" />
		
		<!--- QUERY --->
		<cfelseif IsQuery(_data)>
			<!--- Add query meta data --->
			<cfif arguments.queryKeyCase EQ "lower">
				<cfset recordcountKey = "recordcount" />
				<cfset columnlistKey = "columnlist" />
				<cfset columnlist = LCase(_data.columnlist) />
				<cfset dataKey = "data" />
			<cfelse>
				<cfset recordcountKey = "RECORDCOUNT" />
				<cfset columnlistKey = "COLUMNLIST" />
				<cfset columnlist = _data.columnlist />
				<cfset dataKey = "data" />
			</cfif>
			<cfset jsonString = '"#recordcountKey#":' & _data.recordcount />
			<cfset jsonString = jsonString & ',"#columnlistKey#":"' & columnlist & '"' />
			<cfset jsonString = jsonString & ',"#dataKey#":' />
			
			<!--- Make query a structure of arrays --->
			<cfif arguments.queryFormat EQ "query">
				<cfset jsonString = jsonString & "{" />
				<cfset colPos = 1 />
				
				<cfloop list="#_data.columnlist#" delimiters="," index="column">
					<cfif colPos GT 1>
						<cfset jsonString = jsonString & "," />
					</cfif>
					<cfif arguments.queryKeyCase EQ "lower">
						<cfset column = LCase(column) />
					</cfif>
					<cfset jsonString = jsonString & '"' & column & '":[' />
					
					<cfloop from="1" to="#_data.recordcount#" index="i">
						<!--- Get cell value; recurse to get proper format depending on string/number/boolean data type --->
						<cfset tempVal = encodeJson( _data[column][i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates ) />
						
						<cfif i GT 1>
							<cfset jsonString = jsonString & "," />
						</cfif>
						<cfset jsonString = jsonString & tempVal />
					</cfloop>
					
					<cfset jsonString = jsonString & "]" />
					
					<cfset colPos = colPos + 1 />
				</cfloop>
				<cfset jsonString = jsonString & "}" />
			<!--- Make query an array of structures --->
			<cfelse>
				<cfset jsonString = jsonString & "[" />
				<cfloop query="_data">
					<cfif CurrentRow GT 1>
						<cfset jsonString = jsonString & "," />
					</cfif>
					<cfset jsonString = jsonString & "{" />
					<cfset colPos = 1 />
					<cfloop list="#columnlist#" delimiters="," index="column">
						<cfset tempVal = encodeJson( _data[column][CurrentRow], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates ) />
						
						<cfif colPos GT 1>
							<cfset jsonString = jsonString & "," />
						</cfif>
						
						<cfif arguments.queryKeyCase EQ "lower">
							<cfset column = LCase(column) />
						</cfif>
						<cfset jsonString = jsonString & '"' & column & '":' & tempVal />
						
						<cfset colPos = colPos + 1 />
					</cfloop>
					<cfset jsonString = jsonString & "}" />
				</cfloop>
				<cfset jsonString = jsonString & "]" />
			</cfif>
			
			<!--- Wrap all query data into an object --->
			<cfreturn "{" & jsonString & "}" />
		
		<!--- UNKNOWN OBJECT TYPE --->
		<cfelse>
			<cfreturn '"' & "unknown-obj" & '"' />
		</cfif>
	</cffunction>
	<cffunction name="arrayCollectionToQuery">
    <cfargument name="arrayColl" type="Array" required="true" />

    <cfset var qResult = '' />
    <cfset var columnList = structKeyList(arrayColl[1]) />
    <cfset var typeList = ''/>
    <cfset var numericType = ''/>
    <cfset var k = '' />
    <cfset var i = 0 />

    <cfloop collection="#arrayColl[1]#" item="k">
        <cfif isNumeric(arrayColl[1][k])>
            <!--- decimal or integer? --->
            <cfset numericType = "integer">
            <cfloop from="1" to="#arrayLen(arrayColl)#" index="i">
                <cfif arrayColl[i][k] - fix(arrayColl[i][k]) gt 0>
                    <cfset numericType = "decimal" />
                    <cfbreak />
                </cfif>
            </cfloop>
            <cfset typeList = listAppend(typeList, numericType) />
        <cfelseif isSimpleValue(arrayColl[1][k])>
            <cfset typeList = listAppend(typeList, 'varchar') />
        <cfelseif isBoolean(arrayColl[1][k])>
            <cfset typeList = listAppend(typeList, 'bit') />
        <cfelseif isDate(arrayColl[1][k])>
            <cfset typeList = listAppend(typeList, 'date') />
        <cfelse>
            <cfthrow message="Invalid ArrayCollection" 
            detail="All keys in your array collection must be of one of the following types: Numeric (Int or Float), String, Boolean, Date. The following key contains data that is not one of these types: `#k#`" />
        </cfif>
    </cfloop>

    <cfset qResult = queryNew(columnList, typeList) />

    <cfloop from="1" to="#arrayLen(arrayColl)#" index="i">
        <cfset queryAddRow(qResult) />
        <cfloop collection="#arrayColl[i]#" item="k">
            <cfif not isNumeric(arrayColl[i][k]) and not isSimpleValue(arrayColl[i][k]) and not isBoolean(arrayColl[i][k]) and not isDate(arrayColl[i][k])>
                <cfthrow message="Invalid ArrayCollection" 
                detail="All keys in your array collection must be of one of the following types: Numeric (Int or Float), String, Boolean, Date. The following key contains data that is not one of these types: `#k#`" />
            </cfif>
            <cfset querySetCell(qResult,k,arrayColl[i][k]) />
        </cfloop>
    </cfloop>

    <cfreturn qResult />

</cffunction>
</cfcomponent>