class UserMailer < ApplicationMailer
    default from: 'scheduler@bronsky.life'

    def invite_email(user, requestor)
        @user = user
        attachments['invite.ics'] = File.read("tmp/ics_files/invite.ics")
        mail(to: requestor, subject: 'Invitation for Scheduled Appointment')
    end

end
