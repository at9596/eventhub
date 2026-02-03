module AuthHelpers
  def sign_in_as(user)
    token = JsonWebToken.encode(user_id: user.id)

    # 1. Create a "fake" request so Rails can give us a CookieJar
    request = ActionDispatch::Request.new(Rails.application.env_config)

    # 2. Use Rails' own jar to sign the token
    # This ensures the encryption key and purpose match your app exactly
    jar = ActionDispatch::Cookies::CookieJar.build(request, {})
    jar.signed[:jwt] = { value: token, httponly: true }

    # 3. Extract the raw "Set-Cookie" string (e.g., "jwt=SFMyNTY...")
    # This is what a browser would actually send
    cookie_string = jar.to_header.split(';').first

    # 4. Set the header for the upcoming RSpec request
    # In Request specs, we can use 'header' if using Rack::Test directly,
    # but returning a Hash is more compatible with 'post url, headers: ...'
    { "Cookie" => cookie_string }
  end

  def auth_headers(user)
    sign_in_as(user)
    # {} # Return empty hash because the cookie is now in the jar
  end
end
