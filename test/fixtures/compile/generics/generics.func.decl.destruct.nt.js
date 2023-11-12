const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function({name}, value) {
		console.log(Helper.toString(name));
		console.log(Helper.toString(value.name));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexObject(value, 1, 0, {name: Type.isValue});
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};