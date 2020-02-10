var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	var Position = Helper.tuple(function(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		return [x, y];
	});
	var Foobar = Helper.class({
		$name: "Foobar",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_1: function() {
			this._x = 0;
			this._y = 0;
		},
		__ks_init: function() {
			Foobar.prototype.__ks_init_1.call(this);
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