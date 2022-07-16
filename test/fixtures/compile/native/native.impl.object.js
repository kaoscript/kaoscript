const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_func_map_0 = function(iterator) {
		let results = [];
		for(let index in this) {
			let item = this[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Dictionary._im_map = function(that, ...args) {
		return __ks_Dictionary.__ks_func_map_rt(that, args);
	};
	__ks_Dictionary.__ks_func_map_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Dictionary.__ks_func_map_0.call(that, args[0]);
			}
		}
		if(that.map) {
			return that.map(...args);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Dictionary.__ks_func_map_0.call((() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})(), (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return __ks_rt.__ks_0.call(this, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = (item, name) => {
			return (() => {
				const d = new Dictionary();
				d.name = name;
				d.item = item;
				return d;
			})();
		};
		return __ks_rt;
	})()));
};