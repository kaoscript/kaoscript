const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const T = Helper.alias(value => Type.isNumber(value) || Type.isString(value));
	return {
		T
	};
};