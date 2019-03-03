require("kaoscript/register");
module.exports = function() {
	var foobar = require("./import.argument.namespace.export.ks")().foobar;
	require("./import.argument.namespace.require.ks")(foobar);
};