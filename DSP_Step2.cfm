<p>
   	 		
           
            
            <h2>Step 2 -  Map HELM columns to WHMCS columns</h2>
            <div class="alert alert-info">
              <p><strong>Note:</strong> this also includes your WHMCS custom client fields, so if you do not have a field in WHMCS to hold data from HELM and you want to keep that data, then you will need to create a custom client field.<br />
                If you set the destination column to &quot;NONE&quot; then the data will not be migrated.
              </p>
            </div>
            <cfif StructKeyExists(form,"savefields")><!--- re-save the mapped  fields --->
				<cfset StructDelete(form,"fieldnames")>
                <cfset StructDelete(form,"savefields")>
                <cffile action="write" file="#expandPath('./')#\fields.json" nameconflict="overwrite" output="#serializeJson(form)#">
                <div class="alert alert-success"><h4>Success</h4>
                    <p>The data mappings have been saved</p>
                    
                </div>
        	</cfif>
            <!--- load in the fields list, this is the default HELM->WHMCS match list --->
        	<cffile action="read" file="#expandPath('./')#\fields.json" variable="json">
            <cfset mappings = deserializeJson(json)>
            <!--- list of all HELM client fields (this wont change so can be hard coded) --->
            <cfset helmfields = "AccountNumber,AccountType,AccountStatus,ResellerAccountNumber,Title,FirstName,LastName,CompanyName,AccountPassword,PrimaryEmail,SecondaryEmail,Address1,Address2,Address3,Town,County,CountryCode,PostCode,HomePhone,WorkPhone,MobilePhone,FaxNumber,LastModified,SignUpIP,SignUpDate">
            <cftry>
            <!--- Get the list of fieldnames from WHMCS database in case it has changed since this was written --->
            <cfquery datasource="whmcs" name="whmcsfields">
            select *
            from tblclients
            limit 0,1
            </cfquery>
            <!--- get custom client fields from whmcs --->
            <cfquery datasource="whmcs" name="customfields">
            select id,fieldname
            from tblcustomfields
            where type = 'client'
            </cfquery>
            
            <!--- put all the WHMCS fields into a struct identifying which are custom --->
            
            <cfloop list ="#whmcsfields.columnlist#" item="field">
            	<cfset application.whmcs.Fields[field] = Struct("isCustomField": "false")>
            </cfloop>
            <cfloop query="customfields">
            	<cfset application.whmcs.Fields[fieldname] = Struct("isCustomField": "true", "ID": ID)>
            </cfloop>
            <form method="post" action="index.cfm?step=2" >
            <table>
            	<tr><th>Helm Field</th><th>WHMCS field</th></tr>
            	<cfloop list="#helmfields#" item="helmField">
                	<cfoutput>
                    	<tr>
                        	<td>#helmField#</td>
                    		<td><select name="#helmField#"><option value="">NONE</option>
                            	<cfloop list="#ListSort(StructKeyList(application.whmcs.Fields),"text")#" item="whmcsField">
                                	<option value="#whmcsField#" #IIF(mappings[helmField] is whmcsField, DE('selected'),'')#>#whmcsField#</option>
                                </cfloop>
                                </select>
                            </td>
                       	</tr>
					</cfoutput>
                </cfloop>
            </table>
            <input name="savefields" type="submit" value="Save" class="btn btn-primary"/>
            </form>
 			<cfcatch type="database">
            	<div class="alert alert-error"><h4>Database Error</h4>
                <p>"<cfoutput>#cfcatch.Message#</cfoutput>"</p>
                <p>please check that your data sources are setup correctly.</p>
                
                </div>
            </cfcatch>
            </cftry>
            <a href="index.cfm?step=1" class="btn btn-primary">&laquo; Back</a> <a href="index.cfm?step=3" class="btn btn-primary">Next &raquo;</a>
        
    </p>