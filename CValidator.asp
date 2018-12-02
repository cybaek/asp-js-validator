<%
' @author	BAEK, CHANG YOL http://cybaek.com/
' @email		cybaek@netsgo.com
' @version	0.1
' @update	2003.12.07
' Copyrights reserved.

Class CValidator
	Dim rules
	Dim ErrorReport
	Dim Valid
	
    Private Sub Class_Initialize()
		Valid = False
    End Sub
    
	Public Function GetErrorReport()
		GetErrorReport = ErrorReport
	End Function
	
	Public Function IsValid()
		IsValid = Valid
	End Function
	
	Public Function CheckValues(Filename, Col)
		Set rules = LoadValidationRules(Filename)
		CheckValues = ApplyValidators(rules, Col)
	End Function

	Function LoadValidationRules(Filename)
		Dim xml 
		Set xml = Server.CreateObject("Microsoft.XMLDOM")
		xml.async = False
		xml.load(Filename)

		Set LoadValidationRules = xml
	End Function

	Function ApplyValidators(rules, Col)
		Dim i, j
		Dim length, length2

		Dim Rule, validator, VarName, xpath
		
		ApplyValidators = True
		Valid = True
		ErrorReport = "<div class=CValidatorContainer>" & vbCrLf
		
		For Each VarName In Col
			xpath = "//Rule[@name=""" & VarName & """]/*"
			Call t(xpath)		
			Set Rule = rules.selectNodes(xpath)
			
			If Not (Rule Is Nothing) Then
				For j = 0 To Rule.length-1
					Set validator = Rule.nextNode
					If Not IsNull(validator) Then
						Call t("NodeName: " & validator.nodeName)
						If Not ApplyValidator(validator, VarName, Col) Then
							Call AddReport(Validator.GetAttribute("ErrorMessage"))
							ApplyValidators = False
							Valid = False
						End If
					End If
				Next
			End If
		Next
		ErrorReport = ErrorReport & "</div>"
	End Function

	Sub AddReport(msg)
		ErrorReport = ErrorReport & "<div class=CValidatorItem><span class=CValidatorText>" & msg & "</span></div>" & vbCrLf
	End Sub
	
	Function ApplyValidator(v, curr, Col)
		If v.nodeName = "RequiredFieldValidator" Then
			ApplyValidator = ProcessRequiredFieldValidator(v, curr, Col)
		ElseIf v.nodeName = "RegularExpressionValidator" Then
			ApplyValidator = ProcessRegularExpressionValidator(v, curr, Col)
		ElseIf v.nodeName = "LengthValidator" Then
			ApplyValidator = processLengthValidator(v, curr, Col)
		ElseIf v.nodeName = "RangeValidator" Then
			ApplyValidator = ProcessRangeValidator(v, curr, Col)
		ElseIf v.nodeName = "CustomValidator" Then
			ApplyValidator = ProcessCustomValidator(v, curr, Col)
		ElseIf v.nodeName = "CompareValidator" Then
			ApplyValidator = ProcessCompareValidator(v, curr, Col)
		Else
			ApplyValidator = True
		End If
	End Function

	Function ProcessCompareValidator(v, curr, Col)
		Dim ValueToCompare, DataType, Value, Operator
		
		ValueToCompare= GetValueToCompare(v, Col)
		DataType = v.GetAttribute("Type")
		value = CastingValue(Col(curr), DataType)
		Operator = v.GetAttribute("Operator")
		
		Select Case Operator
			Case "Equal"
				ProcessCompareValidator = (Value = ValueToCompare)
			Case "NotEqual"
				ProcessCompareValidator = (Value <> ValueToCompare)
			Case "GreaterThan"
				ProcessCompareValidator = (Value > ValueToCompare)
			Case "GreaterThanEqual"
				ProcessCompareValidator = (Value >= ValueToCompare)
			Case "LessThan"
				ProcessCompareValidator = (Value < ValueToCompare)
			Case "LessThanEqual"
				ProcessCompareValidator = (Value <= ValueToCompare)
			Case "DataTypeCheck"
				' @todo
				ProcessCompareValidator = True
		End Select
	End Function

	Function GetValueToCompare(v, Col)
		Dim Value, ControlToCompare
		Value = v.GetAttribute("ValueToCompare")
		ControlToCompare = v.GetAttribute("ControlToCompare")

		If Not IsNull(ControlToCompare) Then
			Value = Col(ControlToCompare)
		End If
		
		GetValueToCompare = CastingValue(Value, v.GetAttribute("Type"))
	End Function

	Function CastingValue(value, DataType)
		On Error Resume Next

		Select Case DataType
			Case "Integer"
				CastingValue = CInt(Value)
			Case "Float"
				CastingValue = CDbl(Value)
			Case "Currency"
				CastingValue = CCur(Value)
			Case "String"
				CastingValue = CStr(Value)
			Case "Double"
				CastingValue = CDbl(Value)
			Case "Date"
				CastingValue = CDate(Value)
			Case Else
				CastingValue = CInt(Value)
		End Select

		If Err.number <> 0 Then
			CastingValue = CStr(Value)
		End If
		On Error GoTo 0
	End Function
	
	Function ProcessCustomValidator(v, curr, Col)
		Dim FuncName
		FuncName = v.GetAttribute("OnServerValidate")

		Execute("ProcessCustomValidator = " & FuncName & "(curr, Col)")
	End Function
	
	Function ProcessRangeValidator(v, curr, Col)
		On Error Resume Next
		Dim min, max, value
		min = CCur(v.GetAttribute("MinimumValue"))
		max = CCur(v.GetAttribute("MaximumValue"))
		value = CCur(Col(curr))
		
		ProcessRangeValidator = ((value>=min) And (value<=max))
		
		If Err.number <> 0 Then
			ProcessRangeValidator = False
		End If
		On Error GoTo 0
	End Function
	
	Function ProcessLengthValidator(v, curr, Col)
		Dim min, max, length
		min = CInt(v.GetAttribute("MinimumValue"))
		max = CInt(v.GetAttribute("MaximumValue"))
		length = Len(Col(curr))
		
		ProcessLengthValidator = ((length>=min) And (length<=max))
	End Function
		
	Function ProcessRegularExpressionValidator(v, curr, Col)
		Dim reg
		Set reg = New RegExp
		reg.Pattern = v.GetAttribute("ValidationExpression")
		
		ProcessRegularExpressionValidator = reg.Test(Col(curr))
	End Function
	
	Function ProcessRequiredFieldValidator(v, curr, Col)
		ProcessRequiredFieldValidator = (Len(Col(curr)) > 0)
	End Function
	
	Sub t(msg)
		'Response.Write "<font color=silver>" & msg & "</font><br>" & vbCrLf
	End Sub
End Class
%>