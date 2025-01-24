PublicSite::Engine.routes.draw do
  constraints subdomain: /.+/ do
    get '/', to: 'public_sites#show', as: :public_site
  end
end