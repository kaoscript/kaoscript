var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var x = 0;
	console.log(x);
	var o = new Dictionary();
	o.x = 30;
	if(true) {
		var __ks_x_1 = 42;
		console.log(__ks_x_1);
		if(true) {
			var __ks_x_2 = 10;
			console.log(__ks_x_2);
		}
		console.log(__ks_x_1);
	}
	console.log(x);
	function foo() {
		var x = 5;
	}
};