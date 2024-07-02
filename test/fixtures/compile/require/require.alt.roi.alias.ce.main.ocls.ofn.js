require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
	var {Foobar, Quxbaz} = require("./.require.alt.roi.alias.ce.roi.nfn.ks.1m8hpzz.ksb")(Foobar, Quxbaz);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Quxbaz.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		const foo = Foobar.__ks_new_0();
		foobar.__ks_0((() => {
			const o = new OBJ();
			o.value = foo;
			return o;
		})());
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	quxbaz.__ks_0();
};