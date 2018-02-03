<cfprocessingdirective pageencoding="utf-8">
<cfset setEncoding("form","utf-8")>
<cfparam name="url.step" default="0">

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HELM Client Import</title>

 <!-- Le styles -->
    
    <link href="css/main.css" rel="stylesheet" type="text/css">
    <link href="css/scrollTables.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>

<body>


    <div class="container">
      <div class="row">
      	
        <div class="col-md-3">
        	
          <div class="well sidebar-nav">
            <ol class="nav nav-list" type="1">
            <cfoutput>
              <li class="nav-header">Migration Steps</li>
              <li class="#IIF(url.step eq 0, DE('active'),DE(''))#"><a href="index.cfm">Setup Config</a></li>
              <li class="#IIF(url.step eq 1, DE('active'),DE(''))#"><a href="index.cfm?step=1">Setup Data Sources</a></li>
              <li class="#IIF(url.step eq 2, DE('active'),DE(''))#"><a href="index.cfm?step=2">Map Fields</a></li>
              <li class="#IIF(url.step eq 3, DE('active'),DE(''))#"><a href="index.cfm?step=3">Choose users to migrate</a></li>
              <li class="#IIF(url.step eq 4, DE('active'),DE(''))#"><a href="index.cfm?step=4">Map Hosting Plans</a></li>
              <li class="#IIF(url.step eq 5, DE('active'),DE(''))#"><a href="index.cfm?step=5">Begin Migration</a></li>
              
            </cfoutput>  
            </ol>
          </div><!--/.well -->
        </div><!--/span-->
        <div class="col-md-9">
          <div class="jumbotron">
            <h1>HELM to WHMCS Client Migration</h1>
            <p>use this tool to migrate client data from HELM to WHMCS, you can map all the clients fields and also use custom client fields in WHMCS.</p>
            <p>Written by <a href="http://michaels.me.uk/">Russ Michaels</a></p>
            <p>Environment = <cfoutput>#request.environment#</cfoutput>
          </div>
          <div class="row">
            <cfswitch expression="#url.step#">
            	<cfcase value="1">
                	<cfinclude template="DSP_Step1.cfm">
                 </cfcase>
                <cfcase value="2">
                    <cfinclude template="DSP_Step2.cfm">
                </cfcase>
                <cfcase value="3">
                    <cfinclude template="dsp_step3.cfm">
                </cfcase>
                <cfcase value="4">
                    <cfinclude template="dsp_step4.cfm">
                </cfcase>
                <cfcase value="5">
                    <cfinclude template="dsp_step5.cfm">
                </cfcase>
                <cfdefaultcase>
                  <cfinclude template="DSP_default.cfm">
                </cfdefaultcase>
            </cfswitch>
          </div><!--/row-->
          
        </div><!--/span-->
      </div><!--/row-->
                    

 
   </div><!--/.fluid-container-->
</body>
</html>