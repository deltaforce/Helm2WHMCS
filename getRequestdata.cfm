<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>

<body>
<cfsavecontent variable="getrequest">
<html>
<head></head>
<body>
<cfoutput>#dump(getHttpRequestData())#</cfoutput>
</body>
</html>
</cfsavecontent>
<cffile action="write" file="#expandpath('./')#requestdata.html" nameconflict="overwrite" output="#getrequest#">
</body>
</html>