const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNamed: value => Type.isDexObject(value, 1, 0, {name: Type.isString}),
		isEvent: (value, mapper) => Type.isDexObject(value, 1, 0, {value: mapper[0]})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value, event) {
		return value;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isNamed;
		const t1 = value => __ksType.isEvent(value, [Type.any]);
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(event) {
		foobar.__ks_0(event.value, event);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [__ksType.isNamed]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};