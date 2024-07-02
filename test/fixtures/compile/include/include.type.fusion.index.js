const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const Result = Helper.alias(value => Position.is(value) && Type.isDexObject(value, 1, 0, {value: Type.isString}));
	return {
		Position,
		Result
	};
};