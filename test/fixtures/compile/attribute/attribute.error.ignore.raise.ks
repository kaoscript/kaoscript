#![error(ignore(Error), raise(Exception))]

extern sealed class Error

class Exception extends Error {
}

throw Exception.new()