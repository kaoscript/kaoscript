var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(item) {
		if(item === void 0 || item === null) {
			item = 1;
		}
		console.log(item);
	}
	function bar(item) {
		if(item === void 0 || item === null) {
			item = 1;
		}
		console.log(item);
	}
	function baz(item = 1) {
		console.log(item);
	}
	function qux(item) {
		if(item === void 0 || item === null) {
			item = 1;
		}
		else if(!Type.isNumber(item)) {
			throw new TypeError("'item' is not of type 'Number'");
		}
		console.log(item);
	}
	function quux(item = 1) {
		if(item !== null && !Type.isNumber(item)) {
			throw new TypeError("'item' is not of type 'Number'");
		}
		console.log(item);
	}
}