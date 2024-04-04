const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.struct(function(ok, value = null) {
		const _ = new OBJ();
		_.ok = ok;
		_.value = value;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isBoolean;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Event)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isBoolean(arg = item.ok)) {
			return null;
		}
		args[0] = arg;
		if(!true) {
			return null;
		}
		args[1] = arg;
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
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		throw() {
			return this.__ks_func_throw_rt.call(null, this, this, arguments);
		}
		__ks_func_throw_0(expected) {
			throw new Error("Expecting \"" + expected + "\"");
		}
		__ks_func_throw_1(expecteds) {
			throw new Error("Expecting \"" + expecteds.join("\", \"") + "\"");
		}
		__ks_func_throw_rt(that, proto, args) {
			const t0 = Type.isString;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_throw_0.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_throw_1.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(event) {
			this.throw(...Helper.toArray(event.value, 1));
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isStructInstance(value, Event);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};