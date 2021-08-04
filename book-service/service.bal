import ballerina/http;
import ballerina/io;

// Bookstore handles all books for this service
BookStore store = new;

# A service representing a network-accessible API
# bound to absolute path `/api` and port `9090`.
service /api on new http:Listener(9090) {

    # A resource respresenting an invokable API method
    # accessible at `/api/books`.
    #
    # + request - the inbound request
    # + return - the HTTP response
    resource function get books(http:Request request) returns http:Response {
        io:println("GET list of books.");

        http:Response response = new;
        response.statusCode = 200;
        response.setJsonPayload(store.all());

        return response;
    }
}

class BookStore {
    private map<json> booksMap = {
        "1234567890": {"isbn": "1234567890", "title": "Hands-on Ballerina"}
    };
    
    function all() returns json[] {
        return self.booksMap.toArray();
    }
}