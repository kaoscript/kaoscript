const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let m = "qux";
	let qux = Type.isValue(foo) ? foo[m] : null;
};