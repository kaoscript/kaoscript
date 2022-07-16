const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = "otto";
	let quz = 0;
	let bar = null;
	if((++quz, true) && (++quz, Type.isValue(foo) ? (bar = foo, true) : false)) {
	}
};