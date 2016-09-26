var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	Helper.newInstanceMethod({
		class: Object,
		name: "map",
		final: __ks_Object,
		function: function(iterator) {
			if(iterator === undefined || iterator === null) {
				throw new Error("Missing parameter 'iterator'");
			}
			if(!Type.isFunction(iterator)) {
				throw new Error("Invalid type for parameter 'iterator'");
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
		if(item === undefined || item === null) {
			throw new Error("Missing parameter 'item'");
		}
		if(name === undefined || name === null) {
			throw new Error("Missing parameter 'name'");
		}
		return {
			name: name,
			item: item
		};
	}));
}