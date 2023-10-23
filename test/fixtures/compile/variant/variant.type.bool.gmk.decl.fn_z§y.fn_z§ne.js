const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isEvent: (value, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return Type.isDexObject(value, 0, 0, {value: Type.isString});
			}
			else {
				return Type.isDexObject(value, 0, 0, {expecting: value => Type.isString(value) || Type.isNull(value)});
			}
		}})
	};
	function getNoValue() {
		return getNoValue.__ks_rt(this, arguments);
	};
	getNoValue.__ks_0 = function(event) {
		return event.expecting;
	};
	getNoValue.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, value => !value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return getNoValue.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function getYesValue() {
		return getYesValue.__ks_rt(this, arguments);
	};
	getYesValue.__ks_0 = function(event) {
		return event.value;
	};
	getYesValue.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, value => value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return getYesValue.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};