const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
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
			return Type.isObject(value);
		}
	}}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		let t, __ks_0;
		if(((__ks_0 = event.__ks_0()).ok ? (t = __ks_0, true) : false)) {
			console.log(t.value);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Event.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function event() {
		return event.__ks_rt(this, arguments);
	};
	event.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = false;
			return o;
		})();
	};
	event.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return event.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};