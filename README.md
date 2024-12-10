# SE_lab_6
# Dockerizing یک پروژه Spring Boot با Load Balancing
---

## **مراحل Dockerizing پروژه**

### **ساخت فایل JAR**
در ابتدا، باید فایل JAR پروژه Spring Boot را می‌سازیم. با استفاده از دستور زیر در Maven می‌توانید این فایل را در پوشه `target` ایجاد کرد:

```bash
mvn clean package
```

این دستور یک فایل مانند `demo-0.0.1-SNAPSHOT.jar` در پوشه `target` ایجاد می‌کند.

---

### **ساخت فایل Dockerfile**
یک فایل `Dockerfile` در ریشه پروژه ایجاد می‌کنیم و مراحل ساخت Docker Image را در آن تعریف می‌کنیم:

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /usr/app
COPY target/demo-0.0.1-SNAPSHOT.jar department-service.jar
ENTRYPOINT ["java", "-jar", "department-service.jar"]
```
---

### **ساخت فایل `docker-compose.yml`**
فایل `docker-compose.yml` برای تعریف سرویس‌های مورد نیاز برنامه استفاده می‌شود. نمونه‌ای از این فایل به شرح زیر است:

```yaml
version: '3.8'

services:
  spring-dockerized-app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8082:8082"
    volumes:
      - ./src/main/resources/application.properties:/app/application.properties
    networks:
      - springboot-network

  h2database:
    image: buildo/h2database
    ports:
      - "9092:9092"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb
      - SPRING_DATASOURCE_USERNAME=sa
      - SPRING_DATASOURCE_PASSWORD=password
    networks:
      - springboot-network

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    networks:
      - springboot-network

networks:
  springboot-network:
    driver: bridge
```

---

### **انجام Load Balancing با NGINX**
در این مرحله، از **NGINX** به عنوان Load Balancer استفاده می‌کنیم. این سرویس درخواست‌ها را بین چند نمونه از سرویس Spring Boot توزیع می‌کند. همچنین تنظیمات spring-dockerized-app را دوباره و سه‌باره در docker-compose.yml قرار می‌دهیم تا سه سرویس برای Load Balancing داشته‌ باشیم.

#### فایل `nginx.conf`
یک فایل `nginx.conf` در کنار `docker-compose.yml` ایجاد می‌کنیم و تنظیمات زیر را در آن قرار می‌دهیم:

```nginx
events {}

http {
    upstream spring_app {
        server spring-dockerized-app:8082;
        server spring-dockerized-app-2:8082;
        server spring-dockerized-app-3:8082;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://spring_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

این تنظیمات از الگوریتم **Round Robin** برای توزیع درخواست‌ها بین سه سرور Spring Boot استفاده می‌کند و NGINX را برای گوش دادن به پورت 80 تنظیم می‌کند.

---

### **اجرای پروژه**
دستور زیر را اجرا می‌کنیم تا کانتینرها ساخته و اجرا شوند:

```bash
docker-compose up --build
```
پس از آماده‌سازی کانتینترها، برنامه روی پورت 80 از `localhost` قابل دسترسی است.

---

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
