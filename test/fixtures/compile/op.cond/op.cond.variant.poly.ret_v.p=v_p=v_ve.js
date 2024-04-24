const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
				return Type.isDexObject(value, 0, 0, {message: Type.isString});
			}
		}})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		return x.ok ? x : y.ok ? y : (() => {
			const o = new OBJ();
			o.ok = true;
			o.value = "hello";
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isEvent;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};