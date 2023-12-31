const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Data = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isBoolean;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
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
		if(!Type.isBoolean(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isBoolean(arg = item.y)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(data) {
			this._x = data.x;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isStructInstance(value, Data);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};