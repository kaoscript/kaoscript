const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.tuple(function(x, y) {
		return [x, y];
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._x = 0;
			this._y = 0;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		position() {
			return this.__ks_func_position_rt.call(null, this, this, arguments);
		}
		__ks_func_position_0() {
			return (() => {
				const d = new Dictionary();
				d.start = Position.__ks_new(this._x, this._y);
				return d;
			})();
		}
		__ks_func_position_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_position_0.call(that);
			}
			throw Helper.badArgs();
		}
		position_dict() {
			return this.__ks_func_position_dict_rt.call(null, this, this, arguments);
		}
		__ks_func_position_dict_0() {
			return (() => {
				const d = new Dictionary();
				d.x = this._x;
				d.y = this._y;
				return d;
			})();
		}
		__ks_func_position_dict_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_position_dict_0.call(that);
			}
			throw Helper.badArgs();
		}
		position_tuple() {
			return this.__ks_func_position_tuple_rt.call(null, this, this, arguments);
		}
		__ks_func_position_tuple_0() {
			return Position.__ks_new(this._x, this._y);
		}
		__ks_func_position_tuple_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_position_tuple_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};