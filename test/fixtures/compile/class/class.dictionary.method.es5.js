var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper, Operator = __ks__.Operator;
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
		__ks_func_xy_0: function() {
			return (function(that) {
				var d = new Dictionary();
				d.xy = that.xy(that._x, that._y);
				return d;
			})(this);
		},
		__ks_func_xy_1: function(x, y) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return Operator.addOrConcat(x, y);
		},
		xy: function() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_xy_0.apply(this);
			}
			else if(arguments.length === 2) {
				return Foobar.prototype.__ks_func_xy_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
};