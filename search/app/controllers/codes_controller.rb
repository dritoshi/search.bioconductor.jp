class CodesController < ApplicationController
  # GET /codes
  # GET /codes.json
  def index
    @search = Code.search do
      fulltext params[:query] do
        highlight :code
      end
    end
    @codes = @search.results
=begin
    @codes = Code.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes }
    end
=end
  end

  # GET /codes/1
  # GET /codes/1.json
  def show
    @code = Code.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code }
    end
  end

end
