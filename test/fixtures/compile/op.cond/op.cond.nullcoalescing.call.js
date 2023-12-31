const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (Type.isValue(x) ? x : y)();
	let bar = (Type.isValue(x) ? x : Type.isValue(y) ? y : z)();
};