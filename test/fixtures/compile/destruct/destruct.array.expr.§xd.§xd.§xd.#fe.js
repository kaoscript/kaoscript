const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let x, y, z;
	([x, y, z] = Helper.assert(foobar(), "\"[Any, Any, Any]\"", 0, value => Type.isDexArray(value, 1, 3, 0, 0, [Type.isValue, Type.isValue, Type.isValue])));
};