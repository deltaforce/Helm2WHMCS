
<!--- save the mapped hosting plans to json file when form saved --->
<cfif StructKeyExists (form,"savefields")>
	<cfset StructDelete(form,"fieldnames")>
                <cfset StructDelete(form,"savefields")>
                <cffile action="write" file="#expandPath('./')#\hostingPlans.json" nameconflict="overwrite" output="#serializeJson(form)#">
                <div class="alert alert-success"><h4>Success</h4>
                    <p>The hosting plan mappings have been saved, you can proceed to next step.</p>
                    
                </div>
</cfif>
<!--- /end save --->

<cfquery name="helmPackages" datasource="helm">
    SELECT PackageTypeID,PackageTypeName AS HelmPlan
    FROM PackageType
    WHERE resellerAccountNumber in ('','HOUSERESELLER')
</cfquery>
<cfquery name="WHMCSplans" datasource="whmcs">
	select id,name AS WHMCSplan
	from tblproducts
	where type = 'hostingaccount'
</cfquery>
 <!--- load in any exisitng hostingPlans  mappings  --->
        	<cffile action="read" file="#expandPath('./')#\hostingPlans.json" variable="json">
            <cfset hostingPlansMap = deserializeJson(json)>
<h2>Step 4 -  Map HELM Hosting Plans to WHMCS Hosting Plans</h2>
<form method="post" action="index.cfm?step=4">
<table class="table">
	<thead class="thead-inverse">
	<tr>
		<th>Helm Package</th><th></th><th>WHMCS Hosting Plan</th>
	<tr>
	</thead>
	<tbody>
	<cfoutput>
	<cfloop query="helmpackages">
	<tr>
		<td>#helmPlan#</td>
		<td> ==> </td>
		<td><select name="#helmplan#">
				<option value="NONE">NONE (This plan will be ignored)</option>option>
				
				<cfloop query="WHMCSplans">
					<cfif structKeyExists(hostingPlansMap, helmplan) && hostingPlansMap[helmplan] is whmcsplan>
					<cfset selected = "selected">
					<cfelse>
						<cfset selected = "">
					</cfif>
					<option value="#whmcsplan#" #selected#>#whmcsplan#</option>
				</cfloop>
			</select>
		</td>
		
	</tr>
	</cfloop>
	</cfoutput>
	</tbody>
	</table>
	<p><input name="savefields" type="submit" value="Save" class="btn btn-primary"/></p>

</form>
<a href="index.cfm?step=3" class="btn btn-primary">&laquo; Back</a> <a href="index.cfm?step=5" class="btn btn-primary">Next &raquo;</a>