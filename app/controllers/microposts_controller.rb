class MicropostsController < ApplicationController
	before_filter :signed_in_user, only: [:create, :destroy]
	before_filter :correct_user, only: :destroy


	def create
		@micropost = current_user.microposts.build(params[:micropost])
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_path
		else
			@feed_items = []
			render 'static_pages/home'
		end
	end

	def destroy
		@micropost.destroy
		redirect_to root_path
	end

	private
		def correct_user
			# Note: getting microposts via the user assoc guarantees
			# we are getting the micropost for the current_user, so its
			# okay for them to delete it
			@micropost = current_user.microposts.find(params[:id])
		rescue
			redirect_to root_path
		end
end
