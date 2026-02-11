# Rewards Redemption API

Coding challenge implementation for a basic rewards redemption app using Ruby on Rails and React+TS.
Frontend is not included in this repository. To see the frontend repository visit [rewards_redemtion_frontend](https://github.com/saarangsoltani/rewards_redemtion_frontend).

To facilitate testing, the Rails API is now hosted on AWS EC2, with the React frontend served via S3. I’ve configured CloudFront as the single entry point: requests for /api and /images are routed to the EC2 instance, while all other traffic goes to S3. Note that caching is currently disabled across all origins for real-time testing.

Access Link: https://d1x8219vfkxfve.cloudfront.net/rewards

Test Credentials: If a user runs out of points, please switch to another account:

Login emails: `user1@thanx.com`, `user2@thanx.com`, `user3@thanx.com`  
Password: `pass1234`  


## Tech Stack
- Backend: Ruby on Rails
- Ruby: 3.4.3
- Rails: 8.0.x (project is currently on `~> 8.0.4`)
- Database: SQLite (development/test), PostgreSQL
- Auth: JWT
- Serialization: ActiveModelSerializers

## API Endpoints
- `POST /api/v1/auth/login`: Authenticate user and return JWT + user details.
- `GET /api/v1/rewards`: List rewards.
- `POST /api/v1/redemptions`: Redeem a reward (requires `Authorization: Bearer <token>`).
- `GET /api/v1/redemptions`: List current user's redemption history (requires token).

Redemption flow is transaction-based in the service layer to keep balance updates and inventory updates consistent (db transactions + locks).


## Key Files (Services, Concerns, API, etc.)
```text
app/
  controllers/
    api/v1/
      auth_controller.rb                  -> Login endpoint that validates credentials and returns JWT + user balance.
      rewards_controller.rb               -> Returns rewards list.
      redemptions_controller.rb           -> Returns redemption history and creates redemptions.
    concerns/
      authenticatable.rb                  -> JWT-based request authentication concern for protected endpoints.
  models/
    user.rb,reward.rb,redemption.rb       -> ActiveRecord models
  serializers/
    reward_serializer.rb                  -> Reward response shape including computed availability and full image URL.
    redemption_serializer.rb              -> Redemption response shape including humanized timestamp and nested reward.
  services/ 
    redemption_service.rb                 -> Handles redemption business logic, locking, validation, and transactional updates.
db/seeds.rb                               -> Seed users and rewards for local testing.    
```

## Database Schema
Schema is defined with 3 core tables:
### **users**
|email (unique index) | password_digest | rewards_points_balance | created_at | updated_at |
|---------------------|----------------|----------------------|------------|------------|
### **rewards**
|name | description | points_cost | qty_available | image_url | created_at | updated_at |
|------|-------------|------------|---------------|-----------|------------|------------|
### **redemptions**
|user_id (FK → users) | reward_id (FK → rewards) | points_consumed | created_at | updated_at |
|---------------------|-------------------------|----------------|------------|------------|

### Relationships
- A `User` has many `Redemptions`
- A `Reward` has many `Redemptions`
- A `Redemption` belongs to one `User` and one `Reward`

Redemption flow is transaction-based in the service layer to keep balance updates and inventory updates consistent.


## Additional Gems used
- `bcrypt`: Password hashing via
- `jwt`: Token generation/verification for stateless authentication.
- `active_model_serializers`: Structured JSON serialization for API responses.
- `faker`: Seed data generation.
- `rspec-rails`: Testing framework.
- `factory_bot_rails`: Test factories.



## Setup and Run Locally
From project root:

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```
## Running Tests
```bash
bundle exec rspec
```

## Seeded Users (for quick testing)
Created by `db/seeds.rb`:
- `user1@thanx.com` / `pass1234`
- `user2@thanx.com` / `pass1234`
- `user3@thanx.com` / `pass1234`

## Notes on AI Usage
AI assistance was used for development support when writing tests and documentation drafting/refinement. 
