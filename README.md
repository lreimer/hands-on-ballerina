# Hands-on Ballerina Swan Lake

Demo repository for some Ballerina Swan Lake showcases. To build and run the demos,
make sure to have the latest Ballerina release installed. At the time of writing, this
was Swan Lake Beta 2.

## Book Service

A very simple in-memory REST service with a CRUD API for books.

```
$ cd book-service
$ bal build
$ kubectl apply -f target/kubernetes/book_service 
$ kubectl port-forward service/book-service 9090 9091

$ http get localhost:9091/q/health
$ http get localhost:9090/api/books
$ http --json post localhost:9090/api/books isbn13=0987654321 title=DemoDemoDemo
$ http get localhost:9090/api/books/0987654321
$ http delete localhost:9090/api/books/0987654321
$ http get localhost:9090/api/books/08154711

$ kubectl delete -f target/kubernetes/book_service 
``` 

## Isolated Service

Also a very simple in-memory REST service with a CRUD API for books. However, this implementation
heavily uses the concurrency safety features from Ballerina, such as `isolated` and `readonly`.

```
$ cd isolated-service
$ bal build
$ kubectl apply -f target/kubernetes/isolated_service 
$ kubectl port-forward service/isolated-service 9090 9091

$ http get localhost:9091/q/health
$ http get localhost:9090/api/books
$ http --json post localhost:9090/api/books isbn13=0987654321 title=DemoDemoDemo
$ http get localhost:9090/api/books/0987654321
$ http delete localhost:9090/api/books/0987654321
$ http get localhost:9090/api/books/08154711

$ kubectl delete -f target/kubernetes/isolated_service 
``` 

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

