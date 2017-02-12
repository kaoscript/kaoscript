var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	Helper.newInstanceMethod({
		class: Object,
		name: "map",
		sealed: __ks_Object,
		function: function(iterator) {
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
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Function",
					min: 1,
					max: 1
				}
			]
		}
	});
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