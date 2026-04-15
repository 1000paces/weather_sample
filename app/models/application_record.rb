# Abstract class to inherit models from
# Not used in this simple app, but good practice
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
