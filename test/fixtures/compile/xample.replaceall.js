var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "replaceAll",
		sealed: __ks_String,
		function: function(find, replacement) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(find === void 0 || find === null) {
				throw new TypeError("'find' is not nullable");
			}
			else if(!Type.isString(find)) {
				throw new TypeError("'find' is not of type 'String'");
			}
			if(replacement === void 0 || replacement === null) {
				throw new TypeError("'replacement' is not nullable");
			}
			if(find.length === 0) {
				return this.valueOf();
			}
			if(find.length <= 3) {
				return this.split(find).join(replacement);
			}
			else {
				return this.replace(new RegExp(find.escapeRegex(), "g"), replacement);
			}
		},
		signature: {
			access: 3,
			min: 2,
			max: 2,
			parameters: [
				{
					type: "String",
					min: 1,
					max: 1
				},
				{
					type: "Any",
					min: 1,
					max: 1
				}
			]
		}
	});
}