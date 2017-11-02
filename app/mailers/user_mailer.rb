class UserMailer < ApplicationMailer
    default from: 'scheduler@bronsky.life'

    def invite_email(user, requestor)
        mail(to: requestor, subject: 'Invitation for Scheduled Appointment')
    end

end
