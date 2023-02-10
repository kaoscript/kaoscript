const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(values) {
		const _ = new OBJ();
		_.values = values;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isObject(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	const Quxbaz = Helper.struct(function(values) {
		const _ = new OBJ();
		_.values = values;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isObject(value, Type.isNumber);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(item) {
		for(let __ks_0 in item.values) {
			const value = item.values[__ks_0];
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isStructInstance(value, Foobar) || Type.isStructInstance(value, Quxbaz);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};