module.exports = function() {
	let foo = {
		message: "hello"
	};
	if(true) {
		let message;
		if((message = foo.message).length > 0) {
			console.log(message);
		}
	}
};