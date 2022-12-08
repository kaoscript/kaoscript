const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 0;
	console.log(x);
	let o = new OBJ();
	o.x = 30;
	if(true) {
		let x = 42;
		console.log(x);
		if(true) {
			let x = 10;
			console.log(x);
		}
		console.log(x);
	}
	console.log(x);
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		let x = 5;
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};