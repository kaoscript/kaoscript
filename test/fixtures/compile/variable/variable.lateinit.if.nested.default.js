var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function quxbaz() {
		return 42;
	}
	function foobar() {
		let x = null;
		let a = quxbaz();
		if(Type.isValue(a)) {
			if(a === 0) {
				x = -1;
			}
			else {
				x = a;
			}
		}
		else {
			x = 0;
		}
		return x + 2;
	}
};