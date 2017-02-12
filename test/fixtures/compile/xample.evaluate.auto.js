var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "evaluate",
		sealed: __ks_String,
		function: function() {
			let value = this.trim();
			if(__ks_String._im_startsWith(value, "function") || __ks_String._im_startsWith(value, "{")) {
				return eval("(function(){return " + value + ";})()");
			}
			else {
				return eval(value);
			}
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	Helper.newInstanceMethod({
		class: String,
		name: "startsWith",
		sealed: __ks_String,
		function: function(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isString(value)) {
				throw new TypeError("'value' is not of type 'String'");
			}
			return (this.length >= value.length) && (this.slice(0, value.length) === value);
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "String",
					min: 1,
					max: 1
				}
			]
		}
	});
}