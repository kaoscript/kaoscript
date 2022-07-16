const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function() {
		return new Dictionary;
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	});
	if(Type.isStruct(Foobar)) {
	}
	const Quxbaz = Helper.struct(function() {
		const _ = Foobar.__ks_new();
		return _;
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	}, Foobar);
	const x = Quxbaz.__ks_new();
	if(Type.isStructInstance(x, Quxbaz)) {
	}
	if(Type.isStructInstance(x, Foobar)) {
	}
};