const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let bar = (Type.isValue(x) ? x : Type.isValue(y) ? y : z)();
};