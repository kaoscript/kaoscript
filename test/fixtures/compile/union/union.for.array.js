const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(values) {
		const _ = new OBJ();
		_.values = values;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Foobar)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isArray(arg = item.values, Type.isString)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const Quxbaz = Helper.struct(function(values) {
		const _ = new OBJ();
		_.values = values;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isArray(value, Type.isNumber);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Quxbaz)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isArray(arg = item.values, Type.isNumber)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(item) {
		for(let __ks_1 = 0, __ks_0 = item.values.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = item.values[__ks_1];
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