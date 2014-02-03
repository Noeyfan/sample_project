class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy
	has_secure_password
	before_save {email.downcase!}
	before_create :create_remember_token
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validate :name, presence: true, length: { maxium: 50}
	validate :email, presence: true, format: {with: VALID_EMAIL_REGEX},
						uniqueness: {case_sensitive: false}
	validate :password, length: {minimum: 6}
	validates_confirmation_of :password, if:lambda {|m| m.password.present? }
	
	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)	
		Digest::SHA1.hexdigest(token.to_s)
	end

	def feed
		Micropost.where("user_id = ?", id)
	end
	private
	
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)	
	end
end
