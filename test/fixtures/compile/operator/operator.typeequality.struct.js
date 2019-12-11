var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function() {
		return new Dictionary;
	});
	if(Type.isStruct(Foobar)) {
	}
	var Quxbaz = Helper.struct(function() {
		const _ = Foobar.__ks_builder();
		return _;
	}, Foobar);
	const x = Quxbaz();
	if(Type.isStructInstance(x, Quxbaz)) {
	}
	if(Type.isStructInstance(x, Foobar)) {
	}
};