const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, mapper) => Type.isDexObject(value, 1, 0, {ok: Type.isBoolean, value: () => true}));
};