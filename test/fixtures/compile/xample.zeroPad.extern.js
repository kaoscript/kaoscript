var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "zeroPad",
		sealed: __ks_Number,
		function: function(length) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(length === void 0 || length === null) {
				throw new TypeError("'length' is not nullable");
			}
			return __ks_String._im_lpad(this.toString(), length, "0");
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 1
				}
			]
		}
	});
	var __ks_String = {};
	Helper.newInstanceMethod({
		class: String,
		name: "lpad",
		sealed: __ks_String,
		function: function(length, pad) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(length === void 0 || length === null) {
				throw new TypeError("'length' is not nullable");
			}
			if(pad === void 0 || pad === null) {
				throw new TypeError("'pad' is not nullable");
			}
			return pad.repeat(length - this.length) + this;
		},
		signature: {
			access: 3,
			min: 2,
			max: 2,
			parameters: [
				{
					type: "Any",
					min: 2,
					max: 2
				}
			]
		}
	});
}