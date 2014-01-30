class PeopleController < ApplicationController

  def search
    Person.load_redis
  end

  def autocomplete
    query = params[:user_input].to_s.capitalize
    @results = Person.complete(query,50)
    respond_to do |format|
      format.json { render :json => @results, :status => :ok }
    end
  end

end
