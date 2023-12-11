const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isResult: value => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {value: Type.isString})
	};
};