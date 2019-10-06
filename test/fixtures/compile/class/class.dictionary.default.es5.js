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
		__ks_func_data_0: function() {
			this._z = 1;
			return (function(that) {
				var d = new Dictionary();
				x: that._x;
				y: that._y;
				d.power = (function(that) {
					var d = new Dictionary();
					z: that._z;
					return d;
				})(that);
				return d;
			})(this);
		},
		data: function() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_data_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
};