const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Data = Helper.struct(function(positions) {
		const _ = new OBJ();
		_.positions = positions;
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
		if(Type.isStructInstance(item, Data)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isArray(arg = item.positions, Type.isNumber)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._positions = [];
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(data) {
			this._positions = data.positions;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isStructInstance(value, Data);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};