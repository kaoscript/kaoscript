const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(message, line) {
			this._message = message;
			this._line = line;
		}
		__ks_cons_1(message, {line}) {
			Foobar.prototype.__ks_cons_0.call(this, message, line);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			const t1 = Type.isNumber;
			const t2 = Position.is;
			if(args.length === 2) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						return Foobar.prototype.__ks_cons_0.call(that, args[0], args[1]);
					}
					if(t2(args[1])) {
						return Foobar.prototype.__ks_cons_1.call(that, args[0], args[1]);
					}
					throw Helper.badArgs();
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(message, data) {
			if(message === void 0 || message === null) {
				message = "quxbaz";
			}
			Foobar.prototype.__ks_cons_1.call(this, message, data);
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const t1 = Position.is;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return Quxbaz.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
	}
};