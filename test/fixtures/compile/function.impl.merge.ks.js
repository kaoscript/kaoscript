var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	Helper.newClassMethod({
		class: Array,
		name: "merge",
		final: __ks_Array,
		function: function(...args) {
			let source;
			let i = 0;
			let l = args.length;
			let __ks_0;
			while((i < l) && !((Type.isValue(__ks_0 = args[i]) ? (source = __ks_0, true) : false) && (Type.isArray(source)))) {
				++i;
			}
			++i;
			while(i < l) {
				if(Type.isArray(args[i])) {
					__ks_0 = args[i];
					for(let value in __ks_0) {
						source.pushUniq(value);
					}
				}
				++i;
			}
			return source;
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
}