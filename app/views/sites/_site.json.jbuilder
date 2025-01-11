json.extract! site, :id, :name, :subdomain, :account_id, :created_at, :updated_at
json.url site_url(site, format: :json)
