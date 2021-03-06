class CodesController < ApplicationController
  # GET /codes
  # GET /codes.json
  def index
    if params[:query] != ""
      @search = Code.search do
        fulltext params[:query] do
          highlight :code
        end
        with(:package)
        with(:package, params[:package]) if params[:package].present?
        facet :package
        paginate :page => params[:page], :per_page => 30
      end
   else
      @search = []
    end
#    return @search
    
    respond_to do |format|
      format.html 
      format.json { render json: @search.results }
    end
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
