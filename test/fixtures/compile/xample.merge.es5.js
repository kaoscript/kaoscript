var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	Helper.newClassMethod({
		class: Array,
		name: "merge",
		final: __ks_Array,
		function: function(...args) {
			var source;
			var i = 0;
			var l = args.length;
			while((i < l) && !((Type.isValue(args[i]) ? (source = args[i], true) : false) && Type.isArray(source))) {
				++i;
			}
			++i;
			while(i < l) {
				if(Type.isArray(args[i])) {
					for(var value in args[i]) {
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