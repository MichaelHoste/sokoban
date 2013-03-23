class PacksController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => ['show']

  def index
    @packs = Pack.all
  end

  def show
    Rails.logger.info("PARAMS : " + params.inspect)
    if params[:signed_request]
      redirect_to "/auth/facebook/callback?signed_request=#{params['signed_request']}&state=canvas"
    end

    @pack = Pack.find_by_name(params[:id])
    @level = @pack.levels.first
    @selected_level_name = @level.name

    # Take first two rows of friends and public scores
    # (other rows are displayed by scores_controller in AJAX)
    @pushes_scores         = @level.best_scores.limit(6)
    if current_user
      @pushes_scores_friends = @level.best_scores.where(:user_id => current_user.friends + [current_user.id])
                                                 .limit(6)
    else
      @pushes_scores_friends = []
    end
  end
end


#Started GET "/auth/facebook/callback?state=2e94b5069655850f558861692433fd04ed056dd5fa11eceb&code=AQCUjrnAejHRyjwTAJ53XnF9xHuT7rUVXWhwHqvHhv9Yw80p8EXKFn_e4hyfJr39IO_omHBvdQuQXJ_HJXfm-jHEjouTd0vJGPwus2wbMOXWM_PJBgD9n_nbj9KL0Qp58js1HAX3TWlTOaFheGix0rdHXdFZMXffJSCLOmNufC-_g1vLhMBcDksYEsrOKmOKiPUkunLz7xT6y6adzSlbCZTY" for 127.0.0.1 at 2013-03-23 16:34:55 +0100
#Processing by SessionsController#create as HTML
#  Parameters: {"state"=>"2e94b5069655850f558861692433fd04ed056dd5fa11eceb", "code"=>"AQCUjrnAejHRyjwTAJ53XnF9xHuT7rUVXWhwHqvHhv9Yw80p8EXKFn_e4hyfJr39IO_omHBvdQuQXJ_HJXfm-jHEjouTd0vJGPwus2wbMOXWM_PJBgD9n_nbj9KL0Qp58js1HAX3TWlTOaFheGix0rdHXdFZMXffJSCLOmNufC-_g1vLhMBcDksYEsrOKmOKiPUkunLz7xT6y6adzSlbCZTY", "provider"=>"facebook"}


#Started POST "/?fb_source=appcenter&fb_appcenter=1" for 109.88.245.122 at 2013-03-23 16:41:06 +0100
#Processing by PacksController#show as HTML
#  Parameters: {"signed_request"=>"hz4r5p7erdBtv6qLA8BZneWUwNweKELvMOrmNORj9UQ.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzNjQwNTgwMDAsImlzc3VlZF9hdCI6MTM2NDA1MzI1NSwib2F1dGhfdG9rZW4iOiJBQUFFY1RQOFpDYWI0QkFEMEoxa2pMN3FMQUdSeEdwWkI1czFoMk9sVWZHdFhqT1ZNeUFEQndFbm43Y0dDdjA4UVlOY1EzNDd6QTlpV3g4U1Q5azZoODRWN1A0eFd6WGROWUo2Y09FMHdaRFpEIiwidXNlciI6eyJjb3VudHJ5IjoiYmUiLCJsb2NhbGUiOiJmcl9GUiIsImFnZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiI2MzQ0Nzg4MzcifQ", "fb_source"=>"appcenter", "fb_appcenter"=>"1", "id"=>"Novoban"}
#WARNING: Can't verify CSRF token authenticity
#PARAMS : {"signed_request"=>"hz4r5p7erdBtv6qLA8BZneWUwNweKELvMOrmNORj9UQ.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzNjQwNTgwMDAsImlzc3VlZF9hdCI6MTM2NDA1MzI1NSwib2F1dGhfdG9rZW4iOiJBQUFFY1RQOFpDYWI0QkFEMEoxa2pMN3FMQUdSeEdwWkI1czFoMk9sVWZHdFhqT1ZNeUFEQndFbm43Y0dDdjA4UVlOY1EzNDd6QTlpV3g4U1Q5azZoODRWN1A0eFd6WGROWUo2Y09FMHdaRFpEIiwidXNlciI6eyJjb3VudHJ5IjoiYmUiLCJsb2NhbGUiOiJmcl9GUiIsImFnZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiI2MzQ0Nzg4MzcifQ", "fb_source"=>"appcenter", "fb_appcenter"=>"1", "id"=>"Novoban", "controller"=>"packs", "action"=>"show"}
#
#Redirected to https://www.sokoban.be/auth/facebook?signed_request=hz4r5p7erdBtv6qLA8BZneWUwNweKELvMOrmNORj9UQ.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzNjQwNTgwMDAsImlzc3VlZF9hdCI6MTM2NDA1MzI1NSwib2F1dGhfdG9rZW4iOiJBQUFFY1RQOFpDYWI0QkFEMEoxa2pMN3FMQUdSeEdwWkI1czFoMk9sVWZHdFhqT1ZNeUFEQndFbm43Y0dDdjA4UVlOY1EzNDd6QTlpV3g4U1Q5azZoODRWN1A0eFd6WGROWUo2Y09FMHdaRFpEIiwidXNlciI6eyJjb3VudHJ5IjoiYmUiLCJsb2NhbGUiOiJmcl9GUiIsImFnZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiI2MzQ0Nzg4MzcifQ&state=canvas
#
#Completed 302 Found in 4ms (ActiveRecord: 0.3ms)
#Started GET "/auth/facebook?signed_request=hz4r5p7erdBtv6qLA8BZneWUwNweKELvMOrmNORj9UQ.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzNjQwNTgwMDAsImlzc3VlZF9hdCI6MTM2NDA1MzI1NSwib2F1dGhfdG9rZW4iOiJBQUFFY1RQOFpDYWI0QkFEMEoxa2pMN3FMQUdSeEdwWkI1czFoMk9sVWZHdFhqT1ZNeUFEQndFbm43Y0dDdjA4UVlOY1EzNDd6QTlpV3g4U1Q5azZoODRWN1A0eFd6WGROWUo2Y09FMHdaRFpEIiwidXNlciI6eyJjb3VudHJ5IjoiYmUiLCJsb2NhbGUiOiJmcl9GUiIsImFnZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiI2MzQ0Nzg4MzcifQ&state=canvas" for 109.88.245.122 at 2013-03-23 16:41:06 +0100
#Started GET "/auth/facebook/callback?signed_request=hz4r5p7erdBtv6qLA8BZneWUwNweKELvMOrmNORj9UQ.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzNjQwNTgwMDAsImlzc3VlZF9hdCI6MTM2NDA1MzI1NSwib2F1dGhfdG9rZW4iOiJBQUFFY1RQOFpDYWI0QkFEMEoxa2pMN3FMQUdSeEdwWkI1czFoMk9sVWZHdFhqT1ZNeUFEQndFbm43Y0dDdjA4UVlOY1EzNDd6QTlpV3g4U1Q5azZoODRWN1A0eFd6WGROWUo2Y09FMHdaRFpEIiwidXNlciI6eyJjb3VudHJ5IjoiYmUiLCJsb2NhbGUiOiJmcl9GUiIsImFnZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiI2MzQ0Nzg4MzcifQ&state=canvas" for 109.88.245.122 at 2013-03-23 16:41:06 +0100
#Started GET "/auth/failure?message=invalid_credentials&origin=https%3A%2F%2Fapps.facebook.com%2Fsokojax%2F%3Ffb_source%3Dappcenter%26fb_appcenter%3D1&strategy=facebook" for 109.88.245.122 at 2013-03-23 16:41:06 +0100
#Processing by SessionsController#failure as HTML
#  Parameters: {"message"=>"invalid_credentials", "origin"=>"https://apps.facebook.com/sokojax/?fb_source=appcenter&fb_appcenter=1", "strategy"=>"facebook"}
#
