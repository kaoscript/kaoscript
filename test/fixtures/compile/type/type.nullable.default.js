const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isEvent: value => Type.isDexObject(value, 1, 0, {ok: Type.isBoolean, value: () => true})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		if(Type.isValue(event.value)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isEvent;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};