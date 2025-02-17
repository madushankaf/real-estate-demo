import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;

type RentalRequest record {
    string consumer_id;
    string property_id;
    string rental_start_date;
    int rental_duration_days;
    string payment_method;
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

mysql:Client dbClient = check new (user = USER, password = PASSWORD, database = DATABASE, host = HOST, port = PORT);

service /rental on new http:Listener(8080) {

    resource function post rental(@http:Payload RentalRequest rentalRequest) returns int|error? {
        log:printInfo("Received a rental request");

        sql:ParameterizedQuery query = `INSERT INTO rentals (consumer_id, property_id, rental_start_date, rental_duration_days, payment_method) 
                                        VALUES (${rentalRequest.consumer_id}, ${rentalRequest.property_id}, ${rentalRequest.rental_start_date}, ${rentalRequest.rental_duration_days}, ${rentalRequest.payment_method})`;

        sql:ExecutionResult result = check dbClient->execute(query);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return lastInsertId;
        } else {
            log:printError("Unable to obtain last insert ID");
            return error("Unable to obtain last insert ID");
        }
    }
}
