class SitesController < ApplicationController
  def index
    @sites = Site.order(name: :asc)
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)
    if @site.save
      PingSiteJob.perform_later(@site.id)
      redirect_to sites_path, notice: "Site added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @site = Site.find(params[:id])
    @site.destroy
    redirect_to sites_path, notice: "Site removed."
  end

  private

  def site_params
    params.require(:site).permit(:name, :url)
  end
end
