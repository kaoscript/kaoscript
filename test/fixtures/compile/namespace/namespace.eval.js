const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let NS = Helper.namespace(function() {
		const foobar = 42;
		return {
			foobar
		};
	});
	expect(Type.isNamespace(NS)).to.equal(true);
	expect(NS.foobar).to.equal(42);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return "namespace";
	};
	foobar.__ks_1 = function(x) {
		return "number";
	};
	foobar.__ks_2 = function(x) {
		return "any";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isNamespace;
		const t2 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	expect(foobar.__ks_0(NS)).to.equal("namespace");
	expect(foobar.__ks_1(NS.foobar)).to.equal("number");
};