# Ashfall

A four phase AWS and Terraform project built to practise cloud infrastructure end to end: remote state, networking, a containerized application, managed compute and database, and a documented failure and recovery test.

The goal is not just a working deployment. Each phase is built deliberately, with the reasoning behind each decision recorded, so the repo doubles as a learning log.

## Status

| Phase | Scope | Status |
|-------|-------|--------|
| Bootstrap | Terraform remote state bucket and lock table | Complete |
| 1 | VPC, subnets, internet gateway, routing | Complete |
| 2 | Containerized Flask incident tracker | Complete |
| 3 | Compute and managed database (EC2, RDS) | Planned |
| 4 | Failure and recovery test, documented | Planned |

## Architecture

**Region:** us-east-1

**Bootstrap**
- S3 bucket for Terraform state (versioned, encrypted, public access blocked)
- DynamoDB table for state locking
- Uses local state on purpose, since it is a one time setup that creates the backend everything else depends on

**Phase 1: Network**
- VPC (10.0.0.0/16)
- Two public subnets and two private subnets, spread across two availability zones
- Internet gateway attached to the VPC
- Public route table with a default route to the internet gateway, associated with the public subnets
- Private subnets stay on the main route table with no internet route, by design

**Phase 2: Application**
- Flask and SQLAlchemy incident tracker with full CRUD
- Status field restricted to a validated set of values
- Packaged with Docker and served with gunicorn

**Planned**
- Phase 3 moves the app onto AWS compute and replaces SQLite with Postgres on RDS inside the private subnets.
- Phase 4 deliberately terminates instances under load and documents how the system fails and recovers. The test is run manually through the AWS CLI or console, not with automated chaos tooling.

## Repository structure

```
Ashfall/
├── bootstrap/   # Terraform for remote state (S3 and DynamoDB)
├── network/     # Terraform for VPC, subnets, routing
└── app/         # Flask incident tracker and Dockerfile
```

## API

| Method | Route | Purpose |
|--------|-------|---------|
| GET | /health | Health check, no database access |
| POST | /incidents | Create an incident |
| GET | /incidents | List incidents |
| PATCH | /incidents/<id> | Update an incident |
| DELETE | /incidents/<id> | Delete an incident |

An incident has an id, title, description, status (defaults to `open`), and created and updated timestamps.

## Running the app locally

Requires Docker.

```bash
cd app
docker build -t ashfall-app .
docker run -p 5000:5000 ashfall-app
```

Then, in another terminal:

```bash
curl -X POST http://localhost:5000/incidents \
  -H "Content-Type: application/json" \
  -d '{"title": "Test incident", "description": "Checking the API"}'

curl http://localhost:5000/incidents
```

## Using the Terraform code

Requires Terraform and the AWS CLI configured with a profile named `ashfall`.

```bash
cd bootstrap && terraform init && terraform apply
cd ../network && terraform init && terraform apply
```

This creates real AWS resources and may incur cost. Set up billing alerts first.

## Decisions and lessons

- **Backend and provider credentials are separate.** Terraform resolves the S3 backend before the provider block, so the `profile` setting is needed in both places.
- **Two availability zones from the start.** This isolates AZ failures and is required later for the RDS subnet group.
- **Bootstrap uses local state deliberately.** It creates the backend, so it cannot depend on it.
- **Known gap:** SQLite inside the container is not persistent across restarts. This is accepted for now and resolved in Phase 3 by moving to RDS.
- **Validation caught in testing.** The API originally accepted any status string. Testing exposed it, and the check now applies to both create and update.

## Notes

This is a learning and portfolio project. Resource names use the `ashfall` prefix throughout.