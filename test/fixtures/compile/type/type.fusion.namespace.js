const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isRange: value => Type.isDexObject(value, 1, 0, {start: __ksType.isPosition, end: __ksType.isPosition})
	};
	let SyntaxAnalysis = Helper.namespace(function() {
		const __ksType0 = {
			isParsingError: value => __ksType.isRange(value) && Type.isDexObject(value, 1, 0, {expecteds: value => Type.isArray(value, Type.isString)})
		};
		return {};
	});
};