var Helper = require("@kaoscript/runtime").Helper;
module.exports = function(Array, __ks_Array) {
	Helper.newInstanceMethod({
		class: Array,
		name: "contains",
		sealed: __ks_Array,
		function: function() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			var item = arguments[++__ks_i];
			if(arguments.length > 1) {
				var from = arguments[++__ks_i];
			}
			else  {
				var from = 0;
			}
			return this.indexOf(item, from) !== -1;
		},
		signature: {
			access: 3,
			min: 1,
			max: 2,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 2
				}
			]
		}
	});
	Helper.newInstanceMethod({
		class: Array,
		name: "pushUniq",
		sealed: __ks_Array,
		function: function(...args) {
			if(args.length === 1) {
				if(!__ks_Array._im_contains(this, args[0])) {
					this.push(args[0]);
				}
			}
			else {
				for(let __ks_0 = 0, __ks_1 = args.length, item; __ks_0 < __ks_1; ++__ks_0) {
					item = args[__ks_0];
					if(!__ks_Array._im_contains(this, item)) {
						this.push(item);
					}
				}
			}
			return this;
		},
		signature: {
			access: 3,
			min: 1,
			max: Infinity,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: Infinity
				}
			]
		}
	});
	return {
		Array: Array,
		__ks_Array: __ks_Array
	};
}