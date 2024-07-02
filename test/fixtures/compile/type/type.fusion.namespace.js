const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const Range = Helper.alias(value => Type.isDexObject(value, 1, 0, {start: Position.is, end: Position.is}));
	let SyntaxAnalysis = Helper.namespace(function() {
		const ParsingError = Helper.alias(value => Range.is(value) && Type.isDexObject(value, 1, 0, {expecteds: value => Type.isArray(value, Type.isString)}));
		return {};
	});
};