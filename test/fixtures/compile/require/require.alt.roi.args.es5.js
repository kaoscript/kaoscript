require("kaoscript/register");
var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function(Color) {
	var Foobar = Helper.class({
		$name: "Foobar",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	});
	if(!Type.isValue(Color)) {
		var Color = require("./require.default.ks")(Foobar).Color;
	}
};