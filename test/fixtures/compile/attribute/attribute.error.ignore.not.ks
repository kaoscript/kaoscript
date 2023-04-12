#![error(ignore(Error))]

extern sealed class Error

class Exception extends Error {
}

throw Error.new()