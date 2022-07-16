const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let qux = Helper.namespace(function() {
		class Foobar {
			static __ks_new_0(...args) {
				const o = Object.create(Foobar.prototype);
				o.__ks_init();
				o.__ks_cons_0(...args);
				return o;
			}
			constructor() {
				this.__ks_init();
				this.__ks_cons_rt.call(null, this, arguments);
			}
			__ks_init() {
			}
			__ks_cons_0(name) {
				if(name === void 0 || name === null) {
					name = "john";
				}
				this._name = name;
			}
			__ks_cons_rt(that, args) {
				const t0 = value => Type.isString(value) || Type.isNull(value);
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length <= 1) {
					if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
						return Foobar.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]));
					}
				}
				throw Helper.badArgs();
			}
		}
		return {
			Foobar
		};
	});
	const x = qux.Foobar.__ks_new_0();
};