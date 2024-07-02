const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, mapper) => Type.isDexObject(value, 1, 0, {value: () => true}));
	const Value = Helper.alias(value => Type.isDexObject(value, 1, 0, {value: Type.isString}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function({value: body}) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [Value.is]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};