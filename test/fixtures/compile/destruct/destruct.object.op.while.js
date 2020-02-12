var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return null;
	}
	let x, __ks_0;
	while(Type.isValue(__ks_0 = foobar()) ? ({x} = __ks_0, true) : false) {
	}
	while(Type.isValue(__ks_0 = foobar()) ? (({x} = __ks_0), true) : false) {
	}
};