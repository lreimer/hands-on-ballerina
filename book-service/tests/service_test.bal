import ballerina/test;
import ballerina/http;

// a test client to access the HTTP service endpoint
http:Client testClient = check new ("http://localhost:9090/api");

@test:Config {}
function testSayHello() returns error? {
    http:Response response = check testClient->get("/books");
    test:assertEquals(response.statusCode, 200);

    json[] books = <json[]> check response.getJsonPayload();
    test:assertEquals(books[0].isbn, "1234567890");
}
