class SecretariesController < ApplicationController
  before_action :set_secretary, only: %i[ show edit update destroy ]
  load_and_authorize_resource except: [ :create, :new, :index, :edit ]
  # GET /secretaries or /secretaries.json
  def index
    @secretaries = Secretary.all
  end

  # GET /secretaries/1 or /secretaries/1.json
  def show
  end

  # GET /secretaries/new
  def new
    @secretary = Secretary.new
  end

  # GET /secretaries/1/edit
  def edit
  end

  # POST /secretaries or /secretaries.json
  def create
    @secretary = Secretary.new(secretary_params)
    @secretary.tenant = Current.tenant

    respond_to do |format|
      if @secretary.save
        format.html { redirect_to @secretary, notice: t("secretaries.created") }
        format.json { render :show, status: :created, location: @secretary }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @secretary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /secretaries/1 or /secretaries/1.json
  def update
    respond_to do |format|
      if @secretary.update(secretary_params)
        format.html { redirect_to @secretary, notice: t("secretaries.updated"), status: :see_other }
        format.json { render :show, status: :ok, location: @secretary }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @secretary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /secretaries/1 or /secretaries/1.json
  def destroy
    @secretary.destroy!

    respond_to do |format|
      format.html { redirect_to secretaries_path, notice: t("secretaries.destroyed"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_secretary
      @secretary = Secretary.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def secretary_params
      params.expect(secretary: [ :cnpj, :corporate_name, :email, :name, :prefecture_name, :status ])
    end
end
