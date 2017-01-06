# API Style Guide

## HTTP Requests used

+ `[GET]` - records list, or specific record
+ `[POST]` - create new record
+ `[PUT]` - update record
+ `[PATCH]` - partially update record
+ `[DELETE]` - delete record


> Use records names in plurals when creating API url

## CRUD Requests for a record

+ `[GET]    /records`
+ `[GET]    /records/:id`
+ `[POST]   /records/`
+ `[PUT]    /records/:id`
+ `[PATCH]  /records/:id`
+ `[DELETE] /records/:id`

## CRUD Requests for record relations

+ `[GET]    /records/:id/sub-records`
+ `[GET]    /records/:id/sub-records/:id`
+ `[POST]   /records/:id/sub-records`
+ `[PUT]    /records/:id/sub-records/:id`
+ `[PATCH]  /records/:id/sub-records/:id`
+ `[DELETE] /records/:id/sub-records/:id`

## Versioning

Specify in API url the version of the API you want to connect 

`GET http://api.server.com/v1/users`

In request header specify mayor release in the format yyyy-dd-mm

```
	Content-Type: application/json
	API-Version: 2016-07-06
```

##  Error codes

### HTTP response codes

+ `400` - bad request
+ `401` - unauthorized request
+ `403` - forbidden
+ `404` - requested url not found
+ `405` - method not allowed
+ `500` - internal server error
 
### API error response codes
+ `1001` - Invalid data request, or data missing.
+ `1002` - Record not created, invalid data request, or sent data invalid.
+ `1003` - Record not saved, invalid data request, or sent data invalid.
+ `1004` - Record not deleted, data missing, or invalid data request.
+ `1005` - Provided email is in use by another user.
+ `1006` - Invalid email and password combination.
+ `1007` - There is no user with provided email in our records.
+ `1008` - Invalid model request.
+ `1009` - Invalid recovery code.

