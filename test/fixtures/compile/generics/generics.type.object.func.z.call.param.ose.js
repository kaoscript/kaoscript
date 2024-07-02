const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, mapper) => Type.isDexObject(value, 1, 0, {ok: Type.isBoolean, value: () => true}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		if(event.ok) {
			console.log(Helper.toString(event.value));
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [Type.any]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0((() => {
		const o = new OBJ();
		o.ok = true;
		o.value = "hello";
		return o;
	})());
};