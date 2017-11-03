class UserMailer < ApplicationMailer
    default from: 'scheduler@bronsky.life'

    def invite_email(user, requestor)
        @user = user
        # Attaches .ics file to invite
        attachments['invite.ics'] = File.read("tmp/ics_files/invite.ics")
        mail(to: requestor, subject: 'Invitation for Scheduled Appointment')
    end

end
