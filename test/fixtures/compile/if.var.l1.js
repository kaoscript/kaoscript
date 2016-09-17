module.exports = function() {
	let foo = {
		message: "hello"
	};
	let message;
	if((message = foo.message).length > 0) {
		console.log(message);
	}
}