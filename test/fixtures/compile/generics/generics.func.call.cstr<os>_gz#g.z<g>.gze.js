const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Named = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	const Event = Helper.alias((value, mapper) => Type.isDexObject(value, 1, 0, {value: () => true}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value, event) {
		return value;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Named.is;
		const t1 = value => Event.is(value, [Type.any]);
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
		const t0 = value => Event.is(value, [Named.is]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};