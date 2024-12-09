# SE_lab_6

## Question 1: What does the concept of stateless mean? How did we use this concept in our experiment?

### Stateless Concept:

In a stateless system, the server does not store any client context or session information between requests. Each request from the client contains all the information required for the server to process that request. Stateless systems ensure scalability, as each request is independent, and servers do not need to maintain complex session states.

### How We Used This Concept in the Experiment:

In our experiment, the RESTful API services we developed (/departments, /departments/{id}) are stateless. Each request sent to the server carries all the necessary data required for processing. For example:

- The **POST** request sends a complete `Department` object to create a new resource.
- The **GET** request fetches data without relying on any previously stored session state.
- The **PUT** request provides both the resource ID and updated details directly in the request.
- The **DELETE** request specifies the ID of the resource to delete.

The server does not retain any session-specific state between client requests. For instance, when a client sends a POST request to create a department, the server processes it independently without knowing about the client’s previous requests. This stateless design ensures that our microservice architecture remains lightweight, scalable, and capable of handling increasing loads effectively.

## Question 2: Study the differences between load balancing at Layer 4 and Layer 7 of the OSI model. Briefly explain their advantages compared to each other. In this experiment, which layer’s load balancing did we use?

### Differences Between Layer 4 and Layer 7 Load Balancing:

Layer 4 load balancing operates at the transport layer (TCP/UDP). It balances traffic based on network-level information such as IP addresses, ports, and protocols. It is lightweight and faster since it does not inspect the content of the requests, making it suitable for simple load balancing scenarios where performance is critical.

Layer 7 load balancing, on the other hand, operates at the application layer (HTTP/HTTPS). It can inspect the content of requests, such as URLs, headers, and API paths, to make routing decisions. This makes it more flexible and powerful compared to Layer 4. For instance, Layer 7 load balancing allows routing requests to different backend services based on specific paths, such as GET /departments and POST /departments, enabling more precise traffic distribution.

### Advantages:

The primary advantage of Layer 4 load balancing is its speed and efficiency, as it processes requests with lower overhead. It is ideal for scenarios with high traffic where content inspection is unnecessary. In contrast, Layer 7 load balancing provides more flexibility and allows for advanced routing based on content, making it suitable for complex applications like RESTful APIs.

### Which Layer We Used:

In our experiment, we used Layer 7 load balancing. Since the system we implemented involves a RESTful API that operates over HTTP, Layer 7 load balancing is appropriate. It allows us to distribute traffic based on specific API paths such as /departments and /departments/{id}. This ensures better load distribution among our backend services while maintaining the scalability and reliability of the system.
