var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "evaluate",
		sealed: __ks_String,
		function: function() {
			const value = this.trim();
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
			if(value === undefined || value === null) {
				throw new Error("Missing parameter 'value'");
			}
			else if(!Type.isString(value)) {
				throw new Error("Invalid type for parameter 'value'");
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