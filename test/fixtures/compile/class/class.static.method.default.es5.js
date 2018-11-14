var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	let Shape = Helper.class({
		$name: "Shape",
		$static: {
			__ks_sttc_makeCircle_0: function(color) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(color === void 0 || color === null) {
					throw new TypeError("'color' is not nullable");
				}
				else if(!Type.isString(color)) {
					throw new TypeError("'color' is not of type 'String'");
				}
				return new Shape("circle", color);
			},
			makeCircle: function() {
				if(arguments.length === 1) {
					return Shape.__ks_sttc_makeCircle_0.apply(this, arguments);
				}
				throw new SyntaxError("wrong number of arguments");
			},
			__ks_sttc_makeRectangle_0: function(color) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(color === void 0 || color === null) {
					throw new TypeError("'color' is not nullable");
				}
				else if(!Type.isString(color)) {
					throw new TypeError("'color' is not of type 'String'");
				}
				return new Shape("rectangle", color);
			},
			makeRectangle: function() {
				if(arguments.length === 1) {
					return Shape.__ks_sttc_makeRectangle_0.apply(this, arguments);
				}
				throw new SyntaxError("wrong number of arguments");
			}
		},
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_1: function() {
			this._color = "";
			this._type = "";
		},
		__ks_init: function() {
			Shape.prototype.__ks_init_1.call(this);
		},
		__ks_cons_0: function(type, color) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(type === void 0 || type === null) {
				throw new TypeError("'type' is not nullable");
			}
			else if(!Type.isString(type)) {
				throw new TypeError("'type' is not of type 'String'");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._type = type;
			this._color = color;
		},
		__ks_cons: function(args) {
			if(args.length === 2) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	});
	let r = Shape.makeRectangle("black");
};