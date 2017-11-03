class UserMailer < ApplicationMailer
    default from: 'scheduler@bronsky.life'

    def invite_email(user, requestor)
        @user = user
        attachments['sample.ics'] = File.read("tmp/ics_files/sample.ics")
        mail(to: requestor, subject: 'Invitation for Scheduled Appointment')
    end

end
