json.array!(@credentials) do |credential|
  json.extract! credential, :id, :user_id, :public_key, :host
  json.url credential_url(credential, format: :json)
end
