import ballerina/http;
import ballerina/io;

// Bookstore handles all books for this service
isolated BookStore store = new;

# A service representing a network-accessible API
# bound to absolute path `/api` and port `9090`.
service /api on new http:Listener(9090) {

    # API method to GET list of Books accessible at `/api/books`.
    #
    # + caller - the client caller
    # + request - the inbound request
    isolated resource function get books(http:Caller caller, http:Request request) {
        io:println("GET list of books");

        Book[] books;
        lock {
            books = store.all();
        }

        http:Response response = new;
        response.setJsonPayload(books.toJson());
        checkpanic caller->respond(response);
    }

    # API method to POST a new Book accessible at `/api/books`.
    #
    # + caller - the client caller
    # + request - the inbound request
    resource function post books(http:Caller caller, http:Request request) {
        io:println("POST new book");

        json payload = checkpanic request.getJsonPayload();
        json b = payload.cloneReadOnly();

        string isbn;
        lock {
            isbn = store.create(<Book>b);
        }

        http:Response response = new;
        response.statusCode = 201;
        response.setHeader("Location", "http://localhost:9090/api/books/" + isbn);

        checkpanic caller->respond(response);
    }

    # API method to GET a single book by ISBN13 accessible at `/api/books/[isbn13]`.
    #
    # + request - the inbound request
    # + return - the HTTP response
    resource function get books/[string isbn13](http:Request request) returns http:Response {
        io:println("GET book by ISBN13 " + isbn13);

        Book? book;
        lock {
            book = store.get(isbn13);
        }

        http:Response response = new;

        if book == () {
            io:println("Unknown book with ISBN13 " + isbn13);
            response.statusCode = 404;
        } else {
            io:println("Found book with ISBN13 " + isbn13);
            response.statusCode = 200;
            response.setJsonPayload(book.toJson());
        }

        return response;
    }

    # API method to DELETE a single book by ISBN13 accessible at `/api/books/[isbn13]`.
    #
    # + request - the inbound request
    # + return - the HTTP response
    resource function delete books/[string isbn13](http:Request request) returns http:Response {
        io:println("DELETE book by ISBN13 " + isbn13);

        boolean deleted;
        lock {
            deleted = store.delete(isbn13);
        }

        http:Response response = new;

        if deleted {
            io:println("Deleted book with ISBN13 " + isbn13);
            response.statusCode = 204;
        } else {
            io:println("Unknown book with ISBN13 " + isbn13);
            response.statusCode = 404;
        }

        return response;
    }
}

# Closed Book type record
type Book record {|
    # the ISBN-13
    readonly string isbn13;
    # the book title
    readonly string title;
|};

isolated class BookStore {
    private map<Book> booksMap = {
        "1234567890": {isbn13: "1234567890", title: "Hands-on Ballerina"}
    };

    isolated function all() returns Book[] {
        lock {
            return self.booksMap.cloneReadOnly().toArray();
        }
    }

    isolated function create(Book book) returns string {
        string id = book.isbn13;
        lock {
            self.booksMap[id] = book;
        }
        return id;
    }

    isolated function get(string isbn13) returns Book? & readonly {
        lock {
            return self.booksMap[isbn13];
        }
    }

    isolated function delete(string isbn13) returns boolean {
        Book|error? result;
        lock {
            result = self.booksMap.removeIfHasKey(isbn13);
        }
        return result is Book;
    }
}
