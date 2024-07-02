const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Row = Helper.alias(value => Type.isDexObject(value, 1, 0, {id: Type.isNumber, createdAt: value => Type.isClassInstance(value, Date), links: value => Type.isArray(value, Row.is)}));
	let Foobar = Helper.namespace(function() {
		const Node = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString, parent: value => Node.is(value) || Type.isNull(value), rows: value => Type.isArray(value, Row.is)}));
		function foobar() {
			return foobar.__ks_rt(this, arguments);
		};
		foobar.__ks_0 = function(data) {
		};
		foobar.__ks_rt = function(that, args) {
			const t0 = Node.is;
			if(args.length === 1) {
				if(t0(args[0])) {
					return foobar.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		return {};
	});
};