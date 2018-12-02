<%
Option Explicit
%>
<!--#include file="CValidator.asp" -->
<LINK rel="stylesheet" href="CValidator.css" type="text/css"></LINK>
<%
Dim RuleFilename
RuleFilename = "d:\Websites\www.goodnews.com\Validation\Rules.xml"

Dim Validator
Set Validator = new CValidator
Call Validator.CheckValues(RuleFilename, Request.QueryString)

If Not Validator.IsValid Then
	Response.Write Validator.GetErrorReport()
End If

Function CheckAge(curr, Col)
	Response.Write "Age: " & Col(curr)
	CheckAge = True
End Function
%>