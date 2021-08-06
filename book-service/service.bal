import ballerina/http;
import ballerina/io;

// Bookstore handles all books for this service
BookStore store = new;

# A service representing a network-accessible API
# bound to absolute path `/api` and port `9090`.
@http:ServiceConfig {
    compression: {
        enable: http:COMPRESSION_ALWAYS,
        contentTypes: ["application/json"]
    },
    cors: {
        allowOrigins: ["http://localhost:9090"],
        allowCredentials: false,
        allowHeaders: [],
        exposeHeaders: [],
        maxAge: 3600
    }
}
service /api on new http:Listener(9090) {

    # API method to GET list of Books accessible at `/api/books`.
    #
    # + request - the inbound request
    # + return - the HTTP response
    resource function get books(http:Request request) returns http:Response {
        io:println("GET list of books");
        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload(store.all().toJson());
        return response;

    }

    # API method to POST a new Book accessible at `/api/books`.
    #
    # + request - the inbound request
    # + return - the HTTP response or client error
    resource function post books(http:Request request) returns http:Response|http:ClientError {
        io:println("POST new book");

        json payload = check request.getJsonPayload();
        json b = payload.cloneReadOnly();
        string isbn = store.create(<Book>b);

        http:Response response = new;
        response.statusCode = 201;
        response.setHeader("Location", "http://localhost:9090/api/books/" + isbn);

        return response;
    }

    # API method to GET a single book by ISBN13 accessible at `/api/books/[isbn13]`.
    #
    # + request - the inbound request
    # + return - the HTTP response
    resource function get books/[string isbn13](http:Request request) returns http:Response {
        io:println("GET book by ISBN13 " + isbn13);

        http:Response response = new;

        Book? book = store.get(isbn13);
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

        http:Response response = new;

        boolean deleted = store.delete(isbn13);
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
    string isbn13;
    # the book title
    string title;
|};

class BookStore {
    private map<Book> booksMap = {
        "1234567890": {isbn13: "1234567890", title: "Hands-on Ballerina"}
    };

    function all() returns Book[] {
        return self.booksMap.toArray();
    }

    function create(Book book) returns string {
        string id = book.isbn13;
        self.booksMap[id] = book;
        return id;
    }

    function get(string isbn13) returns Book? {
        return self.booksMap[isbn13];
    }

    function delete(string isbn13) returns boolean {
        Book|error? result = self.booksMap.removeIfHasKey(isbn13);
        return result is Book;
    }
}

# A service implemented Microprofile Health endpoints
service /q on new http:Listener(9091) {
    isolated resource function get health() returns http:Response {
        http:Response response = new;
        response.setJsonPayload({"status": "UP", "checks": []});
        return response;
    }

    isolated resource function get health/ready() returns http:Response {
        http:Response response = new;
        response.setJsonPayload({"status": "UP", "checks": []});
        return response;
    }

    isolated resource function get health/live() returns http:Response {
        http:Response response = new;
        response.setJsonPayload({"status": "UP", "checks": []});
        return response;
    }
}
