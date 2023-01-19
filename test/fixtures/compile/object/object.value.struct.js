const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
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
				const o = new OBJ();
				o.start = Position.__ks_new(this._x, this._y);
				return o;
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
				const o = new OBJ();
				o.x = this._x;
				o.y = this._y;
				return o;
			})();
		}
		__ks_func_position_dict_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_position_dict_0.call(that);
			}
			throw Helper.badArgs();
		}
		position_struct() {
			return this.__ks_func_position_struct_rt.call(null, this, this, arguments);
		}
		__ks_func_position_struct_0() {
			return Position.__ks_new(this._x, this._y);
		}
		__ks_func_position_struct_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_position_struct_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};