const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_0) {
	if(Type.isValue(__ks_0)) {
		Foobar = __ks_0;
	}
	Foobar.prototype.__ks_func_foobar_0 = function(x) {
		return x;
	};
	Foobar.prototype.__ks_func_foobar_rt = function(that, proto, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_foobar_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Foobar.prototype.foobar = function() {
		return this.__ks_func_foobar_rt.call(null, this, this, arguments);
	};
	return {
		Foobar
	};
};