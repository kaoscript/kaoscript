module.exports = function(Helper, Type) {
	var __ks_Function = {};
	Helper.newClassMethod({
		class: Function,
		name: "vcurry",
		sealed: __ks_Function,
		function: function(self, bind = null, ...args) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(self === void 0 || self === null) {
				throw new TypeError("'self' is not nullable");
			}
			else if(!Type.isFunction(self)) {
				throw new TypeError("'self' is not of type 'Function'");
			}
			return function(...additionals) {
				return self.apply(bind, args.concat(additionals));
			};
		},
		signature: {
			access: 3,
			min: 1,
			max: Infinity,
			parameters: [
				{
					type: "Function",
					min: 1,
					max: 1
				},
				{
					type: "Any",
					min: 0,
					max: Infinity
				}
			]
		}
	});
	return {
		Function: Function,
		__ks_Function: __ks_Function
	};
}