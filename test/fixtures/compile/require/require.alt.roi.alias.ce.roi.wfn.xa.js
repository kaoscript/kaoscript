require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(Foobar, Quxbaz) {
	var __ks_0_valuable = Type.isValue(Foobar);
	var __ks_1_valuable = Type.isValue(Quxbaz);
	if(!__ks_0_valuable && !__ks_1_valuable) {
		var {Foobar, Quxbaz} = require("./.require.alt.roi.alias.ce.genesis.ks.j5k8r9.ksb")();
	}
	else if(!(__ks_0_valuable || __ks_1_valuable)) {
		throw Helper.badRequirements();
	}
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
	quxbaz.__ks_0 = function(foo) {
		foobar.__ks_0((() => {
			const o = new OBJ();
			o.value = foo;
			return o;
		})());
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Foobar,
		Quxbaz,
		foobar,
		quxbaz
	};
};