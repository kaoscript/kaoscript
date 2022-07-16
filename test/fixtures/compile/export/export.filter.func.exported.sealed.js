const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Foobar = {};
	__ks_Foobar.__ks_func_foo_0 = function() {
	};
	__ks_Foobar._im_foo = function(that, ...args) {
		return __ks_Foobar.__ks_func_foo_rt(that, args);
	};
	__ks_Foobar.__ks_func_foo_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Foobar.__ks_func_foo_0.call(that);
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return new Foobar();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function qux() {
		return qux.__ks_rt(this, arguments);
	};
	qux.__ks_0 = function(x) {
		return x;
	};
	qux.__ks_1 = function(x) {
		return x;
	};
	qux.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return qux.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return qux.__ks_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		foobar,
		qux
	};
};