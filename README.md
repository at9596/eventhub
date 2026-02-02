EventHub APIEventHub is a high-performance, multi-vendor marketplace API built with Ruby on Rails 8. It allows organizers to create events, and customers to book seats using Stripe for secure payments.
# 🚀 Key FeaturesAuthentication: 
 - Secure JWT-based authentication for Users,       Organizers, and Admins.
 - Event Management: Full CRUD for organizers to manage their events.
 - Booking System: Transactional booking logic with seat availability validation.
 - Payments: Integrated Stripe Payment Intents for secure transactions.
 - Webhooks: Automated booking confirmation via Stripe Webhooks.
 - Background Jobs: Email notifications handled by Solid Queue.
 # 🛠 Tech StackFramework: 
 - Ruby on Rails 8.1 
 - Database: PostgreSQL
 - Authentication: JWT (JSON Web Token) 
  - Authorization: Pundit (Policy-based)
  - Background Processing: Solid Queue & Redis
  - Payments: Stripe Ruby SDK
  - Testing: RSpec, FactoryBot, Faker, WebMock
  ## 🚦 Getting StartedPrerequisitesRuby 3.3.0+PostgreSQL 15+Redis (for Solid Queue/Caching)InstallationClone the repository
      git clone https://github.com/your-username/eventhub.git

     cd eventhub
  - Install dependenciesBash bundle install
Setup the databaseBashbin/rails db:prepare
Run the applicationBashbin/rails s
🧪 TestingWe maintain high code quality with a comprehensive RSpec suite.Run the full suite:Bashbundle exec rspec
Coverage includes:Requests: API endpoint validation and response formats.Policies: Pundit role-based access control (RBAC).Services: StripePayment and JWT service logic.Mailers: Email delivery and content verification.Jobs: Background worker reliability.🔄 CI/CDThis project uses GitHub Actions for Continuous Integration. Every push and pull request is automatically tested against:PostgreSQL 15RedisFull RSpec Suite📝 API Documentation (Brief)MethodEndpointDescriptionAuth RequiredPOST/auth/signupUser registrationNoPOST/auth/loginObtain JWT tokenNoGET/api/v1/eventsList all eventsYesPOST/api/v1/events/:id/bookingsBook an eventYes (Customer)