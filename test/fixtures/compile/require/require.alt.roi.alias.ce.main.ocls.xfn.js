require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	const Quxbaz = Helper.alias(value => Type.isDexObject(value, 1, 0, {value: value => Type.isClassInstance(value, Foobar)}));
	var {Foobar, Quxbaz, foobar, quxbaz} = require("./.require.alt.roi.alias.ce.roi.wfn.xa.ks.1m8hpzz.ksb")(Foobar, Quxbaz);
	quxbaz.__ks_0(Foobar.__ks_new_0());
};