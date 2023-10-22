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
				return Type.isDexObject(value, 0, 0, {value: mapper[0]});
			}
			else {
				return Type.isDexObject(value, 0, 0, {expecting: Type.isString});
			}
		}})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		if(event.ok) {
			console.log(event.value);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [Type.isString]);
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
		return (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = "hello";
			return o;
		})();
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(quxbaz.__ks_0());
};