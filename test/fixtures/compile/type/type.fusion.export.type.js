const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isResult: value => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, Type.isNumber) || Type.isNumber(value) || Type.isNull(value)})
	};
	return {
		__ksType: [__ksType.isResult]
	};
};