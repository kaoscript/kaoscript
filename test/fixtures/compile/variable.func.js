var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(bar = null) {
		let qux;
		if(Type.isValue(bar) ? (qux = bar, true) : false) {
			console.log(qux);
		}
	}
};