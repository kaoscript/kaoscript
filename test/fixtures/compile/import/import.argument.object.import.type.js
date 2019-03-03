require("kaoscript/register");
module.exports = function() {
	var foobar = require("./import.argument.object.export.type.ks")().foobar;
	require("./import.argument.object.require.ks")(foobar);
};