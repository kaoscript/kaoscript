var {Helper, Type} = require("@kaoscript/runtime");
function __ks_require(__ks_0, __ks___ks_0) {
	if(Type.isValue(__ks_0)) {
		return [__ks_0, __ks___ks_0];
	}
	else {
		return [Array, typeof __ks_Array === "undefined" ? {} : __ks_Array];
	}
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Array, __ks_Array] = __ks_require(__ks_0, __ks___ks_0);
	Helper.newInstanceMethod({
		class: Array,
		name: "contains",
		final: __ks_Array,
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
		final: __ks_Array,
		function: function(...args) {
			if(args.length === 1) {
				if(!__ks_Array._im_contains(this, args[0])) {
					this.push(args[0]);
				}
			}
			else {
				for(let __ks_1 = 0, __ks_2 = args.length, item; __ks_1 < __ks_2; ++__ks_1) {
					item = args[__ks_1];
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