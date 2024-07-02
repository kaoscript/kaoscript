const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const RegExpExecArray = Helper.alias(value => Type.isArray(value, value => Type.isString(value) || Type.isNull(value)) && Type.isDexObject(value, 1, 0, {index: Type.isNumber, input: Type.isString}));
	return {
		exec,
		RegExpExecArray
	};
};