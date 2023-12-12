const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isFoobar: value => Type.isDexObject(value, 1, 0, {values: value => Type.isArray(value, Type.isString) || Type.isNull(value)})
	};
	return {
		__ksType: [__ksType.isFoobar]
	};
};