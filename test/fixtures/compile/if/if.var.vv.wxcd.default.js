const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isData: value => Type.isDexObject(value, 1, 0, {test: Type.isFunction, text: Type.isFunction})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(resolve) {
		let value = resolve();
		if(Type.isValue(value) && value.test()) {
			console.log(value.text());
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};