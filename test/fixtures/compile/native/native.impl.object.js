const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_func_map_0 = function(iterator) {
		let results = [];
		for(const index in this) {
			const item = this[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Object._im_map = function(that, ...args) {
		return __ks_Object.__ks_func_map_rt(that, args);
	};
	__ks_Object.__ks_func_map_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Object.__ks_func_map_0.call(that, args[0]);
			}
		}
		if(that.map) {
			return that.map(...args);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Object.__ks_func_map_0.call((() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})(), Helper.function((item, name) => {
		return (() => {
			const o = new OBJ();
			o.name = name;
			o.item = item;
			return o;
		})();
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	})));
};