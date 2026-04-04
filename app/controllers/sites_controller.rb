class SitesController < ApplicationController
  def index
    @sites = Site.includes(:latest_check).order(name: :asc)
  end

  def show
    @site = Site.find(params[:id])
    @checks = @site.checks.order(checked_at: :desc).limit(100)
    @recent_checks = @site.checks.order(checked_at: :desc).limit(20).reverse
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

  def edit
    @site = Site.find(params[:id])
  end

  def update
    @site = Site.find(params[:id])
    if @site.update(site_params)
      redirect_to site_path(@site), notice: "Settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @site = Site.find(params[:id])
    @site.destroy
    redirect_to sites_path, notice: "Site removed."
  end

  def ping
    @site = Site.find(params[:id])
    PingSiteJob.perform_now(@site.id)
    redirect_to sites_path, notice: "#{@site.name} pinged successfully."
  end

  def ping_all
    Site.find_each do |site|
      PingSiteJob.perform_now(site.id)
    end
    redirect_to sites_path, notice: "All sites pinged."
  end

  # JSON API for status badges
  def status_badge
    site = Site.find(params[:id])
    check = site.latest_check

    render json: {
      name: site.name,
      url: site.url,
      status: check ? (check.status >= 200 && check.status < 300 ? "up" : "down") : "pending",
      http_code: check&.status,
      response_ms: check&.duration_ms,
      uptime: site.uptime_percentage,
      checked_at: check&.checked_at&.iso8601
    }
  end

  private

  def site_params
    params.require(:site).permit(:name, :url, :check_interval_seconds, :alert_email)
  end
end
