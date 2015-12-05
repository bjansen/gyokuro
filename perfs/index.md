---
layout: default
---

# Performance tests

## Setup

* MacBook Pro (Retina, 15-inch, Mid 2015)  
* Processor: 2,8 GHz Intel Core i7  
* Memory: 16 Go 1600 MHz DDR3

Stress tests are run with [Gatling](http://gatling.io), scenarios are always the same,
except for the number of concurrent users which is adapted to what the framework seems
to handle:

    class Gyokuro extends Simulation {
    
        val httpProtocol = http
            .baseURL("http://localhost:8080")
            .inferHtmlResources()
    
        val uri1 = "localhost"
    
        val scn = scenario("gyokuro")
            .exec(HelloGyokuro.hello)
    
        setUp(scn.inject(atOnceUsers(100))).protocols(httpProtocol)
    }
    
    object HelloGyokuro {
        val headers_0 = Map("Upgrade-Insecure-Requests" -> "1")
    
        val hello = repeat(1000) { exec(
            http("Hello")
                .get("/hello")
                .headers(headers_0))
        };
    }

## Results

| Framework               | Language          | Req/s     |
|-------------------------|-------------------|-----------|
| [Symfony 3.0.0][1]      | PHP 5.5.29        | 127       |
| [Django 1.9][2]         | Python 3.5.0      | 1020      |
| [Spark Java 2.3][3]     | Java 1.8.0_51     | 4660      |
| **[gyokuro 0.1.0][4]**  | **Ceylon 1.2.0**  | **14295** |

[1]: symfony/
[2]: django/
[3]: spark/
[4]: gyokuro/
<br/>

## Additional notes

### Symfony

Using PHP's built-in server, Symfony didn't like heavy load *at all*: 100 concurrent users failed.
10 concurrent users worked, but the results were still pretty low (a few dozens rps).

Running Symfony on Apache, with Zend OpCache enabled, produced better results.

### Django

Like Symfony, Django (run via its built-in server) didn't like 100 concurrent users, 10 was okay.

### Spark

Run via maven-exec-plugin. 

### gyokuro

Run via `ceylon run`.