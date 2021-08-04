import ballerina/test;
import ballerina/http;

// a test client to access the HTTP service endpoint
http:Client testClient = check new ("http://localhost:9090/hello");

@test:Config {}
function testSayHello() returns error? {
    http:Response response = check testClient->get("/sayHello");
    test:assertEquals(response.statusCode, 200);
    test:assertEquals(response.getTextPayload(), "Hello Ballerina!");
}