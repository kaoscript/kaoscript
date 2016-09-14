module.exports = function(Class, Type) {
	var __ks_Function = {};
	Class.newClassMethod({
		class: Function,
		name: "vcurry",
		final: __ks_Function,
		function: function(self, bind = null, ...args) {
			if(self === undefined || self === null) {
				throw new Error("Missing parameter 'self'");
			}
			if(!Type.isFunction(self)) {
				throw new Error("Invalid type for parameter 'self'");
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