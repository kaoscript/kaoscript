const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isFoobar: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber, foo: Type.isFunction})
	};
	return {
		__ksType: [__ksType.isFoobar]
	};
};