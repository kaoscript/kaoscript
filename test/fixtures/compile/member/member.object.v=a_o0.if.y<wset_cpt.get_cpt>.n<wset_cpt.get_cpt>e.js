const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(add) {
		const values = new OBJ();
		if(add === true) {
			values["foo"] = "foo";
			console.log(values["foo"]);
		}
		else {
			values["foo"] = "foo";
			console.log(values["foo"]);
		}
		console.log(values["foo"]);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};