var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Number = {};
	Helper.newInstanceMethod({
		class: Number,
		name: "zeroPad",
		sealed: __ks_Number,
		function: function(length) {
			if(length === undefined || length === null) {
				throw new Error("Missing parameter 'length'");
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
			if(length === undefined || length === null) {
				throw new Error("Missing parameter 'length'");
			}
			if(pad === undefined || pad === null) {
				throw new Error("Missing parameter 'pad'");
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