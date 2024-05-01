const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let qux = Type.isValue(x) ? x : Type.isValue(y) ? y : z;
};