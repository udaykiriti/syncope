class PingAllSitesJob < ApplicationJob
  queue_as :default

  def perform
    Site.find_each do |site|
      PingSiteJob.perform_later(site.id)
    end
  end
end
