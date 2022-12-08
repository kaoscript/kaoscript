const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function dot() {
		return dot.__ks_rt(this, arguments);
	};
	dot.__ks_0 = function(foo) {
		return foo.bar;
	};
	dot.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return dot.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function bracket() {
		return bracket.__ks_rt(this, arguments);
	};
	bracket.__ks_0 = function(foo, bar) {
		return foo[bar];
	};
	bracket.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return bracket.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};