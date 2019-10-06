var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper;
module.exports = function() {
	var Foobar = Helper.class({
		$name: "Foobar",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_data_0: function(values) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(values === void 0 || values === null) {
				throw new TypeError("'values' is not nullable");
			}
			values.push((function(that) {
				var d = new Dictionary();
				d.value = that._value.name();
				return d;
			})(this));
		},
		data: function() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_data_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
};