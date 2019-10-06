var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_func_map_0 = function(iterator) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(iterator === void 0 || iterator === null) {
			throw new TypeError("'iterator' is not nullable");
		}
		else if(!Type.isFunction(iterator)) {
			throw new TypeError("'iterator' is not of type 'Function'");
		}
		let results = [];
		for(let index in this) {
			let item = this[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Dictionary._im_map = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Dictionary.__ks_func_map_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	console.log(__ks_Dictionary._im_map((() => {
		const d = new Dictionary();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})(), function(item, name) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		return (() => {
			const d = new Dictionary();
			d.name = name;
			d.item = item;
			return d;
		})();
	}));
};