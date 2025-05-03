# Board Game Database Application

A full-stack Spring Boot web application that showcases board game listings with reviews, user authentication, and role-based permissions. This application serves as the example project for the Ultimate CI/CD DevOps Implementation Blueprint.

## Application Overview

This Spring Boot application displays a catalog of board games and their reviews with the following features:
- Anonymous users can browse the board game catalog and read reviews
- Authenticated users with the "user" role can add board games and write reviews
- Authenticated users with the "manager" role can add board games, write reviews, and edit/delete reviews
- RESTful API endpoints for programmatic access to board game data

## Technical Stack

- **Backend**: Java 17, Spring Boot, Spring MVC, Spring Security
- **Frontend**: Thymeleaf, HTML5, CSS, JavaScript, Bootstrap
- **Database**: H2 In-memory Database (configurable for production databases)
- **Build Tool**: Maven
- **Testing**: JUnit, Spring Test
- **Security**: Spring Security with form-based authentication
- **Containerization**: Docker

## Architecture

The application follows a layered architecture:

1. **Controllers Layer**: Handles HTTP requests and delegates to services
   - HomeController: Main application controller
   - BoardGameController: REST API controller

2. **Services Layer**: Implements business logic
   - Currently using direct database access, can be extended with service classes

3. **Data Access Layer**: Manages data persistence
   - DatabaseAccess: Provides database operations using JDBC

4. **Domain Layer**: Defines business entities
   - BoardGame: Represents a board game with its properties
   - Review: Represents user reviews for a board game

## Local Development Setup

### Prerequisites

- Java 17 JDK
- Maven 3.6+
- Git
- Docker (optional, for containerization)

### Build and Run Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/Khaled1771/TheUltimate-CI-CD.git
   cd TheUltimate-CI-CD/BoardGame
   ```

2. Build the application:
   ```bash
   ./mvnw clean package
   ```

3. Run the application:
   ```bash
   ./mvnw spring-boot:run
   ```

4. Access the application in your browser:
   - Open [http://localhost:8080](http://localhost:8080)
   - Default user accounts:
     - Username: `bugs` / Password: `bunny` (user role)
     - Username: `daffy` / Password: `duck` (manager role)

### Running Tests

Run the automated tests to verify application functionality:

```bash
./mvnw test
```

### Building Docker Image Locally

Create a Docker image of the application:

```bash
docker build -t boardgame:latest .
```

Run the Docker container:

```bash
docker run -p 8080:8080 boardgame:latest
```

## Database Configuration

The application uses an H2 in-memory database by default. The schema and initial data are loaded from `src/main/resources/schema.sql`.

For persistent storage, modify `application.properties` to use a different database:

```properties
# MySQL Example
spring.datasource.url=jdbc:mysql://localhost:3306/boardgame
spring.datasource.username=root
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```

## Security Model

The application implements a role-based access control system:

1. **Anonymous Users**: Can view the list of board games and existing reviews
2. **Authenticated Users with ROLE_USER**: Can add board games and write reviews
3. **Authenticated Users with ROLE_MANAGER**: Can add board games, write reviews, and edit/delete reviews

Authentication is handled via a form-based login, and authorization is managed through Spring Security.

## API Endpoints

The application provides RESTful API endpoints:

- `GET /boardgames`: Retrieve all board games
- `GET /boardgames/{id}`: Retrieve a specific board game
- `POST /boardgames`: Create a new board game

Example API usage:

```bash
# Get all board games
curl -X GET http://localhost:8080/boardgames

# Get a specific board game
curl -X GET http://localhost:8080/boardgames/1

# Create a new board game
curl -X POST http://localhost:8080/boardgames \
  -H "Content-Type: application/json" \
  -d '{"name":"Chess","level":3,"minPlayers":2,"maxPlayers":"2","gameType":"Strategy"}'
```

## CI/CD Integration

This application is part of the Ultimate CI/CD DevOps Implementation Blueprint, demonstrating:

1. **Continuous Integration**: Automated building and testing with Jenkins
2. **Continuous Delivery**: Automated deployment to Kubernetes
3. **Infrastructure as Code**: Terraform for infrastructure provisioning
4. **Configuration Management**: Ansible for server configuration

To see how this application is used in the CI/CD pipeline:

1. Explore the [Jenkins pipeline configuration](../Jenkins/)
2. Review the [Kubernetes deployment manifests](../Kubernetes/)
3. Understand the [infrastructure provisioning](../Terraform/)

## Next Steps

To continue with the CI/CD implementation:

1. Understand how the CI/CD pipeline processes this application
2. Return to the [main README](../README.md) for a complete overview of the CI/CD pipeline
3. Follow the step-by-step instructions to implement the full CI/CD workflow
