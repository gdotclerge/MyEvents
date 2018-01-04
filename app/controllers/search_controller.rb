require 'pry'
require 'rest-client'
require 'json'


class SearchController < ApplicationController
  #
  # def search
  #   @keyword = params[:format]
  #   @event_results = event_search()
  #   render 'results'
  # end

  def results
    # @keyword = params[:format]
    @event_results = event_search()
    @search_event_results = creates_event_instances(@event_results).map

  end

  def show
  end


  private

  def event_search
    keyword_search = params[:format].split.join("+").to_s
    keyword_search_path = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=wCElOJlP8V5gpb6GGKmL3c9hKAva1dRq&size=20&keyword=#{keyword_search}"
    JSON.parse(RestClient.get(keyword_search_path))
  end

  def creates_event_instances(json_results)
    json_results["_embedded"]["events"].map do |e|
      ev = Event.create(name: e["name"], sale_date: e["sales"]["public"]["startDateTime"], start_date: e["dates"]["start"]["dateTime"], venue: ven = Venue.find_or_create_by(name: e["_embedded"]["venues"][0]["name"]))
      ven.update(city: e["_embedded"]["venues"][0]["city"]["name"])
      if e["_embedded"]["attractions"]
        e["_embedded"]["attractions"].each do |attr|
          ev.attractions << Attraction.find_or_create_by(name: attr["name"])
        end
      end
      ev
    end
  end



  # @venues = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/venues.json?apikey=wCElOJlP8V5gpb6GGKmL3c9hKAva1dRq&size=20&keyword=#{@keyword.split.join('+')}"))
  # @attractions = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/attractions.json?apikey=wCElOJlP8V5gpb6GGKmL3c9hKAva1dRq&size=20&keyword=#{@keyword.split.join('+')}"))

end
