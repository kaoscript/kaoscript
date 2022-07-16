const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(dict) {
		for(let __ks_0 in dict) {
			const value = dict[__ks_0];
			quxbaz.__ks_0(value);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isDictionary;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(value = null) {
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return quxbaz.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};