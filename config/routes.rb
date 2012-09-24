SurveyWeb::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    match '/auth/:provider/callback', :to => 'sessions#create'
    match '/auth/failure', :to => 'sessions#failure'
    match '/signout', :to => 'sessions#destroy', :as => 'signout'

    match '/surveys/build/:id', :to => 'surveys#build', :as => "surveys_build"

    resources :surveys do
      put 'publish', 'unpublish', 'update_shared_orgs'
      get 'share'
      resources :responses, :only => [:new, :create, :show]
    end
    root :to => 'surveys#index'
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      resources :questions, :except => [:edit, :new]
      resources :options, :only => [:create, :update, :destroy]
      post 'questions/:id/image_upload' => 'questions#image_upload'
    end

    namespace :mobile, :defaults => { :format => 'json'} do
      scope :module => :v1 do
        resources :surveys, :only => [:index, :show]
      end
    end
  end
end
