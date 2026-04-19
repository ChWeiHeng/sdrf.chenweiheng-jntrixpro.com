function isEmpty(object){
	if(object==null || object==undefined || object=="" || object==NaN){
		return true;
	}else{
		return false;
	}
}

//数值是否大于0
function isGtZero(object){
	return !isEmpty(object) && object > 0;
}

//计算毛利率
function calculateMargin(cost,price){
	console.log("rate:"+((parseFloat(price)-parseFloat(cost))/parseFloat(price)).toFixed(4));
	return ((parseFloat(price)-parseFloat(cost))/parseFloat(price)).toFixed(4) ;
}

//小数位数
function getDitigal(price){
	if(!isEmpty(price) && isGtZero(price)){
		if(String(price).indexOf(".")!=-1){
            var digitalLength = String(price).length - (String(price).indexOf(".")+1);
            console.log("digitalLength:"+digitalLength);
            return digitalLength;
        }
	}
	return undefined;
}

//是否大于两位小数
function isGtTwoDigitals(price){
	if(!isEmpty(price) && isGtZero(price)){
		if(String(price).indexOf(".")!=-1){
            var digitalLength = String(price).length - (String(price).indexOf(".")+1);
            if(digitalLength>2){
            	return true;
            }
        }
	}
	return false;
}

export{isEmpty,isGtZero,calculateMargin,getDitigal,isGtTwoDigitals}