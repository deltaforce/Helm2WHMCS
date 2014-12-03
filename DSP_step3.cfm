
<cfparam name ="session.helm.filter.accountstatus" default="0,1">
<cfparam name = "session.helm.filter.resellerID" default="">
<cfparam name = "session.selectedUsers" default= "">
<cfparam name ="form.userID" default="">
<cfif StructKeyExists(URL,"resellerid")>
	<cfset session.helm.filter.resellerID = URL.resellerID>
</cfif>
<cfif structkeyExists(form,"accountstatus")>
	<cfset session.helm.filter.accountstatus = form.accountstatus>
</cfif>
<cfif StructKeyExists(form,"saveusers")>
	<cfset session.selectedUsers = listremoveduplicates(form.users)>
   <cfset alert.text = "Users saved successfully">
   <cfset alert.type = "success">
</cfif>
<cfif structKeyExists(form,"clearUsers")>
	<cfset session.selectedUsers = "">
    <cfset alert.text = "Users list reset to 0">
   <cfset alert.type = "success">
</cfif>


<form method="post">
<h2>Step 3 -  Choose users to migrate</h2>
<div class="alert alert-info">
click on a reseller to display that resellers users.<br>
click the button to SELECT or REMOVE a user/reseller, your selection will be remembered between pages.<br />
<br />
</div>


<cfquery name="getUsers" datasource="helm">
<cfoutput>
select accountnumber,accounttype,accountstatus,firstname,lastname,companyname
from account
where accountstatus in (#session.helm.filter.accountstatus#)
<cfif StructKeyExists(form,"searchStr") AND form.searchStr neq "">
    and (	accountNumber LIKE ('%#form.searchstr#%') OR
            companyname LIKE ('%#form.searchstr#%') OR
            firstname + ' ' + lastname LIKE ('%#form.searchstr#%')
         )
<cfelse>
	<cfif StructKeyExists(form,"viewUsers")>
    AND accountNumber in (#ListQualify(session.selectedUsers,"'")#)
    
    <cfelse>
        <cfif session.helm.filter.resellerID is "">
        and accounttype =1    
        <cfelse>
        and reselleraccountnumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.helm.filter.resellerID#">
        </cfif> 
    </cfif>
</cfif>
</cfoutput>
</cfquery>

<cfif structKeyExists(variables,"alert")>
	<cfoutput><div class="alert alert-#alert.type#">#alert.text#</div></cfoutput>
</cfif>


<div class="span3 well">
<legend>USER Filter</legend>
Show users which are <br />
<cfoutput>
<input name="accountstatus" type="checkbox" value="0" #IIF(ListContains(session.helm.filter.accountstatus,0), "'checked'","")# /> Active<br />
<input name="accountstatus" type="checkbox" value="1" #IIF(ListContains(session.helm.filter.accountstatus,1), "'checked'","")# /> Suspended<br />
<input name="accountstatus" type="checkbox" value="2" #IIF(ListContains(session.helm.filter.accountstatus,2), "'checked'","")# /> Cancelled<br />
</cfoutput>
<br />
<input name="save" type="submit" value="Save Selection" class="btn btn-primary btn-small"/>
<br />
<br />

<cfif session.helm.filter.resellerID neq "">

	<cfoutput>Currently showing users for Reseller ID: #session.helm.filter.resellerID#</cfoutput><br /><br />
    <A  HREF="index.cfm?step=3&resellerid=" class="btn btn-primary btn-small">Show Resellers</A>
<cfelse>
	Currently showing Resellers. Select a reseller to view his users.
</cfif>
</div>
<div class="span3 well">
	<legend>Search</legend>
     Search by UserID, name or company<br />

<input type="text" name="searchStr" /><br />
<input name="search" type="submit" value="Search" class="btn btn-primary btn-small"/>
</div>
<div class="span3 well">
<legend>Results</legend>
<cfoutput>You currently have #ListLen(session.selectedusers)# users selected</cfoutput><br/><br />

<button name="clearUsers" type="submit" class="btn btn-primary btn-small">Reset List</button> 
<button name="viewUsers" type="submit" class="btn btn-primary btn-small">View List</button> 
</div>

<table  class="table table-striped">

	<thead class="fixedHeader">
    	<cfoutput>
    	<tr>
        	<th colspan="5" class="label">Records: #getUsers.recordcount#</th>
        </tr>
        </cfoutput>
    	<tr>
        	<th><input type="button" id="selectAll" name="selectAll" value="Toggle All" class="btn"></th><th>UserID</th><th>Account Type</th><th>Status</th><th>Comapny Name</th><th>Client Name</th>
        </tr>
    </thead>
    <tbody  class="scrollContent">
    	<cfoutput query="getUsers">
    	<tr>
        	<td><button  data-toggle="buttons-checkbox" type="button"  class="btn userID #IIF(ListFind(session.selectedUsers, accountnumber), "'active'","''")#" id="userID" value="#accountnumber#">#IIF(ListFind(session.selectedUsers, accountnumber), "'REMOVE'","'SELECT'")#</button></td>
            <td><a href="index.cfm?step=3&resellerid=#accountnumber#">#accountnumber#</a></td><td><cfif accounttype is 0>ADMIN<cfelseif accounttype is 1>Reseller<cfelseif accounttype is 2>USER</cfif></td>
            <td><cfif accountstatus is 0>ACTIVE<cfelseif accountstatus is 1>SUSPENDED<cfelseif accountstatus is 2>CANCELLED</cfif></td>
            <td>#companyname#</td>
            <td>#firstname# #lastname#</td>
        </tr>
        </cfoutput>
    </tbody>
    <tfoot>
    	<tr>
        	<td colspan="5"><input name="saveusers" type="submit" value="Save Selection" class="btn btn-primary"/>
            
            </td>
        </tr>
    </tfoot>
</table>
<cfoutput>
<input type="hidden" name="users" id="users" size="40" value="#session.selectedUsers#"/>
</cfoutput>
<a href="index.cfm?step=2" class="btn btn-primary">&laquo; Back</a> <a href="index.cfm?step=4" class="btn btn-primary">Next &raquo;</a>
</form>

<script>
$(document).ready(function() {
	//toogle all buttons
    $('#selectAll').click(function() {
        $('.btn.userID').each(function() {
            $(this).button('toggle');
			if ($(this).hasClass('active'))
				{
				$(this).text('REMOVE');//button is active, so set text to REMOVE 
				$(this).text('SELECT');//button is NOT active, so set text to SELECT
				getUsers = $('#users').val().split();//convert list to array
				getUsers.push($(this).val()); //add button value to array
				$('#users').val(getUsers.join()); //convert array back to list
				}
			else
				{
				var y = $('#users').val().split(',');
				var remove = $(this).val();
				y.splice( $.inArray(remove,y) ,1 ); //remove item from list
				$('#users').val(y.join());
				}
        });
    });
	// add/remove userID's to the hidden form field when buttons clicked
	$('.btn.userID').click(function() {
		// we have to test the OPPOSITE of the active state because the button hasn't been toggled yet until AFTER this code runs.
		// so when we are testing if it is ACTIVE, this is really going to be INACTIVE becaus eit will be changed after this runs.
		if ($(this).hasClass('active'))
			{
				$(this).text('SELECT');
				var y = $('#users').val().split(',');
				var remove = $(this).val();
				y.splice( $.inArray(remove,y) ,1 ); //remove item from list
				
				$('#users').val(y.join());
			}
		else
			{
				$(this).text('REMOVE');
				getUsers = $('#users').val().split();//convert list to array
				getUsers.push($(this).val()); //add button value to array
				$('#users').val(getUsers.join()); //convert array back to list
			}
		
	});
});
</script>
