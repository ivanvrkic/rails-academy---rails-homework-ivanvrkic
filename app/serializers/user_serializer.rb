class UserSerializer < Blueprinter::Base
  identifier :id
  field :first_name
  field :last_name
  field :email
  field :created_at
  field :updated_at
end
