const {Helper, Type} = require("@kaoscript/runtime");
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
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function() {
		return "";
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function(x) {
		console.log(x);
		x = Helper.assertString(foo.__ks_0(), 0);
		console.log(x);
		x = bar.__ks_0();
		console.log(x);
	};
	corge.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return corge.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function grault() {
		return grault.__ks_rt(this, arguments);
	};
	grault.__ks_0 = function(x) {
		console.log(Helper.toString(x));
		x = Helper.assert(foo.__ks_0(), "\"Any\"", 0, Type.isValue);
		console.log(Helper.toString(x));
		x = bar.__ks_0();
		console.log(x);
	};
	grault.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return grault.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let x = "";
	console.log(x);
	x = Helper.assertString(foo.__ks_0(), 0);
	console.log(x);
	x = bar.__ks_0();
	console.log(x);
	let y = "";
	console.log(y);
	y = foo.__ks_0();
	console.log(Helper.toString(y));
	y = bar.__ks_0();
	console.log(y);
	return {
		corge,
		grault,
		x,
		y
	};
};