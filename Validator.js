/**
	@author		BAEK, CHANG YOL  http://cybaek.com/
	@email		cybaek@netsgo.com
	@version	0.1
	@update	2003.12.07
	
	Copyrights reserved.
*/

function checkValues(fileName, formObject){
	return applyValidators(formObject, loadValidationRules(fileName));
}

function loadValidationRules(fileName){
	var xml = new ActiveXObject("Microsoft.XMLDOM");
	xml.async = false;
	xml.load(fileName);

	return xml;
}


function applyValidator(v, curr, f){
	if (v.nodeName == 'RequiredFieldValidator'){
		return processRequiredFieldValidator(v, curr);
	}
	else if (v.nodeName == 'RegularExpressionValidator'){
		return processRegularExpressionValidator(v, curr);
	}
	else if (v.nodeName == 'RangeValidator'){
		return processRangeValidator(v, curr);
	}
	else if (v.nodeName == 'CustomValidator'){
		return processCustomValidator(v, curr);
	}
	else if (v.nodeName == 'CompareValidator'){
		return processCompareValidator(v, curr, f);
	}
	else if (v.nodeName == 'LengthValidator'){
		return processLengthValidator(v, curr, f);
	}
	else{
		return true;
	}
}

function processLengthValidator(v, curr, f){
	var min = parseInt(v.getAttribute("MinimumValue"));
	var max = parseInt(v.getAttribute("MaximumValue"));
	var length = getStringLength(curr.value);
	
	return (length>=min) && (length<=max);
}

function getStringLength(str){
	var i, total;
	
	for (i=0, total=0; i<str.length; i++){
		if ((str.charCodeAt(i)<0) || (str.charCodeAt(i)>127)){
			total++;
		}
	}
	
	return str.length + total;
}

function processCompareValidator(v, curr, f){
	var valueToCompare = getValueToCompare(v, f);
	var dataType = v.getAttribute('Type');
	var value = castingValue(curr.value, dataType);
	var operator = v.getAttribute('Operator');
	
	if (operator == 'Equal'){
		return value == valueToCompare;
	}
	else if (operator == 'NotEqual'){
		return value != valueToCompare;
	}
	else if (operator == 'GreaterThan'){
		return value > valueToCompare;
	}
	else if (operator == 'GreaterThanEqual'){
		return value >= valueToCompare;
	}
	else if (operator == 'LessThan'){
		return value  < valueToCompare;
	}
	else if (operator == 'LessThanEqual'){
		return value <= valueToCompare;
	}
	else if (operator == 'DataTypeCheck'){
		// @todo
		return true;
	}	
}

function getValueToCompare(v, f){
	var value = v.getAttribute("ValueToCompare");
	var controlToCompare = v.getAttribute("ControlToCompare");

	if (controlToCompare != null){
		value = f.elements[controlToCompare].value;
	}
	
	return castingValue(value, v.getAttribute("Type"));
}

function processCustomValidator(v, curr){
	var funcName = v.getAttribute("ClientValidationFunction");
	return eval(funcName + '(curr, curr.value)');
}

function processRangeValidator(v, curr){
	var dataType = v.getAttribute("Type");
	var min = v.getAttribute("MinimumValue");
	var max = v.getAttribute("MaximumValue");
	var value = curr.value;
	
	if (isNaN(value)){
		return false;
	}
	value = castingValue(value, dataType);
	min = castingValue(min, dataType);
	max = castingValue(max, dataType);
	
	return (value>=min) && (value<=max);
}

function castingValue(value, dataType){
	if (dataType == 'Integer'){
		return parseInt(value);
	}
	else if (dataType == 'Float'){
		return parseFloat(value);
	}
	else if (dataType == 'Currency'){
		// @todo
		return parseInt(value);
	}
	else if (dataType == 'String'){
		// no op.
		return value;
	}
	else if (dataType == 'Double'){
		// @todo
		return parseFloat(value);
	}
	else if (dataType == 'Date'){
		return new Date(value);
	}
	else{
		// parseInt is used for default casting.
		try{
			value = parseInt(value);
		}
		catch(e){
			// ignore.
		}
	}
	
	return value;
}

function processRegularExpressionValidator(v, curr){
	var re = new RegExp(v.getAttribute("ValidationExpression"), "");
	return re.test(curr.value);
}

function processRequiredFieldValidator(v, curr){
	return curr.value.length != 0;
}

function applyValidators(f, rules){
	var e = f.elements;
	var i, j;

	var rule, validators, validator, varName;

	for(i=0; i<e.length; i++){
		varName = e[i].name;
		rule = rules.selectSingleNode('//Rule[@name="' + varName + '"]')

		if (rule!=null){
			validators = rule.childNodes;
			for (j=0; j<validators.length; j++){
				validator = validators.nextNode;
				if (validator != null) {
					if (!applyValidator(validator, e[i], f)){
						e[i].focus();
						alert(validator.getAttribute("ErrorMessage"));

						return false;
					}
				}
			}
		}
	}
}
