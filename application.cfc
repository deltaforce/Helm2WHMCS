<cfcomponent > 
<cfset This.name = "Helm2WHMCS"> 
<cfset This.clientmanagement="false"> 
<cfset This.loginstorage="Session"> 
<cfset This.sessionmanagement="True"> 
<cfset This.sessiontimeout="#createtimespan(0,0,30,0)#"> 
<cfset This.applicationtimeout="#createtimespan(5,0,0,0)#">

<cfif cgi.HTTP_HOST is "migration.ihostllc.net"><!--- specify the live domain name that you will be using for this app here --->
	<cfset request.environment = "live">
<cfelse>
	<cfset request.environment = "dev"> <!--- if the URL does not contain LIVE host name abobe, then dev settings will be used instead --->
</cfif>
<cffunction name="onRequestStart">
<cfif StructKeyExists(url,"reload")>
	<cfset ApplicationStop()>
    <cfset onapplicationstart()>
</cfif>
</cffunction>
<cffunction name="onApplicationStart" >
	<cfif request.environment == "live">
    	<!--- LIVE site settings --->
        
    	<cfset application.Lucee.webAdmin = ""><!--- your Lucee web admin password --->
        <!--- your WHMCS API URL, make sure you have enabled the API and allowed this server to access it --->
        <cfset application.whmcs.api.url = "http://path to your whmcs/includes/api.php">
        <!--- API username and password --->
        <cfset application.whmcs.api.username = ""> <!--- whmcs uer with api access --->
        <cfset application.whmcs.api.password = ""> <!--- password for whmcs user --->
    <cfelse>
    	<!--- DEV site settings / if you have a dev/testing setup, then you can set these vars accordingly --->
    	<cfset application.Lucee.webAdmin = ""><!--- your Lucee web admin password --->
        <cfset application.whmcs.api.url = "http://path to whmcs/includes/api.php">
        <cfset application.whmcs.api.username = ""> <!--- whmcs uer with api access --->
        <cfset application.whmcs.api.password = ""><!--- password for whmcs user --->
    </cfif>
</cffunction>
</cfcomponent>