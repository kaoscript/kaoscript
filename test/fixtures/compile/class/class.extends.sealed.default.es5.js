var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Error = {};
	let NotImplementedError = Helper.class({
		$name: "NotImplementedError",
		$extends: Error,
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons_0: function(message) {
			if(message === void 0 || message === null) {
				message = "Not Implemented";
			}
			(1);
			this.message = message;
		},
		__ks_cons: function(args) {
			if(args.length >= 0 && args.length <= 1) {
				NotImplementedError.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	});
};