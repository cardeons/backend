class User < ApplicationRecord
    has_secure_password

    validates_presence_of :email
    validates_uniqueness_of :email
    validates_presence_of :name
    validates_uniqueness_of :name
    has_and_belongs_to_many :cards
end
