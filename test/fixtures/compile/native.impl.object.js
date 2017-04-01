var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_func_map_0 = function(iterator) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(iterator === void 0 || iterator === null) {
			throw new TypeError("'iterator' is not nullable");
		}
		else if(!Type.isFunction(iterator)) {
			throw new TypeError("'iterator' is not of type 'Function'");
		}
		let results = [];
		for(let item in this) {
			let index = this[item];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Object._im_map = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Object.__ks_func_map_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	console.log(__ks_Object._im_map({
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	}, function(item, name) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		return {
			name: name,
			item: item
		};
	}));
}