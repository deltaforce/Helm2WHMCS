<cftry>
<cfparam name="continue" default=true>	
<cfadmin action="getDatasources" type="web" password="#application.Lucee.webAdmin#" returnVariable="dataSources">
<cfcatch>
	<div class="alert alert-error">
		<cfoutput>
		<strong>Unable to access your Railo Web Admin API</strong>
		<p>Message: #cfcatch.message#</p>
		<p>Make sure you have enabled the API and set a password on your web admin<p>
		</cfoutput>
	</div>
</cfcatch>
<cfquery name="findwhmcs" dbtype="query">
select * from datasources
where name = 'whmcs'
</cfquery>
<cfquery name="findhelm" dbtype="query">
select * from datasources
where name = 'helm'
</cfquery>
<h2>Step 1 - Setup Data Sources</h2>
<p>You first need to setup 2 data sources, this should be done in your Railo Admin.</p>
<!--- This outputs the API passwords just to verify the hash is correct, only used for debugigng --->
<!---
<p><cfoutput>whmcs api  password: #application.whmcs.api.password#<br />
Hashed: #hash(application.whmcs.api.password,'MD5')#</cfoutput>
--->
<h4>Datasource Name = WHMCS</h4>

<cfif findwhmcs.recordcount GT 0>
	<div class="alert alert-info">Datasource found</div>
<cfelse>
	<div class="alert alert-error"><strong>Datasource NOT found</strong><br />
You need to setup the WHMCS DSN in your Lucee Admin.</div>
	<cfset continue = false>
</cfif>


</p>
<h4>Datasource Name = HELM</h4>
<p>You will need to put the username/password into the DSN and it will need to verify.<br />
<cfif findhelm.recordcount GT 0>
	<div class="alert alert-info">Datasource found</div>
<cfelse>
	<div class="alert alert-error"><strong>Datasource NOT found</strong><br />
You need to setup the HELM DSN in your Lucee Admin.</div>
<cfset continue = false>
</cfif>
</p>
<cfif continue is true>

 <p><a href="index.cfm?step=2" class="btn btn-primary">Next &raquo;</a></p>	
</cfif>

</cftry>