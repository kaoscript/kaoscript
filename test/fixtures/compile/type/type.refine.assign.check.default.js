const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return "";
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let x = "";
	console.log(x);
	x = foo.__ks_0();
	console.log(x);
	let y = 42;
	console.log(Helper.toString(y));
	y = foo.__ks_0();
	console.log(y);
	return {
		foo,
		x,
		y
	};
};