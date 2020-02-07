var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
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
		__ks_func_message_0: function(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return x.toString();
		},
		message: function() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_message_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
	var Quxbaz = Helper.class({
		$name: "Quxbaz",
		$extends: Foobar,
		__ks_init: function() {
			Foobar.prototype.__ks_init.call(this);
		},
		__ks_cons: function(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		},
		__ks_func_message_0: function(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return x;
		},
		__ks_func_message_1: function(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return Helper.toString(x);
		},
		message: function() {
			if(arguments.length === 1) {
				if(Type.isNumber(arguments[0])) {
					return Quxbaz.prototype.__ks_func_message_1.apply(this, arguments);
				}
				else if(Type.isString(arguments[0])) {
					return Quxbaz.prototype.__ks_func_message_0.apply(this, arguments);
				}
			}
			return Foobar.prototype.message.apply(this, arguments);
		}
	});
};