class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true, 
                    uniqueness: true,
                    format: {
                        with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9\.-]+\.[A-Za-z]+\Z/
                    }

    before_save :downcase_email

    def downcase_email
        self.email = email.downcase
    end
    
    def save 
        self.userkey = @userkey.save
    end

end