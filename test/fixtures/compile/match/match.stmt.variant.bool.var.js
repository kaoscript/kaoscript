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
				return Type.isDexObject(value, 0, 0, {message: value => Type.isString(value) || Type.isNull(value)});
			}
		}})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let x = loadEvent.__ks_0();
		if(x.ok) {
			console.log(x.value);
		}
		else if(!x.ok) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function loadEvent() {
		return loadEvent.__ks_rt(this, arguments);
	};
	loadEvent.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.ok = false;
			return o;
		})();
	};
	loadEvent.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return loadEvent.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};