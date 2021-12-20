# Deploy lambda function using Terraform and GitHub Actions.
##### Implement infrastructure as code (IaC) for a simple web application that runs on AWS Lambda that prints the request header, method, and body.

###### The application should be integrated with GitHub actionsCI/CD,

Example Test Case:

``` $ curl --header "Content-Type: application/json" --data '{"username":"xyz","password":"xyz"}' http://${URL}:${PORT}/api```

Response:

```Welcome to our demo API, here are the details of your request:```

Headers:

```Content-Type: application/json```

Method:

```Get```

Body:
```{"username":"xyz", "password":"xyz"}```


