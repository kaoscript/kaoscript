const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	console.log(Position);
};