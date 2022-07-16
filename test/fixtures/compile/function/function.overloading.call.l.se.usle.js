const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function reverse() {
		return reverse.__ks_rt(this, arguments);
	};
	reverse.__ks_0 = function(value) {
		return value.split("").reverse().join("");
	};
	reverse.__ks_1 = function(value) {
		return value.slice().reverse();
	};
	reverse.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		const t1 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return reverse.__ks_1.call(that, args[0]);
			}
			if(t1(args[0])) {
				return reverse.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		console.log(Helper.toString(reverse(x)));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value) || Type.isString(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};