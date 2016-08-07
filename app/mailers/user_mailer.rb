class UserMailer < ApplicationMailer
	def book_uber(email)
		@email_address = email
		mail(to: @email_address, subject: 'Time to book Uber')
	end
end
