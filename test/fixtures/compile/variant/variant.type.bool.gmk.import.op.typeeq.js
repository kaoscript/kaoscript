require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ksType0 = require("./.variant.type.bool.gmk.export.ks.j5k8r9.ksb")().__ksType;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		if(__ksType0[0].__1(event, [Type.isString])) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType0[0](value, [Type.any], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};