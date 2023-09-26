const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function() {
		return new OBJ();
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	});
	if(Type.isStruct(Foobar)) {
	}
	const Quxbaz = Helper.struct(function() {
		return new OBJ();
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(Type.isStructInstance(x, Quxbaz)) {
		}
		else if(Type.isStructInstance(x, Foobar)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};