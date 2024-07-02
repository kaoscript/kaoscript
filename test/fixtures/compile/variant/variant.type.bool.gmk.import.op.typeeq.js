require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Event = require("./.variant.type.bool.gmk.export.ks.j5k8r9.ksb")().Event;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		if(Event.isTrue(event, [Type.isString])) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [Type.any], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};