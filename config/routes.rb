Rails.application.routes.draw do
  resources :clauses
  resources :subparagraphs
  resources :subsections
  resources :subsection_paragraphs
  resources :section_paragraphs
  resources :sections
  resources :chapters
  resources :parts
  resources :titles
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
