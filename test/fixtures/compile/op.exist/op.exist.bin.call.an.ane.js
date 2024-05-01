const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (Type.isValue(x) ? x : y)();
};