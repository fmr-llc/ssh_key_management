json.response do
  json.mode Rails.env
  json.cache @cached ? 'hit' : 'miss'
  json.time Time.zone.now - @start_time
  json.keys @authorized_keys.count
end
json.authorized_keys @authorized_keys
