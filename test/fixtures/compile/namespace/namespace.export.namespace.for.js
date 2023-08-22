const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let ModuleA = Helper.namespace(function() {
		let ModuleB = Helper.namespace(function() {
			function foobar() {
				return foobar.__ks_rt(this, arguments);
			};
			foobar.__ks_0 = function() {
				return "foobar";
			};
			foobar.__ks_rt = function(that, args) {
				if(args.length === 0) {
					return foobar.__ks_0.call(that);
				}
				throw Helper.badArgs();
			};
			return {
				foobar
			};
		});
		return {
			foobar: ModuleB.foobar
		};
	});
	console.log(ModuleA.foobar.__ks_0());
};