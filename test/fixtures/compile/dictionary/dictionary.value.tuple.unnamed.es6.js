var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
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
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._x = 0;
			this._y = 0;
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_position_0() {
			return (() => {
				const d = new Dictionary();
				d.start = Position(this._x, this._y);
				return d;
			})();
		}
		position() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_position_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_position_dict_0() {
			return (() => {
				const d = new Dictionary();
				d.x = this._x;
				d.y = this._y;
				return d;
			})();
		}
		position_dict() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_position_dict_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_position_tuple_0() {
			return Position(this._x, this._y);
		}
		position_tuple() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_position_tuple_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};