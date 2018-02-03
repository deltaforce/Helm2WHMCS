<cfsetting requesttimeout="50000">
<link href="/css/bootstrap-wysihtml5-0.0.2.css" rel="stylesheet" type="text/css" />
<script src="/js/wysihtml5-0.3.0_rc2.min.js"></script>
<script src="/js/bootstrap-wysihtml5-0.0.2.min.js" type="application/javascript"> </script>
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="form.emailSubject" default="">
<cfparam name="form.emailFrom" default="">
<cfparam name="form.emailFailTo" default="">
<cfinclude template="passPhraseGen.cfm">
<cftry>
<cfif NOT structKeyExists(session,"selectedUsers") OR (structKeyExists(session,"selectedUsers") and session.selectedUsers is "")>
	
    <cfthrow detail="You do not have any users selected to migrate or your session has expired.<br />Please go back and select some users." type="custom" message="An Error occured">
</cfif>
<cfif StructKeyExists(form,"migrate")>
	<!--- Do migration --->
	<cfquery name="getUsers" datasource="helm">
    SELECT * from account
    WHERE accountNumber in (#ListQualify(session.selectedUsers,"'")#)
	</cfquery>
    <cfif StructKeyExists(form,"saveEmail")>
    	<cffile action="write" file="#expandPath('./')#customEmailTemplate.cfm" nameconflict="overwrite" output="#form.emailMessage#">
    </cfif>
    
    <!--- load in the fields list, this is the default HELM->WHMCS match list --->
    <cffile action="read" file="#expandPath('./')#\fields.json" variable="json">
    <cfset mappings = deserializeJson(json)>
    <cfset api.result = ArrayNew(1)>
    <cfset api.request = StructNew()>
    <cfset result = ArrayNew(1)>
    <cfoutput query="getUsers">
    	<cfset password = PassphraseGen(words="3",separator=" ")>
        <cfhttp url="#application.whmcs.api.url#" method="post" charset="utf-8">
            <cfhttpparam name="action" value="addclient" type="formfield">
            <cfhttpparam type="formfield" name="responsetype" value="json">
            <cfhttpparam name="username" value="#application.whmcs.api.username#" type="formfield">
            <cfhttpparam name="password" value="#lcase(hash(application.whmcs.api.password,'MD5'))#" type="formfield">
            <cfhttpparam name="password2" value="#password#" type="formfield">
                <!--- <cfdump var="#application#"><cfdump var="#mappings#" label="mappings">--->
                <cfloop collection="#mappings#" item="field">
                    <!--- generate all the fields to submit to the API --->
                    <cfif mappings[field] neq "">
                        <cfif application.whmcs.Fields[mappings[field]].isCustomField>
                            <cfhttpparam name="customfield[#application.whmcs.fields[mappings[field]].id#]" value="#getUsers[field]#" type="formfield">
                            <cfset api.request[#field#] = "customfield[#application.whmcs.fields[mappings[field]].id#]) = #getUsers[field]#">
                        <cfelse>
                            <cfhttpparam name="#lcase(mappings[field])#" value="#getUsers[field]#" type="formfield">
                            <cfset api.request[mappings[field]] = "#getUsers[field]#">
                        </cfif>
                        
                    </cfif>
                </cfloop>
                <!--- the required fields from the form --->
                <cfif form.skipvalidation is true>
                <cfhttpparam name="skipvalidation" value="true" type="formfield">
                </cfif>
                <cfhttpparam type="formfield" name="customfield[21]" value="#form.enableSMS#">
                <cfif form.sendWelcomeEmail is false>
                <cfhttpparam type="formfield" name="noemail" value="true">
                </cfif>
                <cfif form.groupId NEQ 0>
                <cfhttpparam type="formfield" name="groupid" value="#form.groupID#">
                </cfif>
            
            </cfhttp>
            
            <cfif isJSON(cfhttp.filecontent)>
				<cfset response = deserializeJson(cfhttp.filecontent)>
				<cfif response.result is "error"><!--- there was an error from whmcs --->
                    <cfset ArrayAppend(result,Struct('error':'WHMCS API error','message':response.message,'Client': Struct('firstname':api.request.firstname,'lastname':api.request.lastname,'Company Name': api.request.companyname,'Email':api.request.email, 'clientID': '', 'HelmUserID': accountNumber)))>
                <cfelse><!--- whmcs success --->
                    <cfset ArrayAppend(result,Struct('success':'','Client': Struct('firstname':api.request.firstname,'lastname':api.request.lastname,'Company Name': api.request.companyname,'Email':api.request.email, 'clientID': response.clientid, 'HelmUserID': accountNumber)))>
                	<cfif StructKeyExists(form,"customEmail")>
                    	<cfset  emailContent = ReplaceNoCase(form.emailmessage,"$client_name","#api.request.firstname# #api.request.lastname#","ALL")>
                        <cfset  emailContent = ReplaceNoCase(emailContent,"$company_name","#api.request.companyname#","ALL")>
                        <cfset  emailContent = ReplaceNoCase(emailContent,"$email","#api.request.email#","ALL")>
                        <cfset  emailContent = ReplaceNoCase(emailContent,"$password","#password#","ALL")>
                        <cfmail to="#api.request.email#" failto="#form.emailFailTo#" subject="#form.emailSubject#" from="#form.emailFrom#" charset="utf-8" type="html">
                        #emailcontent#
                        </cfmail>
                       
                    </cfif>
                </cfif>
            <cfelse><!--- response from whmcs was not JSON, so something is worng --->
            	<cfset ArrayAppend(result,Struct('error':'Could not deserialize response from WHMCS, therefore is was a valid JSON response','message':cfhttp.filecontent,'Client': Struct('firstname':api.request.firstname,'lastname':api.request.lastname,'Company Name': api.request.companyname,'Email':api.request.email, 'clientID': '', 'HelmUserID': accountNumber)))>
            </cfif>            
            <cfdump var="#cfhttp.filecontent#">
            
        </cfoutput>
        <cfset ArrayAppend(api.result,cfhttp.FileContent)>
        
        <cfsavecontent variable="resultTable">
        <table class="table table-condensed">
        <thead class="fixedHeader">
        	<tr>
                <th>Client name</th>
                <th>Company Name</th>
                <th>Email</th>
                <th>Helm UserID</th>
                <th>WHMCS ClientID</th>
                <th>Status</th>
                <th>Error Details</th>
            </tr>
        </thead>
        <tbody class="scrollContent"> 
		<cfloop from="1" to="#arraylen(result)#" index="x">
        
         
        <cfoutput>
        	<cfif structkeyExists(result[x],"error")>  
                <tr class="danger">
                    <td>#result[x].client.firstname# #result[x].client.lastname#</td>
                    <td>#result[x].client['company name']#</td>
                    <td>#result[x].client.email#</td>
                    <td>#result[x].client.HelmUserID#</td>
                    <td>#result[x].client.clientID#</td>
                    <td>#result[x].error#</td>
                    <td>#result[x].message#</td>
                </tr>
            <cfelse>
                <tr class="success">
                    <td>#result[x].client.firstname# #result[x].client.lastname#</td>
                    <td>#result[x].client['company name']#</td>
                    <td>#result[x].client.email#</td>
                    <td>#result[x].client.HelmUserID#</td>
                    <td>#result[x].client.clientID#</td>
                    <td>SUCCESS</td>
                    <td>&nbsp;</td>
                </tr>
            </cfif>
        
        </cfoutput>
        
        </cfloop>
        </tbody>
        </table>
        </cfsavecontent>
        <!--- save results as a spreadsheet --->
        <cffile action="write" file="#expandpath('./')#results.html" output="#resultTable#" nameconflict="overwrite" >
        <div class="well">
        <legend>Result - any errors will be shown below in RED</legend>
        <a href="results_excel.cfm" class="btn btn-primary" target="_blank"><i class="icon-list-alt icon-white"></i> Download Spreadsheet </a>
        <cfoutput>#resultTable#</cfoutput>
        </div>
       
        
</cfif>


<cfquery name="groups" datasource="whmcs">
select id,groupname from tblclientGroups
</cfquery>

<form method="post" action="index.cfm?step=5"  class="form-horizontal">
<h2>Step 4 -  Begin Migration</h2>
<div class="alert alert-info">
It is recommended you migrate a couple of test users first to make sure everything is working as expected.
</div>
<div class="well">
    <p><legend>Import options</legend></p>
    <cfoutput><p>Users to migrate : <span class="badge">#ListLen(session.selectedUsers)#</span></p></cfoutput>
    <div class="control-group">
            <label class="control-label">Send Welcome Email</label>
            <div class="controls">
              <input type="radio" name="sendWelcomeEmail" value="true" id="sendWelcomeEmail_0" />
              Yes
              <input type="radio" name="sendWelcomeEmail" value="false" id="sendWelcomeEmail_1" checked/>
              No
              <span class="help-block">Do you want to send the new WHMCS client welcome email to each user.</span>
            </div>
    </div>
    <div class="control-group">
            <label class="control-label">Enable SMS Messages</label>
        <div class="controls">
              <input type="radio" name="enableSMS" value="yes" id="enablesms_0" checked/>
              Yes
              <input type="radio" name="enableSMS" value="no" id="enablesms_1" />
          No
          <span class="help-block">Do you want  the client to receive SMS messages. (note this will also send the initial welcome text)</span>
          </div>
    </div>
    <div class="control-group">	
             <label class="control-label">Skip validation</label>
             <div class="controls">
               <input type="radio" name="skipValidation" value="true" id="skipValidation_0" />
               yes
               <input type="radio" name="skipValidation" value="false" id="skipValidation_1" checked/>
               no
               <span class="help-block">Do you want skip the field validation on required client fields.</span>
            </div>
    </div>
    <div class="control-group">	
    
            <label class="control-label">Client Group</label>
            <div class="controls">
                <select name="groupID">
                        <option value="0">NONE</option>
                    <cfoutput query="groups">
                        <option value="#id#">#groupname#</option>
                    </cfoutput>
                </select>
                <span class="help-block">Specify which client group you want to insert these clients into.</span>
            </div>
    </div>
    <div class="control-group">	
        <label class="control-label">Send custom email</label>
        <div class="controls">
            <input type="checkbox" name="customEmail" value="true" id="customEmail" /> 
        </div>
        <cfoutput>
        <div  id="customEmailDiv" style="display:none">	
            <legend>Custom Email</legend>
             <div class="well well-small">In case you want to send a custom email to migrated users and not the WHMCS welcome email, you can define the email below.<br />
			 You will need to make sure that you have setup the SMTP server to be used in the Railo admin. </div>
             <label class="control-label">Subject</label>
             <div class="controls">
             <input type="text" name="emailSubject" size="30" value="#form.emailSubject#"/>
             </div>
            
            <label class="control-label" for="emailFrom">From Address</label> 
            <div class="controls">
                <input type="text" name="emailFrom" size="30" value="#form.emailFrom#"/>
            </div>
            
            <label class="control-label" for="emailFailTo">Fail To Address</label> 
            <div class="controls">
                <input type="text" name="emailFailTo" size="30" value="#form.emailFailTo#"/>
            </div>
            
            <label class="control-label" for="emailMessage">Message
            </label> 
            <div class="controls">
            	
              <textarea  name="emailMessage" id="emailMessage" style="width:450px;height:200px"><cfinclude template="customEmailTemplate.cfm"> </textarea>
                
                
                	<label class="checkbox" for="saveEmail">Save for future use</label>
                    <input type="checkbox" name="saveEmail" value="true" id="saveEmail" /> 
                    
                <span class="help-block">
                Dynamic fields:<br />
                $client_name<br />
				$company_name<br />
				$email<br />
				$password<br />

				</span>
                
            </div>
            </cfoutput>
        </div>
    </div>
    
</div>

<cfcatch type="custom">
	<cfoutput>
    <div class="alert alert-error">
    <strong>#cfcatch.message#</strong><br />
	#cfcatch.Detail#
    </div>
    </cfoutput>
</cfcatch>
</cftry>
<div class="control-group">	
	<a href="index.cfm?step=3" class="btn btn-primary">&laquo; Back</a>
	<button class="btn btn-primary" type="submit" name="migrate">Migrate</button>
</div>
</form>


<script>
$("#customEmail").click(function() {
    $('#customEmailDiv').toggle();
});
$('#emailMessage').wysihtml5({
    "html": true
});
</script>
</cfprocessingdirective>