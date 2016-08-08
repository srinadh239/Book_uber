class UserMailer < ApplicationMailer
	def book_uber(email)
		@email_address = email
		mail(to: @email_address, subject: 'Time to book Uber')
		Delayed::Worker.logger.debug("mail sent")
	end
	def cannot_book_uber(email)
		@email_address = email
		mail(to: @email_address, subject: 'Sorry, cannot book Uber now')
	end
end
