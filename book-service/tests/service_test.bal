import ballerina/test;
import ballerina/http;

// a test client to access the HTTP service endpoint
http:Client testClient = check new ("http://localhost:9090/api");

@test:Config {}
function testGetBooks() returns error? {
    http:Response response = check testClient->get("/books");
    test:assertEquals(response.statusCode, 200);

    json[] books = <json[]>check response.getJsonPayload();
    test:assertEquals(books[0].isbn13, "1234567890");
}

@test:Config {}
function testCreateBook() returns error? {
    Book message = {isbn13: "0987654321", title: "Test Test Test"};
    http:Response response = check testClient->post("/books", message.toJson());
    test:assertEquals(response.statusCode, 201);

    string location = check response.getHeader("Location");
    test:assertEquals(location, "http://localhost:9090/api/books/0987654321");
}

@test:Config {}
function testGetBook() returns error? {
    http:Response response = check testClient->get("/books/1234567890");
    test:assertEquals(response.statusCode, 200);

    json payload = check response.getJsonPayload();
    json b = payload.cloneReadOnly();
    Book book = <Book> b;

    test:assertEquals(book.isbn13, "1234567890");
    test:assertEquals(book.title, "Hands-on Ballerina");
}

@test:Config {}
function testGetUnknownBook() returns error? {
    http:Response response = check testClient->get("/books/4711");
    test:assertEquals(response.statusCode, 404);
}

@test:Config {dependsOn: [testCreateBook]}
function testDeleteBook() returns error? {
    http:Response response = check testClient->delete("/books/0987654321");
    test:assertEquals(response.statusCode, 204);
}

@test:Config {}
function testDeleteUnknownBook() returns error? {
    http:Response response = check testClient->delete("/books/4711");
    test:assertEquals(response.statusCode, 404);
}
