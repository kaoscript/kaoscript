const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isEvent: (value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return __ksType.isEvent.__1(value, mapper);
			}
			else {
				return __ksType.isEvent.__0(value);
			}
		}})
	};
	__ksType.isEvent.__0 = value => Type.isDexObject(value, 0, 0, {expecting: Type.isString});
	__ksType.isEvent.__1 = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		console.log(event.value);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [Type.isString], value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const event = (() => {
		const o = new OBJ();
		o.ok = true;
		o.value = "hello";
		return o;
	})();
	foobar.__ks_0(event);
};