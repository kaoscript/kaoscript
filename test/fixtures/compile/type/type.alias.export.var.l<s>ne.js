const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.alias(value => Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, Type.isString) || Type.isNull(value)}));
	return {
		Foobar
	};
};