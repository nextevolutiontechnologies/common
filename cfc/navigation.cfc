<cfcomponent displayname="Navigation" hint="This is to show navigation on the page will work with so many levels as you want">
	<!--- Initializing our 'variables' scoped variables...public access --->
	<cfset variables.menustring = "">
	<cfset variables.ElementLevel="">
<cffunction name="OutputMenu" access="public" returntype="string"  hint="Outputs the children of a given parent.">
      <!--- Define arguments. --->
  <cfargument name="Data" type="query" required="true" hint="Menu data query."/>
  <cfargument name="ParentID" type="numeric" required="false" default="0" hint="The ID of the parent who's children we want to output."/>
  <cfargument name="FirstULClass" required="false" type="string" default="sf-menu">
	<!--- Define the local scope. --->
    <cfset var LOCAL = StructNew() />
    <CFIF ARGUMENTS.PARENTID eq 0>
		<CFSET variables.menustring = "">
	</CFIF>
    <!--- Query for the children of the given parent. --->
    <cfquery name="LOCAL.Children" dbtype="query" debug="false" >
   	SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive
    FROM
    ARGUMENTS.Data
    WHERE
    intNavParentID = <cfqueryparam value="#ARGUMENTS.ParentID#" cfsqltype="cf_sql_integer" />
    ORDER BY
    intOrderBy ASC
    </cfquery>
     
     
    <!---
    Check to see if we found any children. This is our
    END case scenario. If there are no children then our
    recursion will come to a stop for this path.
    --->
    <cfif LOCAL.Children.RecordCount>
    <CFIF ARGUMENTS.ParentID eq 0>
    	<CFSET variables.menustring=variables.menustring & "<ul class='#ARGUMENTS.FirstULClass#'>">
	<CFELSE>
		<CFSET variables.menustring=variables.menustring & "<ul>">
	</CFIF>
    <!--- Loop over children. --->
    <cfloop query="LOCAL.Children">
    <CFIF LOCAL.Children.stNavItemClass gt ''>
		 <CFSET variables.menustring=variables.menustring & '<li class="#LOCAL.Children.stNavItemClass#">'>
	<CFELSE>
    	 <CFSET variables.menustring=variables.menustring & "<li>">
	</CFIF>
	<CFIF LOCAL.Children.strNavItemURL gt ''>
		<CFIF isDefined("u") and u gt ''>
			<CFSET variables.menustring=variables.menustring & "<a href='#Replace(LOCAL.Children.strNavItemURL,'$$u$$','#u#')#'">
		<CFELSEIF isDefined("u") and u eq ''>
				<CFSET variables.menustring=variables.menustring & "<a href='#Replace(LOCAL.Children.strNavItemURL,'/$$u$$/','')#'">
		<CFELSE>
			<CFSET variables.menustring=variables.menustring & "<a href='#LOCAL.Children.strNavItemURL#'">
		</CFIF>
	<CFELSE>
     	<CFSET variables.menustring=variables.menustring & "<a href='##'">
	</CFIF>
	<!--- added to user target= to open in a new window --->
	<CFIF LOCAL.Children.strNavItemTarget gt ''>
		<CFSET variables.menustring=variables.menustring & "target=" & LOCAL.Children.strNavItemTarget & ">">
	<CFELSE>
	    <CFSET variables.menustring=variables.menustring & ">">
	</CFIF>
     <CFSET variables.menustring=variables.menustring & "#LOCAL.Children.strNavItemNm#</a>">
    <!---
    Now that we are looking at a particular child, we want to recursively call this function (from within itself) to see if
    this child has, itself, some children.
     
    We are passing along the same data set, but instead of passing along the  original ParentID, we passing along THIS
    child's ID as the next round or Parent IDs.
    --->
    <cfset OutputMenu(Data = ARGUMENTS.Data,ParentID = LOCAL.Children.intNavItemID) />
    	<CFSET variables.menustring=variables.menustring & "</li>">
    </cfloop>
     <CFSET variables.menustring=variables.menustring & "</ul>">
     
    </cfif>
     
    <!--- Return out. --->
	<CFRETURN variables.menustring>
  </cffunction>
<cffunction name="getNavigation" returntype="any" access="remote">
		<cfargument name="page" default="1">
        <cfargument name="pageSize" default="100">
        <cfargument name="gridsortcolumn" default="">
        <cfargument name="gridsortdir" default="DESC">
		<cfargument name="NavID" required="yes">
		<cfargument name="intNavParentID" required="no">
		<CFQUERY name="GetTopNav" debug="false" >
			SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive, strInMemberTypes
			FROM  vGetNavigation WHERE intNavID=#arguments.NavID#
			<CFIF isdefined("arguments.intNavParentID") and intNavParentID gt ''>AND intNavParentID=#arguments.intNavParentID#</CFIF>
		</CFQUERY>
		<!--- next we need to get memberTypeList with wording to show in grid --->
		<cfset TestArray = ArrayNew(1)>
		<CFSET QueryAddColumn(GetTopNav, "MemberTypeListResult",  TestArray)>
		<CFSET QueryAddColumn(GetTopNav, "SelectedLink",  TestArray)>
		<CFSET QueryAddColumn(GetTopNav, "NextPage", TestArray)>
		<cfloop query="GetTopNav">
			<CFIF GetTopNav.strInMemberTypes gt ''>
			<CFQUERY name="getMemberTypeList" debug="false" >
				SELECT strMemberType  from vGetMemberType where intMemberTypeID in (#GetTopNav.strInMemberTypes#)
			</CFQUERY>
			 <cfset querySetCell(GetTopNav,'MemberTypeListResult',"#ValueList(getMemberTypeList.strMemberType)#", currentrow)>
		    <CFELSE>
		     <cfset querySetCell(GetTopNav,'MemberTypeListResult',"All Types", currentrow)>
			</CFIF>
		 <cfset querySetCell(GetTopNav,'SelectedLink',"<a href='/navigation/?CFGRIDKEY=#intNavItemID#'>Select</a>", currentrow)> 
			<!---  <cfset querySetCell(GetTopNav,'SelectedLink',"<a class='nav-modal' href='EditNavPop.cfm?CFGRIDKEY=#intNavItemID#'>Edit</a>", currentrow)> --->
			 <CFQUERY name="CheckifSublevelExists" debug="false" >
				 SELECT intNavItemID from vGetNavigation where intNavID=#arguments.NavID# and intNavParentID=#GetTopNav.intNavItemID#
			  </CFQUERY>
			 <CFIF CheckifSublevelExists.RecordCount gt 0>
				 <cfset querySetCell(GetTopNav, 'NextPage', "<a href='/site-manager/navigation/navigation.cfm?thisNavID=#arguments.NavID#&thisNavParentID=#GetTopNav.intNavItemID#'>Sub Level</a>", currentrow)>
			 <CFELSE>
			 	<cfset querySetCell(getTopNav, 'NextPage', '')>
			</CFIF>
		</cfloop>
		
		<cfset result = QueryConvertForGrid(GetTopNav, page, pageSize)>
	<cfreturn result>
</cffunction>


<cffunction name="getNavigationList" returntype="query" access="remote">
		<cfargument name="NavID" required="yes">
		<cfargument name="intNavParentID" required="no">
		<CFQUERY name="GetTopNav" debug="false" >
			SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive, strInMemberTypes
			FROM  vGetNavigation WHERE intNavID=#arguments.NavID#
			<CFIF isdefined("arguments.intNavParentID") and intNavParentID gt ''>AND intNavParentID=#arguments.intNavParentID#</CFIF>
		</CFQUERY>
		<!--- next we need to get memberTypeList with wording to show in grid --->
		<cfset TestArray = ArrayNew(1)>
		<CFSET QueryAddColumn(GetTopNav, "MemberTypeListResult",  TestArray)>

		<CFSET QueryAddColumn(GetTopNav, "NextPage", TestArray)>
		<cfloop query="GetTopNav">
			<CFIF GetTopNav.strInMemberTypes gt ''>
			<CFQUERY name="getMemberTypeList" debug="false" >
				SELECT strMemberType  from vGetMemberType where intMemberTypeID in (#GetTopNav.strInMemberTypes#)
			</CFQUERY>
			 <cfset querySetCell(GetTopNav,'MemberTypeListResult',"#ValueList(getMemberTypeList.strMemberType)#", currentrow)>
		    <CFELSE>
		     <cfset querySetCell(GetTopNav,'MemberTypeListResult',"All Types", currentrow)>
			</CFIF>

 
			<!---  <cfset querySetCell(GetTopNav,'SelectedLink',"<a class='review' href='EditNavPop.cfm?CFGRIDKEY=#intNavItemID#&thisNavID=#arguments.NavID#'>Edit</a>", currentrow)> --->
			 <CFQUERY name="CheckifSublevelExists" debug="false" >
				 SELECT intNavItemID from vGetNavigation where intNavID=#arguments.NavID# and intNavParentID=#GetTopNav.intNavItemID#
			  </CFQUERY>
			 <CFIF CheckifSublevelExists.RecordCount gt 0>
				 <cfset querySetCell(GetTopNav, 'NextPage', "<a href='/site-manager/navigation/navigation.cfm?thisNavID=#arguments.NavID#&thisNavParentID=#GetTopNav.intNavItemID#' class='review'>Sub Level</a>", currentrow)>
			 <CFELSE>
			 	<cfset querySetCell(getTopNav, 'NextPage', '')>
			</CFIF>
		</cfloop>
		
		
	<cfreturn GetTopNav>
</cffunction>

<!--- <cffunction name="DropDownSelect" access="remote" returntype="query"  hint="">

      <!--- Define arguments. --->
 <!---  <cfargument name="Data" type="query" required="true" hint="Menu data query."/> --->
  <cfargument name="ParentID" type="numeric" required="false" default="0" hint="The ID of the parent who's children we want to output."/>
	<!--- Define the local scope. --->
    <cfset var LOCAL = StructNew() />
    <CFIF ARGUMENTS.PARENTID eq 0>
		<CFSET variables.menustring = "">
	</CFIF>
    <!--- Query for the children of the given parent. --->
    <cfquery name="getChildren">
   	SELECT 
	 intNavItemID, intNavID, intNavParentID, NavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive
   <!---  FROM --->
  <!---   ARGUMENTS.Data --->
FROM  vGetNavigation 
    WHERE
    intNavParentID = <cfqueryparam value="#ARGUMENTS.ParentID#" cfsqltype="cf_sql_integer" /> and intNavID=3 
    ORDER BY
    intOrderBy ASC
    </cfquery>
	<cfreturn getChildren>
</cffunction> --->



<cffunction name="GetWhichLevelSelected" access="remote" returntype="string">
	<cfargument name="Data" type="query" required="true" hint="Menu data query."/>
	<cfargument name="ParentID" type="numeric" required="false" default="0" hint="The ID of the parent who's children we want to output."/>
	<cfargument name="NavItemID" type="numeric">
	 <cfset var LOCAL = StructNew() />
	
    <!--- Query for the children of the given parent. --->
    <cfquery name="LOCAL.Parent" dbtype="query" debug="false" >
   	SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive
    FROM
    ARGUMENTS.Data
    WHERE
    intNavItemID=#ARGUMENTS.NavItemID#
    ORDER BY
    intOrderBy ASC
    </cfquery>
	
	 <CFSET variables.ElementLevel=variables.ElementLevel  & LOCAL.Parent.intNavItemID & '_' & LOCAL.Parent.intNavParentID & ','>
	 <CFIF LOCAL.Parent.intNavParentID neq 0>
		  
		  <cfset GetWhichLevelSelected(Data = ARGUMENTS.Data,NavItemID = LOCAL.Parent.intNavParentID) />
     </CFIF>
	<CFRETURN variables.ElementLevel>
</cffunction>

<cffunction name="GetDropDownSelectBYParentID" access="remote" returntype="query">
	<cfargument name="ParentID" type="numeric">
	<cfargument name="NavID" type="numeric" default="3">
	<CFQUERY name="getselection" debug="false" >
		SELECT '-1' as intNavItemID,'' as intNavID, '-1' as intNavParentID, 'None ...' as strNavItemNm, '' as intOrderBy, '' as strNavItemURL, '' as strNavItemTarget, '' as stNavItemClass, '' as strDoEvent, '' as isActive
		UNION
		SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive
		FROM  vGetNavigation WHERE intNavID=#arguments.NavID# and intNavParentID=#arguments.ParentID#
	</CFQUERY>
	

	<cfreturn getselection>
</cffunction>

<cffunction name="GetDropDownSelectBYItemNavID" access="remote" returntype="query">
	<cfargument name="ItemNavID" type="numeric">
	<cfargument name="NavID" type="numeric" default="3">
	
	<CFQUERY name="getselection" debug="false" >
		SELECT '-1' as intNavItemID,'' as intNavID, '-1' as intNavParentID, 'None ...' as strNavItemNm, '' as intOrderBy, '' as strNavItemURL, '' as strNavItemTarget, '' as stNavItemClass, '' as strDoEvent, '' as isActive
		UNION
		SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive
		FROM  vGetNavigation WHERE intNavID=#arguments.NavID# and intNavParentID=#arguments.ItemNavID#
	</CFQUERY>
	

	<cfreturn getselection>
</cffunction>
<cffunction name="getNavigationbyItemNavID" access="remote" returntype="query">
	<cfargument name="ItemNavID" type="numeric">
	<CFQUERY name="getselection" debug="false" >
		SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive,strInMemberTypes
		FROM  vGetNavigation WHERE intNavItemID=#arguments.ItemNavID#
	</CFQUERY>
	<cfreturn getselection>
</cffunction>
<cffunction name="getSecurityMemberTypeList" access="remote" returntype="query">

		<CFQUERY name="GETMEMBERTYPELIST" debug="false" >
			select intMemberTypeID, strMemberType from vGetMemberType
		</CFQUERY>
	<cfreturn GETMEMBERTYPELIST>
</cffunction>
<cffunction name="GetNavigationOutput" returntype="string">
	 <cfargument name="intNavID" type="numeric" required="true"/>
	 <cfargument name="FirstULClass" type="string" required="false" default="">
	 <CFQUERY name="GetTopNav" debug="false" >
		SELECT intNavItemID, intNavID, intNavParentID, strNavItemNm, intOrderBy, strNavItemURL, strNavItemTarget, stNavItemClass, strDoEvent, isActive
		FROM  vGetNavigation WHERE intNavID=#arguments.intNavID# and isActive=1 and (PATINDEX('%#session.memberTypeID#%',strInMemberTypes)>0 or strInMemberTypes is null)
	</CFQUERY>
	<CFINVOKE component="cfc.Navigation" method="OutputMenu" returnVariable="OutputMenu_results">
		<cfinvokeargument name="Data" value="#GetTopNav#">
		<cfinvokeargument name="ParentID" value="0">
		<CFIF arguments.FirstULClass gt ''>
		<cfinvokeargument name="FirstULClass" value="#arguments.FirstULClass#">
		</CFIF>
	</CFINVOKE>
	<cfreturn OutputMenu_results>
</cffunction>
</cfcomponent>