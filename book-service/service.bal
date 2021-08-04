import ballerina/http;

# A service representing a network-accessible API
# bound to absolute path `/hello` and port `9090`.
service /hello on new http:Listener(9090) {

    # A resource respresenting an invokable API method
    # accessible at `/hello/sayHello`.
    #
    # + request - the inbound request
    # + return - the HTTP response
    resource function get sayHello(http:Request request) returns http:Response {
        http:Response response = new;

        response.statusCode = 200;
        response.setTextPayload("Hello Ballerina!");

        return response;
    }
}
