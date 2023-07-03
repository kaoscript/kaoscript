const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function init() {
		return init.__ks_rt(this, arguments);
	};
	init.__ks_0 = function(data, builder) {
		let statement, fragment;
		const block = builder.newBlock();
		for(let __ks_2 = data.block(data.body).statements, __ks_1 = 0, __ks_0 = __ks_2.length; __ks_1 < __ks_0; ++__ks_1) {
			statement = __ks_2[__ks_1];
			block.statement(statement);
		}
		block.done();
		let source = "";
		for(let __ks_2 = builder.toArray(), __ks_1 = 0, __ks_0 = __ks_2.length; __ks_1 < __ks_0; ++__ks_1) {
			fragment = __ks_2[__ks_1];
			source = Helper.concatString(source, fragment.code);
		}
		return source;
	};
	init.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return init.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};