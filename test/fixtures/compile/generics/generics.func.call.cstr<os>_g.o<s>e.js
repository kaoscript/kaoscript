const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Named = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		console.log(value.name);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Named.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0((() => {
		const o = new OBJ();
		o.name = "Hello!";
		return o;
	})());
};