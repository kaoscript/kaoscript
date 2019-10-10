var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
	}
	function quxbaz() {
		let x, __ks_0;
		if(Type.isValue(__ks_0 = foobar()) ? (x = __ks_0, false) : true) {
			throw new Error();
		}
		return x.y;
	}
};