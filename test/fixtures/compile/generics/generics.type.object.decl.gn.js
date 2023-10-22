const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isEvent: (value, mapper) => Type.isDexObject(value, 1, 0, {ok: Type.isBoolean, value: mapper[0]})
	};
};