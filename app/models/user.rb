class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true, 
                    uniqueness: true,
                    format: {
                        with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9\.-]+\.[A-Za-z]+\Z/
                    }

    validates :username, presence: true, uniqueness: { case_sensitive: false }
                    
    before_save :downcase_email
    before_save :downcase_username

    def downcase_email
        self.email = email.downcase
    end
    def downcase_username
        self.username = username.downcase
    end
end