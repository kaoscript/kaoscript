require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = require("../_/._function.ks.j5k8r9.ksb")().__ks_Function;
	class Template {
		static __ks_new_0() {
			const o = Object.create(Template.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		compile() {
			return this.__ks_func_compile_rt.call(null, this, this, arguments);
		}
		__ks_func_compile_0() {
			return Helper.function(() => {
				return 42;
			}, (that, fn, ...args) => {
				if(args.length === 0) {
					return fn.call(null);
				}
				throw Helper.badArgs();
			});
		}
		__ks_func_compile_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_compile_0.call(that);
			}
			throw Helper.badArgs();
		}
		run() {
			return this.__ks_func_run_rt.call(null, this, this, arguments);
		}
		__ks_func_run_0(args) {
		}
		__ks_func_run_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_run_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
	}
	const template = Template.__ks_new_0();
	return {
		Template,
		template
	};
};