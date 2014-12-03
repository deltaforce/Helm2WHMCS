<cfheader name="Content-Disposition" value="inline; filename=results.xls">
<cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"> 
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel">
<style>
.success{background-color: #BFFFBF;}
.error {background-color:#FFB3B3;}
</style>
</head>
<body>
<cfinclude template="results.html">
</body>
</html>
