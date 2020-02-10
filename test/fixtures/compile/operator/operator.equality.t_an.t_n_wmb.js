var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		let x = null;
		if(Type.isValue(x) ? x.foo !== null : false) {
		}
	}
};