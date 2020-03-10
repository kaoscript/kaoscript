var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	var Position = Helper.tuple(function(__ks_0, __ks_1) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(__ks_0 === void 0 || __ks_0 === null) {
			throw new TypeError("'__ks_0' is not nullable");
		}
		else if(!Type.isNumber(__ks_0)) {
			throw new TypeError("'__ks_0' is not of type 'Number'");
		}
		if(__ks_1 === void 0 || __ks_1 === null) {
			throw new TypeError("'__ks_1' is not nullable");
		}
		else if(!Type.isNumber(__ks_1)) {
			throw new TypeError("'__ks_1' is not of type 'Number'");
		}
		return [__ks_0, __ks_1];
	});
	var Foobar = Helper.class({
		$name: "Foobar",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_0: function() {
			this._x = 0;
			this._y = 0;
		},
		__ks_init: function() {
			Foobar.prototype.__ks_init_0.call(this);
		},
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_position_0: function() {
			return (function(that) {
				var d = new Dictionary();
				d.start = Position(that._x, that._y);
				return d;
			})(this);
		},
		position: function() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_position_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		},
		__ks_func_position_dict_0: function() {
			return (function(that) {
				var d = new Dictionary();
				d.x = that._x;
				d.y = that._y;
				return d;
			})(this);
		},
		position_dict: function() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_position_dict_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		},
		__ks_func_position_tuple_0: function() {
			return Position(this._x, this._y);
		},
		position_tuple: function() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_position_tuple_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
};