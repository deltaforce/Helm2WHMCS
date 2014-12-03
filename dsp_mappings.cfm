<p>
   	 		<!--- load in the fields list, this is the default HELM->WHMCS match list --->
        	<cffile action="read" file="#expandPath('./')#\fields.json" variable="json">
            <cfset mappings = deserializeJson(json)>
            <!--- list of all HELM client fields (this wont change so can be hard coded) --->
            <cfset helmfields = "AccountNumber,AccountType,AccountStatus,ResellerAccountNumber,Title,FirstName,LastName,CompanyName,AccountPassword,PrimaryEmail,SecondaryEmail,Address1,Address2,Address3,Town,County,CountryCode,PostCode,HomePhone,WorkPhone,MobilePhone,FaxNumber,LastModified,SignUpIP,SignUpDate">
            <cftry>
            <!--- Get the list of fieldnames from WHMCS database in case it has changed since this was writtem --->
            <cfquery datasource="whmcs" name="whmcsfields" cachedwithin="#createtimespan(1,0,0,0)#">
            select *
            from tblclients
            limit 0,1
            </cfquery>
            <!--- get custom client fields from whmcs --->
            <cfquery datasource="whmcs" name="customfields" cachedwithin="#createtimespan(1,0,0,0)#">
            select fieldname
            from tblcustomfields
            where type = 'client'
            </cfquery>
            <!--- convert all whmcs fields into a comma dleimted list --->
            <cfset whmcsfieldlist = whmcsfields.columnlist>
            <!--- now append the custom fields --->
            <cfset whmcsfieldlist = ListAppend(whmcsfieldlist,valueList(customfields.fieldname))>
            <!--- now sort them alphanetically --->
            <cfset whmcsfieldlist = ListSort(whmcsfieldlist,"text")>
            <h2> Map HELM columns to WHMCS columns</h2>
            <p>Note: this also includes custom client fields.</p>
            <form method="post" action="index.cfm?step=mappings" >
            <table>
            	<tr><th>Helm Field</th><th>WHMCS field</th></tr>
            	<cfloop list="#helmfields#" item="helmField">
                	<cfoutput><tr><td>#helmField#</td><td><select name="#helmField#"><option value="">NONE</option><cfloop list="#whmcsfieldlist#" item="whmcsField"><option value="#whmcsField#" #IIF(mappings[helmField] is whmcsField, DE('selected'),'')#>#whmcsField#</option></cfloop></select></td></tr></cfoutput>
                </cfloop>
            </table>
            <input name="savefields" type="submit" value="Save" />
            </form>
 			<cfcatch type="database">
            	<div class="alert alert-error"><h4>Database Error</h4>
                <p>"<cfoutput>#cfcatch.Message#</cfoutput>"</p>
                <p>please check that your data sources are setup correctly.</p>
                
                </div>
            </cfcatch>
            </cftry>
        <cfif StructKeyExists(form,"savefields")><!--- re-save the matched fields --->
        	<cfset StructDelete(form,"fieldnames")>
            <cfset StructDelete(form,"savefields")>
        	<cffile action="write" file="#expandPath('./')#\fields.json" nameconflict="overwrite" output="#serializeJson(form)#">
            Fields saved as fields.json
        </cfif>
    </p>