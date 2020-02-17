var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper;
module.exports = function() {
	var Foobar = Helper.class({
		$name: "Foobar",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_1: function() {
			this._values = new Dictionary();
		},
		__ks_init: function() {
			Foobar.prototype.__ks_init_1.call(this);
		},
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_foobar_0: function() {
			var values = Helper.concatDictionary(this._values);
		},
		foobar: function() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
};